import SwiftUI

/// Lets the user fill in the prior 4 15-minute blocks (the last hour),
/// with "same as above" to copy a category forward.
struct CaptureView: View {
    @Environment(AuditStore.self) private var store
    @State private var selectedDate: Date = .now

    private var lastFourSlots: [Int] {
        let currentSlot = Calendar.current.component(.hour, from: selectedDate) * TimeBlock.blocksPerHour
            + Calendar.current.component(.minute, from: selectedDate) / 15
        return (max(0, currentSlot - 4)..<currentSlot).map { $0 }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(lastFourSlots, id: \.self) { slot in
                    SlotRow(slot: slot, date: selectedDate)
                }
            }
            .navigationTitle("Last Hour")
        }
    }
}

private struct SlotRow: View {
    @Environment(AuditStore.self) private var store
    let slot: Int
    let date: Date

    private var assignedCategory: TimeCategory? {
        let day = Calendar.current.startOfDay(for: date)
        guard let block = store.timeBlocks.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: day) && $0.slotIndex == slot
        }), let categoryID = block.categoryID else { return nil }
        return store.categories.first { $0.id == categoryID }
    }

    var body: some View {
        Menu {
            ForEach(store.categories) { category in
                Button(category.name) {
                    store.setCategory(category.id, forSlot: slot, on: date)
                }
            }
        } label: {
            HStack {
                Text(slotLabel)
                Spacer()
                Text(assignedCategory?.name ?? "Unassigned")
                    .foregroundStyle(assignedCategory == nil ? .secondary : .primary)
            }
        }
    }

    private var slotLabel: String {
        let hour = slot / TimeBlock.blocksPerHour
        let minute = (slot % TimeBlock.blocksPerHour) * 15
        return String(format: "%02d:%02d", hour, minute)
    }
}

#Preview {
    CaptureView()
        .environment(AuditStore())
}
