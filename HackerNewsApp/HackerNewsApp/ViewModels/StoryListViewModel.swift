import Foundation
import SwiftUI

@MainActor
class StoryListViewModel: ObservableObject {
    @Published var stories: [Story] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var error: String?
    @Published var selectedStoryType: StoryType = .top

    private var allStoryIds: [Int] = []
    private var currentPage = 0
    private let pageSize = 30

    private let api = HackerNewsAPI.shared

    var hasMoreStories: Bool {
        currentPage * pageSize < allStoryIds.count
    }

    func loadStories(refresh: Bool = false) async {
        if refresh {
            currentPage = 0
            stories = []
        }

        guard !isLoading else { return }
        isLoading = true
        error = nil

        do {
            allStoryIds = try await api.fetchStoryIds(for: selectedStoryType)
            let idsToFetch = Array(allStoryIds.prefix(pageSize))
            let fetchedStories = try await api.fetchStories(ids: idsToFetch, limit: pageSize)
            stories = fetchedStories
            currentPage = 1
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func loadMoreStories() async {
        guard hasMoreStories, !isLoadingMore, !isLoading else { return }
        isLoadingMore = true

        do {
            let startIndex = currentPage * pageSize
            let endIndex = min(startIndex + pageSize, allStoryIds.count)
            let idsToFetch = Array(allStoryIds[startIndex..<endIndex])
            let fetchedStories = try await api.fetchStories(ids: idsToFetch, limit: pageSize)
            stories.append(contentsOf: fetchedStories)
            currentPage += 1
        } catch {
            self.error = error.localizedDescription
        }

        isLoadingMore = false
    }

    func changeStoryType(to type: StoryType) async {
        guard type != selectedStoryType else { return }
        selectedStoryType = type
        await loadStories(refresh: true)
    }

    func refresh() async {
        await loadStories(refresh: true)
    }
}
