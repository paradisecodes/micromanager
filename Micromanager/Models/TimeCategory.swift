import SwiftUI

struct Subcategory: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

struct TimeCategory: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var colorHex: String
    var subcategories: [Subcategory]
    var isSystemDefault: Bool

    init(id: UUID = UUID(), name: String, colorHex: String, subcategories: [Subcategory] = [], isSystemDefault: Bool = false) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.subcategories = subcategories
        self.isSystemDefault = isSystemDefault
    }

    static let sleep = TimeCategory(name: "Sleep", colorHex: "4A4A68", isSystemDefault: true)
    static let untracked = TimeCategory(name: "Untracked", colorHex: "9B9B9B", isSystemDefault: true)

    static let defaultSet: [TimeCategory] = [
        sleep,
        TimeCategory(
            name: "Work", colorHex: "2E2C6E",
            subcategories: ["Deep work", "Meetings", "Admin", "Travel"].map { Subcategory(name: $0) }
        ),
        TimeCategory(
            name: "Family", colorHex: "C8663F",
            subcategories: ["Meals", "Kids", "Errands"].map { Subcategory(name: $0) }
        ),
        TimeCategory(
            name: "Personal", colorHex: "4F8A7B",
            subcategories: ["Commute", "Reading", "Friends"].map { Subcategory(name: $0) }
        ),
        TimeCategory(
            name: "Health", colorHex: "B08A2E",
            subcategories: ["Exercise", "Appointments", "Rest"].map { Subcategory(name: $0) }
        ),
        untracked,
    ]
}
