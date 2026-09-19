import Foundation

/// A single two-week capture window.
struct Audit: Identifiable, Codable, Equatable {
    let id: UUID
    var startDate: Date
    var endDate: Date
    var status: Status

    enum Status: String, Codable {
        case inProgress
        case completed
    }

    init(id: UUID = UUID(), startDate: Date, status: Status = .inProgress) {
        self.id = id
        self.startDate = startDate
        self.endDate = Calendar.current.date(byAdding: .day, value: 14, to: startDate) ?? startDate
        self.status = status
    }
}
