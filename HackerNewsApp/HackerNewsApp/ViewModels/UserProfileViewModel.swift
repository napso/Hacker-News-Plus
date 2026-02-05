import Foundation

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var submissions: [Story] = []
    @Published var isLoading = false
    @Published var isLoadingSubmissions = false
    @Published var error: String?

    private let api = HackerNewsAPI.shared
    private var currentPage = 0
    private let pageSize = 20

    let userId: String

    init(userId: String) {
        self.userId = userId
    }

    var hasMoreSubmissions: Bool {
        guard let submitted = user?.submitted else { return false }
        return currentPage * pageSize < submitted.count
    }

    func loadUser() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        do {
            user = try await api.fetchUser(id: userId)
            await loadSubmissions(refresh: true)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func loadSubmissions(refresh: Bool = false) async {
        guard let submitted = user?.submitted, !submitted.isEmpty else { return }

        if refresh {
            currentPage = 0
            submissions = []
        }

        guard !isLoadingSubmissions else { return }
        isLoadingSubmissions = true

        do {
            let startIndex = currentPage * pageSize
            let endIndex = min(startIndex + pageSize, submitted.count)
            let idsToFetch = Array(submitted[startIndex..<endIndex])

            let fetchedItems = try await api.fetchStories(ids: idsToFetch, limit: pageSize)
            let stories = fetchedItems.filter { $0.type == "story" }

            if refresh {
                submissions = stories
            } else {
                submissions.append(contentsOf: stories)
            }
            currentPage += 1
        } catch {
            self.error = error.localizedDescription
        }

        isLoadingSubmissions = false
    }

    func loadMoreSubmissions() async {
        guard hasMoreSubmissions else { return }
        await loadSubmissions(refresh: false)
    }
}
