import SwiftUI

struct CategoriesView: View {
    @Environment(AuditStore.self) private var store
    @State private var newCategoryName = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(store.categories) { category in
                        HStack {
                            Circle()
                                .fill(Color(hex: category.colorHex))
                                .frame(width: 14, height: 14)
                            Text(category.name)
                        }
                    }
                    .onDelete { offsets in
                        store.categories.remove(atOffsets: offsets)
                    }
                }
                Section("Add Category") {
                    HStack {
                        TextField("Name", text: $newCategoryName)
                        Button("Add") {
                            guard !newCategoryName.isEmpty else { return }
                            store.categories.append(TimeCategory(name: newCategoryName, colorHex: "#808080"))
                            newCategoryName = ""
                        }
                    }
                }
            }
            .navigationTitle("Categories")
            .toolbar { EditButton() }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}

#Preview {
    CategoriesView()
        .environment(AuditStore())
}
