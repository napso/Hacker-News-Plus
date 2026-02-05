import Foundation

struct User: Codable, Identifiable {
    let id: String
    let created: Int?
    let karma: Int?
    let about: String?
    let submitted: [Int]?

    var displayKarma: String {
        guard let karma = karma else { return "0" }
        if karma >= 1000 {
            return String(format: "%.1fk", Double(karma) / 1000)
        }
        return "\(karma)"
    }

    var memberSince: String {
        guard let created = created else { return "Unknown" }
        let date = Date(timeIntervalSince1970: TimeInterval(created))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var aboutText: String {
        about ?? "No description available."
    }

    var submissionCount: Int {
        submitted?.count ?? 0
    }
}
