import SwiftUI

struct TimeCategory: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var colorHex: String
    var isSystemDefault: Bool

    init(id: UUID = UUID(), name: String, colorHex: String, isSystemDefault: Bool = false) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.isSystemDefault = isSystemDefault
    }

    static let sleep = TimeCategory(name: "Sleep", colorHex: "#4A4A68", isSystemDefault: true)
    static let skipped = TimeCategory(name: "Skipped", colorHex: "#9B9B9B", isSystemDefault: true)

    static let defaultSet: [TimeCategory] = [
        sleep,
        TimeCategory(name: "Work", colorHex: "#3D3B8E", isSystemDefault: true),
        TimeCategory(name: "Exercise", colorHex: "#2E8B57", isSystemDefault: true),
        TimeCategory(name: "Family", colorHex: "#D96C6C", isSystemDefault: true),
        TimeCategory(name: "Chores", colorHex: "#B08968", isSystemDefault: true),
        TimeCategory(name: "Leisure", colorHex: "#4C9AA8", isSystemDefault: true),
        TimeCategory(name: "Commute", colorHex: "#8A7CA8", isSystemDefault: true),
        skipped,
    ]
}
