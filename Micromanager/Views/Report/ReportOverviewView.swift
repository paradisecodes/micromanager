import SwiftUI

struct ReportOverviewView: View {
    @Environment(AuditStore.self) private var store

    private var totals: [AuditStore.CategoryTotal] { store.categoryTotals() }
    private var totalMinutes: Int { totals.reduce(0) { $0 + $1.minutes } }
    private var auditHours: Int {
        guard let audit = store.currentAudit else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: audit.startDate, to: audit.endDate).day ?? 14
        return days * 24
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    if totals.contains(where: { $0.minutes > 0 }) {
                        whereItWentCard
                        moodEnergyCard
                        timeLeaksCard
                    } else {
                        emptyState
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color.dsBackground)
            .navigationBarHidden(true)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(dateRangeText).font(.dsSemiBold(13)).tracking(0.6).foregroundStyle(Color.dsTextTertiary)
                Text("Your audit").font(.dsSemiBold(30)).foregroundStyle(Color.dsTextPrimary)
            }
            Spacer()
            HStack(spacing: 7) {
                Image(systemName: "square.and.arrow.up")
                Text("Share")
            }
            .font(.dsSemiBold(14))
            .foregroundStyle(Color.dsIndigo)
            .padding(.horizontal, 14).frame(height: 36)
            .background(Color.dsTint)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.horizontal, 22).padding(.top, 14).padding(.bottom, 20)
    }

    private var whereItWentCard: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .lastTextBaseline) {
                    Text("Where it went").font(.dsSemiBold(17)).foregroundStyle(Color.dsTextPrimary)
                    Spacer()
                    Text("\(auditHours) hours").font(.dsMedium(13)).foregroundStyle(Color.dsTextTertiary)
                }
                GeometryReader { geo in
                    let unit = max(totalMinutes, auditHours * 60, 1)
                    HStack(spacing: 2) {
                        ForEach(totals) { total in
                            Color(hex: total.category.colorHex)
                                .frame(width: geo.size.width * CGFloat(total.minutes) / CGFloat(unit))
                        }
                        Color.dsTrack
                    }
                }
                .frame(height: 12)
                .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(spacing: 11) {
                    ForEach(totals) { total in
                        NavigationLink {
                            CategoryDrilldownView(category: total.category)
                        } label: {
                            HStack(spacing: 11) {
                                Circle().fill(Color(hex: total.category.colorHex)).frame(width: 9, height: 9)
                                Text(total.category.name).font(.dsSemiBold(16)).foregroundStyle(Color.dsTextPrimary)
                                Spacer()
                                Text(hoursLabel(total.minutes)).font(.dsMedium(15)).foregroundStyle(Color.dsTextSecondary)
                                Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundStyle(Color.dsChevron)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 22)
    }

    /// Mock content — the AI analysis engine that correlates mood/energy with
    /// time use is not built yet (see PRD open questions). Real numbers once it is.
    private var moodEnergyCard: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 13) {
                Text("Mood & energy").font(.dsSemiBold(17)).foregroundStyle(Color.dsTextPrimary)
                HStack(alignment: .bottom, spacing: 7) {
                    ForEach([0.4, 0.62, 0.3, 0.82, 0.55, 0.44, 0.96], id: \.self) { h in
                        RoundedRectangle(cornerRadius: 5)
                            .fill(h > 0.75 ? Color.dsIndigo : Color.dsTrack)
                            .frame(height: 78 * h)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 78, alignment: .bottom)
                (Text("Your two best-rated days averaged ")
                    .foregroundStyle(Color.dsTextSecondary)
                 + Text("3h 20m of deep work").foregroundStyle(Color.dsTextPrimary).fontWeight(.semibold)
                 + Text(" and under an hour of meetings.").foregroundStyle(Color.dsTextSecondary))
                    .font(.dsRegular(14.5))
            }
        }
        .padding(.horizontal, 22).padding(.top, 12)
    }

    /// Mock content — see note on `moodEnergyCard`.
    private var timeLeaksCard: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 13) {
                Text("Biggest time leaks").font(.dsSemiBold(17)).foregroundStyle(Color.dsTextPrimary)
                leakRow(rank: 1, title: "Fragmented admin", value: "9h 45m")
                leakRow(rank: 2, title: "Recurring 4pm meeting", value: "7h")
            }
        }
        .padding(.horizontal, 22).padding(.top, 12)
    }

    private func leakRow(rank: Int, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.dsSemiBold(14))
                .foregroundStyle(Color.dsIndigo)
                .frame(width: 30, height: 30)
                .background(Color.dsTint)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text(title).font(.dsMedium(16)).foregroundStyle(Color.dsTextPrimary)
            Spacer()
            Text(value).font(.dsSemiBold(15)).foregroundStyle(Color.dsTextPrimary)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Data Yet",
            systemImage: "chart.bar.doc.horizontal",
            description: Text("Log a few blocks and your report will start filling in here.")
        )
        .padding(.top, 60)
    }

    private var dateRangeText: String {
        guard let audit = store.currentAudit else { return "No audit yet" }
        let formatter = Date.FormatStyle().month(.abbreviated).day()
        return "\(audit.startDate.formatted(formatter)) \u{2013} \(audit.endDate.formatted(formatter))"
    }

    private func hoursLabel(_ minutes: Int) -> String {
        let h = minutes / 60, m = minutes % 60
        return m == 0 ? "\(h)h" : "\(h)h \(m)m"
    }
}

#Preview {
    ReportOverviewView()
        .environment(AuditStore.preview())
}
