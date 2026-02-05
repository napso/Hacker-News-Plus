import Foundation

struct Comment: Codable, Identifiable {
    let id: Int
    let by: String?
    let text: String?
    let time: Int?
    let kids: [Int]?
    let parent: Int?
    let deleted: Bool?
    let dead: Bool?
    let type: String?

    var displayAuthor: String {
        by ?? "[deleted]"
    }

    var displayText: String {
        text ?? "[deleted]"
    }

    var timeAgo: String {
        guard let time = time else { return "" }
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var isDeleted: Bool {
        deleted == true || dead == true || text == nil
    }

    var childCount: Int {
        kids?.count ?? 0
    }
}

class CommentNode: Identifiable, ObservableObject {
    let id: Int
    let comment: Comment
    var children: [CommentNode]
    let depth: Int
    @Published var isCollapsed: Bool = false

    init(comment: Comment, children: [CommentNode] = [], depth: Int = 0) {
        self.id = comment.id
        self.comment = comment
        self.children = children
        self.depth = depth
    }

    var totalChildCount: Int {
        children.reduce(0) { $0 + 1 + $1.totalChildCount }
    }
}
