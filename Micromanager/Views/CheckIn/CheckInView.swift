import SwiftUI

/// Once-per-day mood/energy follow-up about the previous day.
struct CheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuditStore.self) private var store
    @State private var mood: Int = 3
    @State private var energy: Double = 0.4
    @State private var note: String = ""

    private let energyLabels: [(range: ClosedRange<Double>, label: String)] = [
        (0...0.2, "Drained"), (0.2...0.4, "Low-ish"), (0.4...0.6, "Steady"), (0.6...0.8, "Good"), (0.8...1.0, "Wired"),
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button("Skip") { dismiss() }.font(.dsMedium(16)).foregroundStyle(Color.dsTextTertiary)
                    Spacer()
                    Text(yesterday.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())).font(.dsSemiBold(15)).foregroundStyle(Color.dsTextPrimary)
                    Spacer()
                    Button("Done") { save() }.font(.dsSemiBold(16)).foregroundStyle(Color.dsIndigo)
                }
                .padding(.horizontal, 22).padding(.top, 18)

                VStack(alignment: .leading, spacing: 6) {
                    Text("YESTERDAY").font(.dsSemiBold(13)).tracking(0.8).foregroundStyle(Color.dsTextTertiary)
                    Text("How did the day feel?").font(.dsSemiBold(30)).foregroundStyle(Color.dsTextPrimary)
                }
                .padding(.horizontal, 22).padding(.top, 28)

                ScrollView {
                    VStack(spacing: 12) {
                        moodCard
                        energyCard
                        noteCard
                    }
                    .padding(.horizontal, 22).padding(.top, 26)
                }

                VStack(spacing: 10) {
                    Button { save() } label: { DSPrimaryButton(title: "Save check-in") }
                    Text("Takes about 15 seconds \u{00B7} \(ordinal(store.checkIns.count + 1)) of 14")
                        .font(.dsRegular(13.5)).foregroundStyle(Color.dsTextTertiary)
                }
                .padding(.horizontal, 22).padding(.bottom, 18)
            }
            .background(Color.dsBackground)
            .navigationBarHidden(true)
        }
    }

    private var moodCard: some View {
        DSCard(padding: 20) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Mood").font(.dsSemiBold(15)).foregroundStyle(Color.dsTextPrimary)
                HStack {
                    ForEach(DailyCheckIn.ratingRange, id: \.self) { value in
                        let selected = value == mood
                        Text("\(value)")
                            .font(.dsSemiBold(selected ? 19 : 17))
                            .foregroundStyle(selected ? .white : Color(hex: "A8A5BC"))
                            .frame(width: selected ? 56 : 50, height: selected ? 56 : 50)
                            .background(selected ? Color.dsIndigo : Color.dsTintAlt)
                            .clipShape(Circle())
                            .onTapGesture { withAnimation(.snappy) { mood = value } }
                    }
                }
                HStack {
                    Text("Rough").font(.dsMedium(13)).foregroundStyle(Color.dsTextTertiary)
                    Spacer()
                    Text("Good day").font(.dsMedium(13)).foregroundStyle(Color.dsTextTertiary)
                }
            }
        }
    }

    private var energyCard: some View {
        DSCard(padding: 20) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Energy").font(.dsSemiBold(15)).foregroundStyle(Color.dsTextPrimary)
                    Spacer()
                    Text(energyLabel).font(.dsSemiBold(15)).foregroundStyle(Color.dsIndigo)
                }
                Slider(value: $energy).tint(Color.dsIndigo)
                HStack {
                    Text("Drained").font(.dsMedium(13)).foregroundStyle(Color.dsTextTertiary)
                    Spacer()
                    Text("Wired").font(.dsMedium(13)).foregroundStyle(Color.dsTextTertiary)
                }
            }
        }
    }

    private var noteCard: some View {
        DSCard(padding: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Note").font(.dsSemiBold(15)).foregroundStyle(Color.dsTextPrimary)
                    Spacer()
                    Text("Optional").font(.dsMedium(13)).foregroundStyle(Color.dsTextTertiary)
                }
                TextField("Anything worth remembering about yesterday\u{2026}", text: $note, axis: .vertical)
                    .font(.dsRegular(16))
                    .lineLimit(2...4)
                HStack {
                    HStack(spacing: 7) {
                        Image(systemName: "mic.fill")
                        Text("Dictate")
                    }
                    .font(.dsSemiBold(14))
                    .foregroundStyle(Color.dsIndigo)
                    .padding(.horizontal, 15).frame(height: 40)
                    .background(Color.dsTint)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private var energyLabel: String {
        energyLabels.first { $0.range.contains(energy) }?.label ?? "Steady"
    }

    private var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now
    }

    private func ordinal(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }

    private func save() {
        store.recordCheckIn(mood: mood, energy: Int((energy * 4).rounded()) + 1)
        dismiss()
    }
}

#Preview {
    CheckInView()
        .environment(AuditStore.preview())
}
