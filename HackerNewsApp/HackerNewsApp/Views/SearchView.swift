import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @State private var showingFilters = false

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    searchBar

                    // Filter chips
                    filterChips

                    // Results
                    if viewModel.searchText.isEmpty {
                        emptySearchState
                    } else if viewModel.isLoading && viewModel.results.isEmpty {
                        LoadingView()
                    } else if viewModel.results.isEmpty {
                        noResultsState
                    } else {
                        resultsList
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeManager.secondaryTextColor)

                TextField("Search stories...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.clearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(themeManager.cardBackgroundColor)
            .cornerRadius(10)

            Button {
                showingFilters.toggle()
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundColor(Color("AccentOrange"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .sheet(isPresented: $showingFilters) {
            SearchFiltersView(viewModel: viewModel)
                .presentationDetents([.medium])
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: viewModel.sortOption.rawValue,
                    isActive: viewModel.sortOption != .relevance
                ) {
                    showingFilters = true
                }

                FilterChip(
                    title: viewModel.timeFilter.rawValue,
                    isActive: viewModel.timeFilter != .allTime
                ) {
                    showingFilters = true
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private var emptySearchState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(themeManager.secondaryTextColor.opacity(0.5))

            Text("Search Hacker News")
                .font(.system(size: themeManager.fontSize.titleSize, weight: .semibold))
                .foregroundColor(themeManager.primaryTextColor)

            Text("Find stories, comments, and discussions")
                .font(.system(size: themeManager.fontSize.bodySize))
                .foregroundColor(themeManager.secondaryTextColor)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }

    private var noResultsState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(themeManager.secondaryTextColor.opacity(0.5))

            Text("No Results")
                .font(.system(size: themeManager.fontSize.titleSize, weight: .semibold))
                .foregroundColor(themeManager.primaryTextColor)

            Text("Try different keywords or filters")
                .font(.system(size: themeManager.fontSize.bodySize))
                .foregroundColor(themeManager.secondaryTextColor)

            Spacer()
        }
        .padding()
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.results) { hit in
                    NavigationLink(value: hit.toStory()) {
                        SearchResultRowView(hit: hit)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if hit.id == viewModel.results.last?.id {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .navigationDestination(for: Story.self) { story in
            StoryDetailView(story: story)
        }
    }
}

struct SearchResultRowView: View {
    let hit: AlgoliaHit
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(hit.displayTitle)
                .font(.system(size: themeManager.fontSize.titleSize, weight: .medium))
                .foregroundColor(themeManager.primaryTextColor)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            if let host = hit.hostName {
                Text(host)
                    .font(.system(size: themeManager.fontSize.captionSize))
                    .foregroundColor(Color("AccentOrange"))
            }

            HStack(spacing: 16) {
                Label("\(hit.displayScore)", systemImage: "arrow.up")
                Label("\(hit.commentCount)", systemImage: "bubble.right")
                Text(hit.timeAgo)

                Spacer()

                Text(hit.displayAuthor)
            }
            .font(.system(size: themeManager.fontSize.captionSize))
            .foregroundColor(themeManager.secondaryTextColor)
        }
        .padding(16)
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
    }
}

struct FilterChip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: themeManager.fontSize.captionSize, weight: .medium))
                .foregroundColor(isActive ? .white : themeManager.primaryTextColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isActive ? Color("AccentOrange") : themeManager.cardBackgroundColor)
                .cornerRadius(16)
        }
    }
}

struct SearchFiltersView: View {
    @ObservedObject var viewModel: SearchViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Sort By") {
                    ForEach(SearchSortOption.allCases) { option in
                        Button {
                            Task {
                                await viewModel.updateFilters(sort: option)
                            }
                            dismiss()
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                    .foregroundColor(themeManager.primaryTextColor)
                                Spacer()
                                if viewModel.sortOption == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color("AccentOrange"))
                                }
                            }
                        }
                    }
                }

                Section("Time Range") {
                    ForEach(SearchTimeFilter.allCases) { filter in
                        Button {
                            Task {
                                await viewModel.updateFilters(time: filter)
                            }
                            dismiss()
                        } label: {
                            HStack {
                                Text(filter.rawValue)
                                    .foregroundColor(themeManager.primaryTextColor)
                                Spacer()
                                if viewModel.timeFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color("AccentOrange"))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(ThemeManager())
        .environmentObject(BookmarkManager())
}
