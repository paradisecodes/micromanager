import SwiftUI

struct CategoryDrilldownView: View {
    let category: TimeCategory
    @Environment(\.dismiss) private var dismiss
    @Environment(AuditStore.self) private var store

    private var subtotals: [AuditStore.SubcategoryTotal] { store.subcategoryTotals(for: category) }
    private var totalMinutes: Int { subtotals.reduce(0) { $0 + $1.minutes } }
    private var maxSubMinutes: Int { subtotals.map(\.minutes).max() ?? 1 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                backButton
                titleBlock
                subcategoriesCard
                heatmapCard
                recommendationCard
            }
            .padding(.bottom, 24)
        }
        .background(Color.dsBackground)
        .navigationBarHidden(true)
    }

    private var backButton: some View {
        Button { dismiss() } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left").font(.system(size: 14, weight: .bold))
                Text("Audit").font(.dsMedium(16))
            }
            .foregroundStyle(Color.dsIndigo)
        }
        .padding(.horizontal, 22).padding(.top, 18)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 9) {
                Circle().fill(Color(hex: category.colorHex)).frame(width: 10, height: 10)
                Text(category.name.uppercased()).font(.dsSemiBold(13)).tracking(0.6).foregroundStyle(Color.dsTextTertiary)
            }
            Text(totalLabel).font(.dsSemiBold(38)).foregroundStyle(Color.dsTextPrimary)
            Text(subtitleLabel).font(.dsRegular(15)).foregroundStyle(Color.dsTextSecondary)
        }
        .padding(.horizontal, 22).padding(.top, 22)
    }

    private var subcategoriesCard: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Subcategories").font(.dsSemiBold(17)).foregroundStyle(Color.dsTextPrimary)
                VStack(spacing: 12) {
                    ForEach(subtotals) { sub in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(sub.subcategory.name).font(.dsSemiBold(15)).foregroundStyle(Color.dsTextPrimary)
                                Spacer()
                                Text(hoursLabel(sub.minutes)).font(.dsMedium(15)).foregroundStyle(Color.dsTextSecondary)
                            }
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 4).fill(Color.dsTint)
                                    .overlay(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(hex: category.colorHex))
                                            .frame(width: geo.size.width * CGFloat(sub.minutes) / CGFloat(max(maxSubMinutes, 1)))
                                    }
                            }
                            .frame(height: 8)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 22).padding(.top, 22)
    }

    /// Mock content — see the note on `ReportOverviewView.moodEnergyCard`; the
    /// activity-pattern heatmap needs the same not-yet-built analysis engine.
    private var heatmapCard: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("When it happens").font(.dsSemiBold(17)).foregroundStyle(Color.dsTextPrimary)
                    Spacer()
                    Text("6am \u{2013} 10pm").font(.dsMedium(13)).foregroundStyle(Color.dsTextTertiary)
                }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    ForEach(0..<28, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(heatmapSample[i % heatmapSample.count])
                            .frame(height: 16)
                    }
                }
                HStack {
                    ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                        Text(day).font(.dsMedium(12)).foregroundStyle(Color.dsTextTertiary).frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, 22).padding(.top, 12)
    }

    /// Mock content — real recommendations require the AI analysis engine (PRD open question).
    private var recommendationCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("RECOMMENDATION").font(.dsSemiBold(13)).tracking(0.6).foregroundStyle(Color.dsOnIndigoSecondary)
            (Text("Admin arrived in 19 separate blocks. Batching it into two 45-minute windows would return about ")
                .foregroundStyle(.white)
             + Text("4 hours a week").fontWeight(.semibold).foregroundStyle(.white)
             + Text(".").foregroundStyle(.white))
                .font(.dsRegular(16.5))
        }
        .padding(18)
        .background(Color.dsIndigo)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding(.horizontal, 22).padding(.top, 12)
    }

    private var heatmapSample: [Color] {
        ["EEEDF7", "C9C7E4", "2E2C6E", "6C69C9", "2E2C6E", "C9C7E4", "F1F0F6"].map { Color(hex: $0) }
    }

    private var totalLabel: String {
        let h = totalMinutes / 60, m = totalMinutes % 60
        return m == 0 ? "\(h)h" : "\(h)h \(m)m"
    }

    private var subtitleLabel: String {
        guard let audit = store.currentAudit else { return "" }
        let totalDays = max(Calendar.current.dateComponents([.day], from: audit.startDate, to: audit.endDate).day ?? 14, 1)
        let percent = Int((Double(totalMinutes) / Double(totalDays * 24 * 60) * 100).rounded())
        let perDay = totalMinutes / totalDays / 60
        return "\(percent)% of the two weeks \u{00B7} \(perDay)h a day on average"
    }

    private func hoursLabel(_ minutes: Int) -> String {
        let h = minutes / 60, m = minutes % 60
        return m == 0 ? "\(h)h" : "\(h)h \(m)m"
    }
}

#Preview {
    NavigationStack {
        CategoryDrilldownView(category: TimeCategory.defaultSet[1])
            .environment(AuditStore.preview())
    }
}
