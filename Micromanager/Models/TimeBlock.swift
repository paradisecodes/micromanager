import Foundation

/// A single 15-minute slot within a day. 96 of these make up a full day.
struct TimeBlock: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    /// Index 0...95, where 0 = 00:00-00:15.
    var slotIndex: Int
    var categoryID: UUID?

    init(id: UUID = UUID(), date: Date, slotIndex: Int, categoryID: UUID? = nil) {
        self.id = id
        self.date = date
        self.slotIndex = slotIndex
        self.categoryID = categoryID
    }

    var startTime: DateComponents {
        DateComponents(hour: slotIndex / 4, minute: (slotIndex % 4) * 15)
    }

    static let blocksPerDay = 96
    static let blocksPerHour = 4
}
