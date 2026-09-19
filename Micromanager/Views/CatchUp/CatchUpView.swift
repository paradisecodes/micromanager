import SwiftUI

struct CatchUpView: View {
    let entry: TimelineEntry
    let date: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(AuditStore.self) private var store
    @State private var isPickingManually = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").font(.system(size: 16, weight: .bold)).foregroundStyle(Color.dsIndigo)
                    }
                    Spacer()
                    Text("Catch up").font(.dsSemiBold(15)).foregroundStyle(Color.dsTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 20)
                }
                .padding(.horizontal, 22).padding(.top, 18)

                VStack(alignment: .leading, spacing: 8) {
                    Text(durationTitle)
                        .font(.dsSemiBold(34))
                        .foregroundStyle(Color.dsTextPrimary)
                    Text("\(rangeText). Fill it now and your audit stays complete.")
                        .font(.dsRegular(16))
                        .foregroundStyle(Color.dsTextSecondary)
                }
                .padding(.horizontal, 22).padding(.top, 26)

                VStack(spacing: 11) {
                    Button { applyRepeat() } label: {
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Same as last \(lastWeekdayName)").font(.dsSemiBold(17)).foregroundStyle(.white)
                                Text("Work \u{203A} Deep work, \(rangeText)").font(.dsRegular(14)).foregroundStyle(Color.dsOnIndigoSecondary)
                            }
                            Spacer()
                            Circle().fill(.white.opacity(0.16)).frame(width: 40, height: 40)
                                .overlay(Image(systemName: "checkmark").foregroundStyle(.white).font(.system(size: 14, weight: .bold)))
                        }
                        .padding(17)
                        .background(Color.dsIndigo)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }

                    Button { /* opens VoiceCaptureView in a full flow later */ } label: {
                        catchUpOptionRow(icon: "mic.fill", title: "Describe the afternoon")
                    }
                    Button { isPickingManually = true } label: {
                        catchUpOptionRow(icon: "square.grid.2x2", title: "Fill block by block")
                    }
                }
                .padding(.horizontal, 22).padding(.top, 24)

                VStack(alignment: .leading, spacing: 11) {
                    HStack {
                        Text("Backfill window").font(.dsSemiBold(14)).foregroundStyle(Color.dsIndigo)
                        Spacer()
                        Text("27h left").font(.dsSemiBold(14)).foregroundStyle(Color.dsIndigo)
                    }
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 3).fill(Color.dsTrack)
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3).fill(Color.dsIndigoLight).frame(width: geo.size.width * 0.56)
                            }
                    }
                    .frame(height: 6)
                    Text("Gaps stay editable for 48 hours. After that they're locked so the report reflects what you actually recalled.")
                        .font(.dsRegular(13.5))
                        .foregroundStyle(Color.dsTextSecondary)
                }
                .padding(17)
                .background(Color.dsTint)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 22).padding(.top, 26)

                Spacer()

                VStack(spacing: 10) {
                    Button { markUntracked() } label: {
                        Text("Mark as untracked time")
                            .font(.dsSemiBold(16))
                            .foregroundStyle(Color.dsTextSecondary)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.dsDashedBorder, lineWidth: 1.5))
                    }
                    Text("Skipping lowers report accuracy").font(.dsRegular(13.5)).foregroundStyle(Color.dsTextTertiary)
                }
                .padding(.horizontal, 22).padding(.bottom, 18)
            }
            .background(Color.dsBackground)
            .navigationBarHidden(true)
            .sheet(isPresented: $isPickingManually) {
                ManualBlockFillView(entry: entry, date: date)
            }
        }
    }

    private func catchUpOptionRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).foregroundStyle(Color.dsIndigo)
            Text(title).font(.dsSemiBold(17)).foregroundStyle(Color.dsTextPrimary)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundStyle(Color.dsChevron)
        }
        .padding(17)
        .background(Color.dsCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.dsChrome.opacity(0.05), radius: 1, x: 0, y: 1)
    }

    private func applyRepeat() {
        guard let work = store.categories.first(where: { $0.name == "Work" }) else { return dismiss() }
        let deepWork = work.subcategories.first { $0.name == "Deep work" }
        for slot in entry.startSlot..<entry.endSlot {
            store.setBlock(categoryID: work.id, subcategoryID: deepWork?.id, forSlot: slot, on: date)
        }
        dismiss()
    }

    private func markUntracked() {
        let untracked = store.categories.first { $0.isSystemDefault && $0.name == "Untracked" }
        for slot in entry.startSlot..<entry.endSlot {
            store.setBlock(categoryID: untracked?.id, subcategoryID: nil, forSlot: slot, on: date)
        }
        dismiss()
    }

    private var durationTitle: String {
        let minutes = entry.durationMinutes
        let h = minutes / 60, m = minutes % 60
        return m == 0 ? "\(h) hour\(h == 1 ? "" : "s") open" : "\(h)h \(m)m open"
    }

    private var rangeText: String {
        func label(_ slot: Int) -> String { String(format: "%d:%02d", slot / 4, (slot % 4) * 15) }
        return "\(label(entry.startSlot)) – \(label(entry.endSlot))"
    }

    private var lastWeekdayName: String {
        Calendar.current.date(byAdding: .day, value: -7, to: date)?.formatted(.dateTime.weekday(.wide)) ?? "week"
    }
}

/// Simple per-slot manual assignment, reused by the catch-up flow's "Fill block by block" option.
private struct ManualBlockFillView: View {
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
    CatchUpView(entry: TimelineEntry(startSlot: 32, endSlot: 36, categoryID: nil, subcategoryID: nil), date: .now)
        .environment(AuditStore.preview())
}
