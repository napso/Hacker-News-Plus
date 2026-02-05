import SwiftUI

struct BookmarksView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @State private var showingClearConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()

                if bookmarkManager.bookmarkedStories.isEmpty {
                    emptyState
                } else {
                    bookmarksList
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !bookmarkManager.bookmarkedStories.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingClearConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .confirmationDialog(
                "Clear All Bookmarks?",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All", role: .destructive) {
                    withAnimation {
                        for story in bookmarkManager.bookmarkedStories {
                            bookmarkManager.removeBookmark(story)
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "bookmark")
                .font(.system(size: 60))
                .foregroundColor(themeManager.secondaryTextColor.opacity(0.5))

            Text("No Saved Stories")
                .font(.system(size: themeManager.fontSize.titleSize, weight: .semibold))
                .foregroundColor(themeManager.primaryTextColor)

            Text("Stories you save will appear here")
                .font(.system(size: themeManager.fontSize.bodySize))
                .foregroundColor(themeManager.secondaryTextColor)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }

    private var bookmarksList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(bookmarkManager.bookmarkedStories) { story in
                    NavigationLink(value: story) {
                        BookmarkRowView(story: story)
                    }
                    .buttonStyle(.plain)
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

struct BookmarkRowView: View {
    let story: Story

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var bookmarkManager: BookmarkManager

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(story.displayTitle)
                    .font(.system(size: themeManager.fontSize.titleSize, weight: .medium))
                    .foregroundColor(themeManager.primaryTextColor)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                if let host = story.hostName {
                    Text(host)
                        .font(.system(size: themeManager.fontSize.captionSize))
                        .foregroundColor(Color("AccentOrange"))
                }

                HStack(spacing: 16) {
                    Label("\(story.displayScore)", systemImage: "arrow.up")
                    Label("\(story.commentCount)", systemImage: "bubble.right")
                    Text(story.timeAgo)
                }
                .font(.system(size: themeManager.fontSize.captionSize))
                .foregroundColor(themeManager.secondaryTextColor)
            }

            Spacer()

            Button {
                withAnimation {
                    bookmarkManager.removeBookmark(story)
                }
            } label: {
                Image(systemName: "bookmark.fill")
                    .foregroundColor(Color("AccentOrange"))
            }
        }
        .padding(16)
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(12)
    }
}

#Preview {
    BookmarksView()
        .environmentObject(ThemeManager())
        .environmentObject(BookmarkManager())
}
