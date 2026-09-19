import Foundation

/// Once-per-day qualitative follow-up about the previous day.
struct DailyCheckIn: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var mood: Int
    var energy: Int

    init(id: UUID = UUID(), date: Date, mood: Int, energy: Int) {
        self.id = id
        self.date = date
        self.mood = mood
        self.energy = energy
    }

    static let ratingRange = 1...5
}
