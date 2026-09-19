import SwiftUI

struct CategoriesView: View {
    @Environment(AuditStore.self) private var store
    @State private var expandedCategoryID: UUID?
    @State private var isAddingCategory = false
    @State private var newCategoryName = ""

    private var userCategories: [TimeCategory] { store.categories.filter { !$0.isSystemDefault } }
    private var subcategoryCount: Int { userCategories.reduce(0) { $0 + $1.subcategories.count } }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(userCategories.count) CATEGORIES \u{00B7} \(subcategoryCount) SUBCATEGORIES")
                            .font(.dsSemiBold(13)).tracking(0.6)
                            .foregroundStyle(Color.dsTextTertiary)
                        Text("Categories").font(.dsSemiBold(30)).foregroundStyle(Color.dsTextPrimary)
                    }
                    Spacer()
                    Text("Edit").font(.dsSemiBold(16)).foregroundStyle(Color.dsIndigo).padding(.top, 14)
                }
                .padding(.horizontal, 22).padding(.top, 14)

                ScrollView {
                    VStack(spacing: 11) {
                        ForEach(userCategories) { category in
                            categoryCard(category)
                        }

                        Button { isAddingCategory = true } label: {
                            Text("+ New category")
                                .font(.dsSemiBold(16))
                                .foregroundStyle(Color.dsIndigo)
                                .frame(maxWidth: .infinity).frame(height: 52)
                                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.dsDashedBorder, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])))
                        }

                        Text("Sleep and Untracked are built in and can't be removed. Renaming a category updates past entries too.")
                            .font(.dsRegular(13.5))
                            .foregroundStyle(Color.dsTextTertiary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 22).padding(.top, 20).padding(.bottom, 24)
                }
            }
            .background(Color.dsBackground)
            .navigationBarHidden(true)
            .alert("New Category", isPresented: $isAddingCategory) {
                TextField("Name", text: $newCategoryName)
                Button("Add") {
                    guard !newCategoryName.isEmpty else { return }
                    store.categories.insert(TimeCategory(name: newCategoryName, colorHex: "808080"), at: store.categories.count - 1)
                    newCategoryName = ""
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func categoryCard(_ category: TimeCategory) -> some View {
        let isExpanded = expandedCategoryID == category.id
        return VStack(spacing: 0) {
            Button {
                withAnimation(.snappy) { expandedCategoryID = isExpanded ? nil : category.id }
            } label: {
                HStack(spacing: 11) {
                    Circle().fill(Color(hex: category.colorHex)).frame(width: 10, height: 10)
                    if isExpanded {
                        Text(category.name).font(.dsSemiBold(18)).foregroundStyle(Color.dsTextPrimary)
                    } else {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(category.name).font(.dsSemiBold(18)).foregroundStyle(Color.dsTextPrimary)
                            Text(subcategoryPreview(category)).font(.dsRegular(13)).foregroundStyle(Color.dsTextTertiary)
                        }
                    }
                    Spacer()
                    Text(hoursLabel(category)).font(.dsMedium(14)).foregroundStyle(Color.dsTextTertiary)
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.dsChevron)
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            if isExpanded {
                FlowLayout(spacing: 8) {
                    ForEach(category.subcategories) { sub in
                        Text(sub.name)
                            .font(.dsMedium(14.5))
                            .foregroundStyle(Color.dsTextPrimary)
                            .padding(.horizontal, 13).frame(height: 34)
                            .background(Color.dsTintAlt)
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                    }
                    Text("+ Add")
                        .font(.dsSemiBold(14.5))
                        .foregroundStyle(Color.dsIndigo)
                        .padding(.horizontal, 13).frame(height: 34)
                        .overlay(RoundedRectangle(cornerRadius: 11).strokeBorder(Color.dsDashedBorder, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])))
                }
                .padding(.horizontal, 16).padding(.bottom, 16)
            }
        }
        .background(Color.dsCard)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.dsChrome.opacity(0.05), radius: 1, x: 0, y: 1)
    }

    private func subcategoryPreview(_ category: TimeCategory) -> String {
        let names = category.subcategories.map(\.name)
        guard names.count > 3 else { return names.joined(separator: " \u{00B7} ") }
        return names.prefix(3).joined(separator: " \u{00B7} ") + " \u{00B7} +\(names.count - 3)"
    }

    private func hoursLabel(_ category: TimeCategory) -> String {
        let minutes = store.categoryTotals().first { $0.category.id == category.id }?.minutes ?? 0
        guard minutes > 0 else { return "" }
        let h = minutes / 60, m = minutes % 60
        if h == 0 { return "\(m)m" }
        return m == 0 ? "\(h)h" : "\(h)h \(m)m"
    }
}

/// Minimal wrapping layout for subcategory chips.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX, y: CGFloat = bounds.minY, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    CategoriesView()
        .environment(AuditStore.preview())
}
