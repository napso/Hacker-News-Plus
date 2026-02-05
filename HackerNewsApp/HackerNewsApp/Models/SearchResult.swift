import Foundation

struct AlgoliaSearchResponse: Codable {
    let hits: [AlgoliaHit]
    let nbHits: Int
    let page: Int
    let nbPages: Int
    let hitsPerPage: Int
}

struct AlgoliaHit: Codable, Identifiable {
    let objectID: String
    let title: String?
    let url: String?
    let author: String?
    let points: Int?
    let storyText: String?
    let commentText: String?
    let numComments: Int?
    let createdAt: String?
    let createdAtI: Int?
    let storyId: Int?

    var id: String { objectID }

    enum CodingKeys: String, CodingKey {
        case objectID
        case title
        case url
        case author
        case points
        case storyText = "story_text"
        case commentText = "comment_text"
        case numComments = "num_comments"
        case createdAt = "created_at"
        case createdAtI = "created_at_i"
        case storyId = "story_id"
    }

    var displayTitle: String {
        title ?? "[No Title]"
    }

    var displayAuthor: String {
        author ?? "unknown"
    }

    var displayScore: Int {
        points ?? 0
    }

    var commentCount: Int {
        numComments ?? 0
    }

    var timeAgo: String {
        guard let time = createdAtI else { return "" }
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var hostName: String? {
        guard let urlString = url, let url = URL(string: urlString) else { return nil }
        return url.host?.replacingOccurrences(of: "www.", with: "")
    }

    var itemId: Int {
        if let idString = objectID.components(separatedBy: "_").last,
           let id = Int(idString) {
            return id
        }
        return Int(objectID) ?? 0
    }

    func toStory() -> Story {
        Story(
            id: itemId,
            title: title,
            url: url,
            text: storyText,
            by: author,
            time: createdAtI,
            score: points,
            descendants: numComments,
            kids: nil,
            type: "story",
            deleted: nil,
            dead: nil
        )
    }
}

enum SearchSortOption: String, CaseIterable, Identifiable {
    case relevance = "Relevance"
    case date = "Date"
    case points = "Points"

    var id: String { rawValue }

    var algoliaParam: String {
        switch self {
        case .relevance: return "search"
        case .date: return "search_by_date"
        case .points: return "search"
        }
    }
}

enum SearchTimeFilter: String, CaseIterable, Identifiable {
    case allTime = "All Time"
    case pastDay = "Past 24h"
    case pastWeek = "Past Week"
    case pastMonth = "Past Month"
    case pastYear = "Past Year"

    var id: String { rawValue }

    var timestamp: Int? {
        let now = Int(Date().timeIntervalSince1970)
        switch self {
        case .allTime: return nil
        case .pastDay: return now - 86400
        case .pastWeek: return now - 604800
        case .pastMonth: return now - 2592000
        case .pastYear: return now - 31536000
        }
    }
}
