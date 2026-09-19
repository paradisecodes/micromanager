import Foundation
import Observation

/// In-memory/local store for the active audit. Swap for a Supabase-backed
/// implementation later; nothing above this layer should need to change.
@Observable
final class AuditStore {
    var categories: [TimeCategory] = TimeCategory.defaultSet
    var currentAudit: Audit?
    var timeBlocks: [TimeBlock] = []
    var checkIns: [DailyCheckIn] = []

    func startAudit(on date: Date = .now) {
        currentAudit = Audit(startDate: date)
    }

    func setCategory(_ categoryID: UUID?, forSlot slotIndex: Int, on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        if let index = timeBlocks.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: day) && $0.slotIndex == slotIndex
        }) {
            timeBlocks[index].categoryID = categoryID
        } else {
            timeBlocks.append(TimeBlock(date: day, slotIndex: slotIndex, categoryID: categoryID))
        }
    }

    func recordCheckIn(mood: Int, energy: Int, for date: Date = .now) {
        checkIns.append(DailyCheckIn(date: date, mood: mood, energy: energy))
    }
}
