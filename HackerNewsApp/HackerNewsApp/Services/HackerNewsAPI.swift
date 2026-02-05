import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .rateLimited:
            return "Rate limited. Please try again later."
        }
    }
}

actor HackerNewsAPI {
    static let shared = HackerNewsAPI()

    private let baseURL = "https://hacker-news.firebaseio.com/v0"
    private let algoliaBaseURL = "https://hn.algolia.com/api/v1"
    private let session: URLSession
    private var cache: [String: (data: Any, timestamp: Date)] = [:]
    private let cacheTimeout: TimeInterval = 300 // 5 minutes

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }

    // MARK: - Story Fetching

    func fetchStoryIds(for type: StoryType) async throws -> [Int] {
        let cacheKey = "storyIds_\(type.endpoint)"

        if let cached = cache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheTimeout,
           let ids = cached.data as? [Int] {
            return ids
        }

        let url = URL(string: "\(baseURL)/\(type.endpoint).json")!
        let (data, _) = try await session.data(from: url)
        let ids = try JSONDecoder().decode([Int].self, from: data)

        cache[cacheKey] = (ids, Date())
        return ids
    }

    func fetchStory(id: Int) async throws -> Story {
        let cacheKey = "story_\(id)"

        if let cached = cache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheTimeout,
           let story = cached.data as? Story {
            return story
        }

        let url = URL(string: "\(baseURL)/item/\(id).json")!
        let (data, _) = try await session.data(from: url)
        let story = try JSONDecoder().decode(Story.self, from: data)

        cache[cacheKey] = (story, Date())
        return story
    }

    func fetchStories(ids: [Int], limit: Int = 30) async throws -> [Story] {
        let limitedIds = Array(ids.prefix(limit))

        return await withTaskGroup(of: Story?.self) { group in
            for id in limitedIds {
                group.addTask {
                    try? await self.fetchStory(id: id)
                }
            }

            var stories: [Story] = []
            for await story in group {
                if let story = story {
                    stories.append(story)
                }
            }

            // Sort by original order
            return stories.sorted { story1, story2 in
                guard let index1 = limitedIds.firstIndex(of: story1.id),
                      let index2 = limitedIds.firstIndex(of: story2.id) else {
                    return false
                }
                return index1 < index2
            }
        }
    }

    // MARK: - Comment Fetching

    func fetchComment(id: Int) async throws -> Comment {
        let cacheKey = "comment_\(id)"

        if let cached = cache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheTimeout,
           let comment = cached.data as? Comment {
            return comment
        }

        let url = URL(string: "\(baseURL)/item/\(id).json")!
        let (data, _) = try await session.data(from: url)
        let comment = try JSONDecoder().decode(Comment.self, from: data)

        cache[cacheKey] = (comment, Date())
        return comment
    }

    func fetchCommentTree(ids: [Int], depth: Int = 0, maxDepth: Int = 10) async throws -> [CommentNode] {
        guard depth < maxDepth else { return [] }

        return await withTaskGroup(of: CommentNode?.self) { group in
            for id in ids {
                group.addTask {
                    guard let comment = try? await self.fetchComment(id: id) else { return nil }

                    var children: [CommentNode] = []
                    if let kidIds = comment.kids, !kidIds.isEmpty {
                        children = (try? await self.fetchCommentTree(
                            ids: kidIds,
                            depth: depth + 1,
                            maxDepth: maxDepth
                        )) ?? []
                    }

                    return CommentNode(comment: comment, children: children, depth: depth)
                }
            }

            var nodes: [CommentNode] = []
            for await node in group {
                if let node = node {
                    nodes.append(node)
                }
            }

            // Maintain order
            return nodes.sorted { node1, node2 in
                guard let index1 = ids.firstIndex(of: node1.id),
                      let index2 = ids.firstIndex(of: node2.id) else {
                    return false
                }
                return index1 < index2
            }
        }
    }

    // MARK: - User Fetching

    func fetchUser(id: String) async throws -> User {
        let cacheKey = "user_\(id)"

        if let cached = cache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheTimeout,
           let user = cached.data as? User {
            return user
        }

        let url = URL(string: "\(baseURL)/user/\(id).json")!
        let (data, _) = try await session.data(from: url)
        let user = try JSONDecoder().decode(User.self, from: data)

        cache[cacheKey] = (user, Date())
        return user
    }

    // MARK: - Search (Algolia)

    func search(
        query: String,
        sort: SearchSortOption = .relevance,
        timeFilter: SearchTimeFilter = .allTime,
        page: Int = 0
    ) async throws -> AlgoliaSearchResponse {
        var urlComponents = URLComponents(string: "\(algoliaBaseURL)/\(sort.algoliaParam)")!

        var queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "tags", value: "story"),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "hitsPerPage", value: "30")
        ]

        if let timestamp = timeFilter.timestamp {
            queryItems.append(URLQueryItem(name: "numericFilters", value: "created_at_i>\(timestamp)"))
        }

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(AlgoliaSearchResponse.self, from: data)
    }

    // MARK: - Cache Management

    func clearCache() {
        cache.removeAll()
    }

    func clearExpiredCache() {
        let now = Date()
        cache = cache.filter { now.timeIntervalSince($0.value.timestamp) < cacheTimeout }
    }
}
