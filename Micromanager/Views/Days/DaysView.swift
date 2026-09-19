import SwiftUI

/// Browse prior days of the current audit. Not detailed in the hi-fi mockups —
/// kept minimal until that screen is designed.
struct DaysView: View {
    @Environment(AuditStore.self) private var store

    private var days: [Date] {
        guard let audit = store.currentAudit else { return [] }
        let totalDays = Calendar.current.dateComponents([.day], from: audit.startDate, to: audit.endDate).day ?? 14
        return (0..<totalDays).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: audit.startDate) }
    }

    var body: some View {
        NavigationStack {
            List(days, id: \.self) { day in
                HStack {
                    Text(day.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                        .font(.dsMedium(16))
                        .foregroundStyle(Color.dsTextPrimary)
                    Spacer()
                    if Calendar.current.isDateInToday(day) {
                        Text("Today").font(.dsSemiBold(13)).foregroundStyle(Color.dsIndigo)
                    }
                }
                .listRowBackground(Color.dsCard)
            }
            .scrollContentBackground(.hidden)
            .background(Color.dsBackground)
            .navigationTitle("Days")
        }
    }
}

#Preview {
    DaysView()
        .environment(AuditStore.preview())
}
