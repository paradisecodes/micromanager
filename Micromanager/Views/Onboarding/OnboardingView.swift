import SwiftUI

struct OnboardingView: View {
    @Environment(AuditStore.self) private var store
    @State private var startDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2).fill(Color.dsIndigo).frame(height: 4)
                RoundedRectangle(cornerRadius: 2).fill(Color.dsIndigo).frame(height: 4)
                RoundedRectangle(cornerRadius: 2).fill(Color.dsTrack).frame(height: 4)
            }
            .padding(.horizontal, 22).padding(.top, 18)

            VStack(alignment: .leading, spacing: 10) {
                Text("Two weeks, in 15-minute blocks")
                    .font(.dsSemiBold(34))
                    .foregroundStyle(Color.dsTextPrimary)
                Text("One prompt an hour covering the last four blocks, and one question each morning about the day before.")
                    .font(.dsRegular(16.5))
                    .foregroundStyle(Color.dsTextSecondary)
            }
            .padding(.horizontal, 22).padding(.top, 30)

            VStack(spacing: 2) {
                settingRow(title: "Starts", value: startDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()), topRadius: 22, bottomRadius: 4)
                settingRow(title: "Prompt hours", value: "7:00 AM \u{2013} 11:00 PM", topRadius: 4, bottomRadius: 4)
                settingRow(title: "Usual sleep", value: "11:30 PM \u{2013} 6:30 AM", topRadius: 4, bottomRadius: 22, badge: "Auto-filled")
            }
            .padding(.horizontal, 22).padding(.top, 26)

            HStack(alignment: .top, spacing: 13) {
                Image(systemName: "bell.badge").foregroundStyle(Color.dsIndigo)
                Text("Notifications are how the audit works. Without the hourly prompt there's nothing to capture.")
                    .font(.dsRegular(15))
                    .foregroundStyle(Color(hex: "3E3B5C"))
            }
            .padding(17)
            .background(Color.dsTint)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 22).padding(.top, 24)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    store.startAudit(on: startDate)
                } label: {
                    DSPrimaryButton(title: "Allow notifications & start")
                }
                Text("Review my categories first")
                    .font(.dsSemiBold(15.5))
                    .foregroundStyle(Color.dsIndigo)
            }
            .padding(.horizontal, 22).padding(.bottom, 18)
        }
        .background(Color.dsBackground)
    }

    private func settingRow(title: String, value: String, topRadius: CGFloat, bottomRadius: CGFloat, badge: String? = nil) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.dsMedium(13.5)).foregroundStyle(Color.dsTextTertiary)
                Text(value).font(.dsSemiBold(17)).foregroundStyle(Color.dsTextPrimary)
            }
            Spacer()
            if let badge {
                Text(badge)
                    .font(.dsSemiBold(12.5))
                    .foregroundStyle(Color.dsIndigo)
                    .padding(.horizontal, 9).padding(.vertical, 5)
                    .background(Color.dsTint)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundStyle(Color.dsChevron)
            }
        }
        .padding(16)
        .background(Color.dsCard)
        .clipShape(.rect(topLeadingRadius: topRadius, bottomLeadingRadius: bottomRadius, bottomTrailingRadius: bottomRadius, topTrailingRadius: topRadius))
        .shadow(color: Color.dsChrome.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    OnboardingView()
        .environment(AuditStore())
}
