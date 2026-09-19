import SwiftUI

/// Once-per-day mood/energy follow-up about the previous day.
struct CheckInView: View {
    @Environment(AuditStore.self) private var store
    @State private var mood: Int = 3
    @State private var energy: Int = 3

    var body: some View {
        NavigationStack {
            Form {
                Section("How was yesterday?") {
                    Stepper("Mood: \(mood)", value: $mood, in: DailyCheckIn.ratingRange)
                    Stepper("Energy: \(energy)", value: $energy, in: DailyCheckIn.ratingRange)
                }
                Button("Save Check-In") {
                    store.recordCheckIn(mood: mood, energy: energy)
                }
            }
            .navigationTitle("Daily Check-In")
        }
    }
}

#Preview {
    CheckInView()
        .environment(AuditStore())
}
