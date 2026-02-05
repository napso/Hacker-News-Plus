import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results: [AlgoliaHit] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var sortOption: SearchSortOption = .relevance
    @Published var timeFilter: SearchTimeFilter = .allTime

    private var currentPage = 0
    private var totalPages = 0
    private var cancellables = Set<AnyCancellable>()
    private let api = HackerNewsAPI.shared

    init() {
        // Debounce search input
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard !query.isEmpty else {
                    self?.results = []
                    return
                }
                Task {
                    await self?.search()
                }
            }
            .store(in: &cancellables)
    }

    var hasMoreResults: Bool {
        currentPage < totalPages - 1
    }

    func search(refresh: Bool = true) async {
        guard !searchText.isEmpty else {
            results = []
            return
        }

        if refresh {
            currentPage = 0
            results = []
        }

        guard !isLoading else { return }
        isLoading = true
        error = nil

        do {
            let response = try await api.search(
                query: searchText,
                sort: sortOption,
                timeFilter: timeFilter,
                page: currentPage
            )

            if refresh {
                results = response.hits
            } else {
                results.append(contentsOf: response.hits)
            }

            totalPages = response.nbPages
            currentPage = response.page + 1
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func loadMore() async {
        guard hasMoreResults, !isLoading else { return }
        await search(refresh: false)
    }

    func updateFilters(sort: SearchSortOption? = nil, time: SearchTimeFilter? = nil) async {
        if let sort = sort {
            sortOption = sort
        }
        if let time = time {
            timeFilter = time
        }
        await search(refresh: true)
    }

    func clearSearch() {
        searchText = ""
        results = []
        currentPage = 0
        totalPages = 0
    }
}
