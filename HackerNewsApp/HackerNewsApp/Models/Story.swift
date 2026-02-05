import Foundation

struct Story: Codable, Identifiable, Equatable {
    let id: Int
    let title: String?
    let url: String?
    let text: String?
    let by: String?
    let time: Int?
    let score: Int?
    let descendants: Int?
    let kids: [Int]?
    let type: String?
    let deleted: Bool?
    let dead: Bool?

    var displayTitle: String {
        title ?? "[Deleted]"
    }

    var displayAuthor: String {
        by ?? "unknown"
    }

    var displayScore: Int {
        score ?? 0
    }

    var commentCount: Int {
        descendants ?? 0
    }

    var timeAgo: String {
        guard let time = time else { return "" }
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var hostName: String? {
        guard let urlString = url, let url = URL(string: urlString) else { return nil }
        return url.host?.replacingOccurrences(of: "www.", with: "")
    }

    var storyURL: URL? {
        guard let urlString = url else { return nil }
        return URL(string: urlString)
    }

    var hackerNewsURL: URL {
        URL(string: "https://news.ycombinator.com/item?id=\(id)")!
    }

    static func == (lhs: Story, rhs: Story) -> Bool {
        lhs.id == rhs.id
    }
}

enum StoryType: String, CaseIterable, Identifiable {
    case top = "Top"
    case best = "Best"
    case new = "New"
    case ask = "Ask HN"
    case show = "Show HN"
    case jobs = "Jobs"

    var id: String { rawValue }

    var endpoint: String {
        switch self {
        case .top: return "topstories"
        case .best: return "beststories"
        case .new: return "newstories"
        case .ask: return "askstories"
        case .show: return "showstories"
        case .jobs: return "jobstories"
        }
    }

    var icon: String {
        switch self {
        case .top: return "flame.fill"
        case .best: return "star.fill"
        case .new: return "clock.fill"
        case .ask: return "questionmark.circle.fill"
        case .show: return "eye.fill"
        case .jobs: return "briefcase.fill"
        }
    }

    var color: String {
        switch self {
        case .top: return "AccentOrange"
        case .best: return "AccentYellow"
        case .new: return "AccentGreen"
        case .ask: return "AccentBlue"
        case .show: return "AccentPurple"
        case .jobs: return "AccentTeal"
        }
    }
}
