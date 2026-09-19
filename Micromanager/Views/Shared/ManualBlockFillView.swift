import SwiftUI

/// Simple per-slot manual assignment. Reused by the catch-up flow's "Fill
/// block by block" option and by voice capture's "Enter manually instead".
struct ManualBlockFillView: View {
    let entry: TimelineEntry
    let date: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(AuditStore.self) private var store

    var body: some View {
        NavigationStack {
            List {
                ForEach(entry.startSlot..<entry.endSlot, id: \.self) { slot in
                    Menu {
                        ForEach(store.categories) { category in
                            Button(category.name) { store.setBlock(categoryID: category.id, subcategoryID: nil, forSlot: slot, on: date) }
                        }
                    } label: {
                        HStack {
                            Text(String(format: "%d:%02d", slot / 4, (slot % 4) * 15))
                            Spacer()
                            Text(store.category(withID: store.block(on: date, slot: slot)?.categoryID)?.name ?? "Unassigned")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Fill Block by Block")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}

#Preview {
    ManualBlockFillView(entry: TimelineEntry(startSlot: 32, endSlot: 36, categoryID: nil, subcategoryID: nil), date: .now)
        .environment(AuditStore.preview())
}
