import SwiftUI

struct StoryListView: View {
    @StateObject private var viewModel = StoryListViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @State private var showingStoryTypePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()

                if viewModel.isLoading && viewModel.stories.isEmpty {
                    LoadingView()
                } else if let error = viewModel.error, viewModel.stories.isEmpty {
                    ErrorView(message: error) {
                        Task {
                            await viewModel.loadStories(refresh: true)
                        }
                    }
                } else {
                    storyList
                }
            }
            .navigationTitle(viewModel.selectedStoryType.rawValue)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    storyTypeMenu
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refresh()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                if viewModel.stories.isEmpty {
                    await viewModel.loadStories()
                }
            }
        }
    }

    private var storyTypeMenu: some View {
        Menu {
            ForEach(StoryType.allCases) { type in
                Button {
                    Task {
                        await viewModel.changeStoryType(to: type)
                    }
                } label: {
                    Label(type.rawValue, systemImage: type.icon)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: viewModel.selectedStoryType.icon)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .foregroundColor(Color("AccentOrange"))
        }
    }

    private var storyList: some View {
        ScrollView {
            LazyVStack(spacing: themeManager.useCompactMode ? 1 : 12) {
                ForEach(Array(viewModel.stories.enumerated()), id: \.element.id) { index, story in
                    NavigationLink(value: story) {
                        StoryRowView(story: story, rank: index + 1)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if story.id == viewModel.stories.last?.id {
                            Task {
                                await viewModel.loadMoreStories()
                            }
                        }
                    }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.horizontal, themeManager.useCompactMode ? 0 : 12)
            .padding(.vertical, 8)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .navigationDestination(for: Story.self) { story in
            StoryDetailView(story: story)
        }
    }
}

struct StoryRowView: View {
    let story: Story
    let rank: Int

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var bookmarkManager: BookmarkManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // Rank number
                Text("\(rank)")
                    .font(.system(size: themeManager.fontSize.captionSize, weight: .medium))
                    .foregroundColor(themeManager.secondaryTextColor)
                    .frame(width: 28, alignment: .center)

                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text(story.displayTitle)
                        .font(.system(size: themeManager.fontSize.titleSize, weight: .medium))
                        .foregroundColor(bookmarkManager.isRead(story) ? themeManager.secondaryTextColor : themeManager.primaryTextColor)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    // URL host
                    if let host = story.hostName {
                        Text(host)
                            .font(.system(size: themeManager.fontSize.captionSize))
                            .foregroundColor(Color("AccentOrange"))
                    }

                    // Meta info
                    HStack(spacing: 16) {
                        // Score
                        Label("\(story.displayScore)", systemImage: "arrow.up")
                            .foregroundColor(scoreColor)

                        // Comments
                        Label("\(story.commentCount)", systemImage: "bubble.right")
                            .foregroundColor(themeManager.secondaryTextColor)

                        // Time
                        Text(story.timeAgo)
                            .foregroundColor(themeManager.secondaryTextColor)

                        Spacer()

                        // Author
                        Text(story.displayAuthor)
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    .font(.system(size: themeManager.fontSize.captionSize))
                }
            }
            .padding(.vertical, themeManager.useCompactMode ? 12 : 16)
            .padding(.horizontal, 12)
        }
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(themeManager.useCompactMode ? 0 : 12)
        .contextMenu {
            Button {
                bookmarkManager.toggleBookmark(story)
            } label: {
                Label(
                    bookmarkManager.isBookmarked(story) ? "Remove Bookmark" : "Add Bookmark",
                    systemImage: bookmarkManager.isBookmarked(story) ? "bookmark.slash" : "bookmark"
                )
            }

            if let url = story.storyURL {
                ShareLink(item: url) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }

            Button {
                UIPasteboard.general.string = story.hackerNewsURL.absoluteString
            } label: {
                Label("Copy Link", systemImage: "doc.on.doc")
            }
        }
    }

    private var scoreColor: Color {
        if story.displayScore >= 200 {
            return .red
        } else if story.displayScore >= 100 {
            return Color("AccentOrange")
        } else {
            return themeManager.secondaryTextColor
        }
    }
}

#Preview {
    StoryListView()
        .environmentObject(ThemeManager())
        .environmentObject(BookmarkManager())
}
