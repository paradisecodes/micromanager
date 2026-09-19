import Foundation
import Observation

/// A merged run of one or more contiguous 15-minute blocks sharing the same
/// assignment (or the same "unassigned" gap), as shown in the Today timeline.
struct TimelineEntry: Identifiable {
    let id = UUID()
    let startSlot: Int
    let endSlot: Int
    let categoryID: UUID?
    let subcategoryID: UUID?

    var isGap: Bool { categoryID == nil }
    var durationMinutes: Int { (endSlot - startSlot) * 15 }
}

/// In-memory/local store for the active audit. Swap for a Supabase-backed
/// implementation later; nothing above this layer should need to change.
@Observable
final class AuditStore {
    var categories: [TimeCategory] = TimeCategory.defaultSet
    var currentAudit: Audit?
    var timeBlocks: [TimeBlock] = []
    var checkIns: [DailyCheckIn] = []

    // MARK: - Audit lifecycle

    func startAudit(on date: Date = .now) {
        currentAudit = Audit(startDate: date)
    }

    /// 1-based day number within the current audit, or nil if there's no active audit.
    func dayNumber(for date: Date = .now) -> Int? {
        guard let audit = currentAudit else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: audit.startDate), to: Calendar.current.startOfDay(for: date)).day ?? 0
        return days + 1
    }

    /// One entry per audit day: `true` = fully in the past (counted as complete for
    /// the progress strip), `nil` = today (in progress), not present = future day.
    func progressStrip(referenceDate: Date = .now) -> [Bool?] {
        guard let audit = currentAudit else { return [] }
        let totalDays = Calendar.current.dateComponents([.day], from: audit.startDate, to: audit.endDate).day ?? 14
        let today = Calendar.current.startOfDay(for: referenceDate)
        return (0..<totalDays).map { offset in
            guard let day = Calendar.current.date(byAdding: .day, value: offset, to: audit.startDate) else { return false }
            let dayStart = Calendar.current.startOfDay(for: day)
            if dayStart < today { return true }
            if dayStart == today { return nil }
            return false
        }
    }

    // MARK: - Categories

    func category(withID id: UUID?) -> TimeCategory? {
        categories.first { $0.id == id }
    }

    func subcategory(withID id: UUID?, in category: TimeCategory?) -> Subcategory? {
        category?.subcategories.first { $0.id == id }
    }

    // MARK: - Blocks

    func block(on date: Date, slot: Int) -> TimeBlock? {
        let day = Calendar.current.startOfDay(for: date)
        return timeBlocks.first { Calendar.current.isDate($0.date, inSameDayAs: day) && $0.slotIndex == slot }
    }

    func setBlock(categoryID: UUID?, subcategoryID: UUID?, forSlot slotIndex: Int, on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        if let index = timeBlocks.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: day) && $0.slotIndex == slotIndex }) {
            timeBlocks[index].categoryID = categoryID
            timeBlocks[index].subcategoryID = subcategoryID
        } else {
            timeBlocks.append(TimeBlock(date: day, slotIndex: slotIndex, categoryID: categoryID, subcategoryID: subcategoryID))
        }
    }

    /// Merges contiguous same-assignment blocks (and unassigned gaps) from
    /// midnight up to `slot` into display-ready rows for the Today timeline.
    func timeline(for date: Date, upToSlot slot: Int) -> [TimelineEntry] {
        var entries: [TimelineEntry] = []
        var runStart = 0
        var runCategory: UUID?
        var runSubcategory: UUID?

        func flush(at end: Int) {
            guard end > runStart else { return }
            entries.append(TimelineEntry(startSlot: runStart, endSlot: end, categoryID: runCategory, subcategoryID: runSubcategory))
        }

        for s in 0..<max(slot, 0) {
            let assignment = block(on: date, slot: s)
            let (cat, sub) = (assignment?.categoryID, assignment?.subcategoryID)
            if cat != runCategory || sub != runSubcategory {
                flush(at: s)
                runStart = s
                runCategory = cat
                runSubcategory = sub
            }
        }
        flush(at: slot)
        return entries
    }

    // MARK: - Check-ins

    func recordCheckIn(mood: Int, energy: Int, for date: Date = .now) {
        checkIns.append(DailyCheckIn(date: date, mood: mood, energy: energy))
    }

    // MARK: - Report

    struct CategoryTotal: Identifiable {
        let category: TimeCategory
        var minutes: Int
        var id: UUID { category.id }
    }

    /// Minutes logged per user-defined category (Sleep/Untracked excluded),
    /// across every block ever recorded in this audit.
    func categoryTotals() -> [CategoryTotal] {
        var minutesByCategory: [UUID: Int] = [:]
        for block in timeBlocks {
            guard let categoryID = block.categoryID,
                  let category = category(withID: categoryID),
                  !category.isSystemDefault else { continue }
            minutesByCategory[categoryID, default: 0] += 15
        }
        return categories
            .filter { !$0.isSystemDefault }
            .map { CategoryTotal(category: $0, minutes: minutesByCategory[$0.id, default: 0]) }
            .sorted { $0.minutes > $1.minutes }
    }

    struct SubcategoryTotal: Identifiable {
        let subcategory: Subcategory
        var minutes: Int
        var id: UUID { subcategory.id }
    }

    /// Minutes logged per subcategory within a single category.
    func subcategoryTotals(for category: TimeCategory) -> [SubcategoryTotal] {
        var minutesBySubcategory: [UUID: Int] = [:]
        for block in timeBlocks where block.categoryID == category.id {
            guard let subcategoryID = block.subcategoryID else { continue }
            minutesBySubcategory[subcategoryID, default: 0] += 15
        }
        return category.subcategories
            .map { SubcategoryTotal(subcategory: $0, minutes: minutesBySubcategory[$0.id, default: 0]) }
            .sorted { $0.minutes > $1.minutes }
    }
}

extension AuditStore {
    /// Seeded store for SwiftUI previews (and the `-seedPreviewAudit` debug launch
    /// argument) — mirrors the "Day 3" state shown in the hi-fi mockups. Not gated
    /// behind `#if DEBUG`: Xcode's `#Preview` macro compiles into Release builds too
    /// via `xcodebuild`, so this needs to always be available; it's simply unused in
    /// a shipped build since nothing else calls it outside of previews/debug launches.
    static func preview() -> AuditStore {
        let store = AuditStore()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        store.startAudit(on: calendar.date(byAdding: .day, value: -2, to: today) ?? today)

        guard let work = store.categories.first(where: { $0.name == "Work" }),
              let family = store.categories.first(where: { $0.name == "Family" }) else { return store }
        let deepWork = work.subcategories.first { $0.name == "Deep work" }
        let admin = work.subcategories.first { $0.name == "Admin" }
        let meals = family.subcategories.first { $0.name == "Meals" }

        func fill(_ range: Range<Int>, categoryID: UUID?, subcategoryID: UUID?) {
            for slot in range { store.setBlock(categoryID: categoryID, subcategoryID: subcategoryID, forSlot: slot, on: today) }
        }
        // 6:00-6:45 Exercise (Health), 6:45-8:00 Breakfast (Family/Meals), 8:00-9:00 gap, 9:00-10:00 Deep work
        if let health = store.categories.first(where: { $0.name == "Health" }) {
            fill(24..<27, categoryID: health.id, subcategoryID: health.subcategories.first { $0.name == "Exercise" }?.id)
        }
        fill(27..<32, categoryID: family.id, subcategoryID: meals?.id)
        fill(36..<40, categoryID: work.id, subcategoryID: deepWork?.id)
        _ = admin
        return store
    }
}
