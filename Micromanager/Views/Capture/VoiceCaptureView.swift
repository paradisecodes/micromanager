import SwiftUI

/// Voice-first capture sheet. Recording UI and drafted-block review match the
/// hi-fi mockup; actual on-device speech-to-text (Apple's Speech framework,
/// per the PRD) and NLP parsing into blocks are not wired up yet — the
/// transcript and drafted rows below are static placeholders.
struct VoiceCaptureView: View {
    let referenceDate: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(AuditStore.self) private var store
    @State private var isListening = true

    private var draftedRows: [(time: String, subcategory: String, category: String, needsCheck: Bool)] {
        [
            ("9:00", "Admin", "Work", false),
            ("9:15", "Meetings", "Work", false),
            ("9:30", "Commute", "Personal", true),
            ("9:45", "Commute", "Personal", false),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") { dismiss() }
                    .font(.dsMedium(16))
                    .foregroundStyle(Color.dsOnIndigoTertiary)
                Spacer()
                Text(hourRangeText).font(.dsSemiBold(15)).foregroundStyle(.white)
                Spacer()
                Button("Save") { dismiss() }
                    .font(.dsSemiBold(16))
                    .foregroundStyle(.white.opacity(0.35))
                    .disabled(true)
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)

            VStack(spacing: 14) {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(waveformHeights, id: \.self) { h in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(h > 40 ? Color.dsMint : Color.dsIndigoPale)
                            .frame(width: 4, height: h)
                    }
                }
                .frame(height: 48)

                Button {
                    isListening.toggle()
                } label: {
                    Circle()
                        .fill(.white)
                        .frame(width: 92, height: 92)
                        .overlay(Circle().stroke(.white.opacity(0.12), lineWidth: 10).padding(-10))
                        .overlay(Image(systemName: "mic.fill").font(.system(size: 30)).foregroundStyle(Color.dsIndigo))
                }
                Text(isListening ? "Listening — tap to stop" : "Tap to start listening")
                    .font(.dsMedium(15))
                    .foregroundStyle(Color.dsOnIndigoSecondary)
            }
            .padding(.top, 18)

            Text("\u{201C}Email and standup till about half nine, then drove to the office.\u{201D}")
                .font(.dsRegular(17))
                .foregroundStyle(.white)
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal, 22)
                .padding(.top, 18)

            draftSheet
        }
        .background(Color.dsIndigo)
    }

    private var draftSheet: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .lastTextBaseline) {
                Text("\(draftedRows.count) BLOCKS DRAFTED")
                    .font(.dsSemiBold(13)).tracking(0.8)
                    .foregroundStyle(Color.dsTextTertiary)
                Spacer()
                Text("Edit all").font(.dsSemiBold(14)).foregroundStyle(Color.dsIndigo)
            }

            ForEach(Array(draftedRows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 12) {
                    Text(row.time).font(.dsSemiBold(13)).foregroundStyle(Color.dsTextTertiary).frame(width: 42, alignment: .leading)
                    RoundedRectangle(cornerRadius: 2).fill(Color.dsIndigo).frame(width: 4, height: 24)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(row.subcategory).font(.dsSemiBold(16)).foregroundStyle(Color.dsTextPrimary)
                        Text(row.category).font(.dsRegular(13)).foregroundStyle(Color.dsTextTertiary)
                    }
                    Spacer()
                    if row.needsCheck {
                        Text("Check")
                            .font(.dsSemiBold(12))
                            .foregroundStyle(Color.dsIndigo)
                            .padding(.horizontal, 9).padding(.vertical, 5)
                            .background(Color.dsTint)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundStyle(Color.dsChevron)
                    }
                }
                .padding(13)
                .background(Color.dsCard)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(row.needsCheck ? Color.dsIndigo : .clear, lineWidth: 1.5)
                )
            }

            Spacer(minLength: 0)

            VStack(spacing: 10) {
                Button { dismiss() } label: {
                    DSPrimaryButton(title: "Save \(draftedRows.count) blocks")
                }
                Button("Enter manually instead") { dismiss() }
                    .font(.dsMedium(15))
                    .foregroundStyle(Color.dsTextSecondary)
            }
            .padding(.bottom, 14)
        }
        .padding(.horizontal, 22)
        .padding(.top, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.dsBackground)
        .clipShape(.rect(topLeadingRadius: 28, topTrailingRadius: 28))
        .padding(.top, 16)
    }

    private var waveformHeights: [CGFloat] {
        [16, 30, 46, 24, 38, 52, 28, 18, 34, 22, 12]
    }

    private var hourRangeText: String {
        let start = Calendar.current.date(byAdding: .hour, value: -1, to: referenceDate) ?? referenceDate
        return "\(start.formatted(.dateTime.hour().minute())) – \(referenceDate.formatted(.dateTime.hour().minute()))"
    }
}

#Preview {
    VoiceCaptureView(referenceDate: .now)
        .environment(AuditStore.preview())
}
