import SwiftUI
import SafariServices

struct StoryDetailView: View {
    let story: Story

    @StateObject private var viewModel: StoryDetailViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @State private var showingWebView = false
    @State private var showingShareSheet = false

    init(story: Story) {
        self.story = story
        self._viewModel = StateObject(wrappedValue: StoryDetailViewModel(story: story))
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Story header
                    storyHeader

                    Divider()
                        .padding(.vertical, 12)

                    // Story text (for Ask HN, etc.)
                    if let text = viewModel.story.text {
                        HTMLTextView(html: text)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)

                        Divider()
                    }

                    // Comments section
                    commentsSection
                }
            }
            .refreshable {
                await viewModel.refreshStory()
            }
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        bookmarkManager.toggleBookmark(viewModel.story)
                    } label: {
                        Image(systemName: bookmarkManager.isBookmarked(viewModel.story) ? "bookmark.fill" : "bookmark")
                    }

                    Menu {
                        Button {
                            viewModel.expandAll()
                        } label: {
                            Label("Expand All", systemImage: "arrow.down.right.and.arrow.up.left")
                        }

                        Button {
                            viewModel.collapseAll()
                        } label: {
                            Label("Collapse All", systemImage: "arrow.up.left.and.arrow.down.right")
                        }

                        Divider()

                        if let url = viewModel.story.storyURL {
                            ShareLink(item: url) {
                                Label("Share Article", systemImage: "square.and.arrow.up")
                            }
                        }

                        ShareLink(item: viewModel.story.hackerNewsURL) {
                            Label("Share Discussion", systemImage: "bubble.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .task {
            bookmarkManager.markAsRead(viewModel.story)
            await viewModel.loadComments()
        }
        .sheet(isPresented: $showingWebView) {
            if let url = viewModel.story.storyURL {
                SafariView(url: url)
            }
        }
    }

    private var storyHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(viewModel.story.displayTitle)
                .font(.system(size: themeManager.fontSize.titleSize + 2, weight: .semibold))
                .foregroundColor(themeManager.primaryTextColor)
                .fixedSize(horizontal: false, vertical: true)

            // URL button
            if let url = viewModel.story.storyURL {
                Button {
                    if themeManager.openLinksInApp {
                        showingWebView = true
                    } else {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Image(systemName: "link")
                        Text(viewModel.story.hostName ?? "Open Article")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: themeManager.fontSize.bodySize))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color("AccentOrange"))
                    .cornerRadius(8)
                }
            }

            // Meta info
            HStack(spacing: 20) {
                Label("\(viewModel.story.displayScore) points", systemImage: "arrow.up")
                Label("\(viewModel.story.commentCount) comments", systemImage: "bubble.right")
            }
            .font(.system(size: themeManager.fontSize.captionSize))
            .foregroundColor(themeManager.secondaryTextColor)

            // Author and time
            HStack {
                NavigationLink(value: viewModel.story.displayAuthor) {
                    Text("by \(viewModel.story.displayAuthor)")
                        .foregroundColor(Color("AccentOrange"))
                }

                Text("•")
                    .foregroundColor(themeManager.secondaryTextColor)

                Text(viewModel.story.timeAgo)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            .font(.system(size: themeManager.fontSize.captionSize))
        }
        .padding(16)
        .navigationDestination(for: String.self) { userId in
            UserProfileView(userId: userId)
        }
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Comments header
            HStack {
                Text("Comments")
                    .font(.system(size: themeManager.fontSize.titleSize, weight: .semibold))
                    .foregroundColor(themeManager.primaryTextColor)

                Spacer()

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            if viewModel.isLoading && viewModel.comments.isEmpty {
                LoadingView()
                    .frame(height: 200)
            } else if viewModel.comments.isEmpty {
                Text("No comments yet")
                    .font(.system(size: themeManager.fontSize.bodySize))
                    .foregroundColor(themeManager.secondaryTextColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.comments) { node in
                        CommentNodeView(node: node, viewModel: viewModel)
                    }
                }
            }
        }
    }
}

struct CommentNodeView: View {
    @ObservedObject var node: CommentNode
    @ObservedObject var viewModel: StoryDetailViewModel
    @EnvironmentObject var themeManager: ThemeManager

    private let depthColors: [Color] = [
        Color("AccentOrange"),
        Color("AccentBlue"),
        Color("AccentGreen"),
        Color("AccentPurple"),
        Color("AccentTeal"),
        Color("AccentYellow"),
        Color.red,
        Color.pink
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Comment content
            HStack(alignment: .top, spacing: 0) {
                // Depth indicator
                if node.depth > 0 {
                    HStack(spacing: 0) {
                        ForEach(0..<node.depth, id: \.self) { depth in
                            Rectangle()
                                .fill(depthColors[depth % depthColors.count])
                                .frame(width: 3)
                                .padding(.trailing, 8)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    // Header
                    HStack {
                        NavigationLink(value: node.comment.displayAuthor) {
                            Text(node.comment.displayAuthor)
                                .font(.system(size: themeManager.fontSize.captionSize, weight: .semibold))
                                .foregroundColor(Color("AccentOrange"))
                        }

                        Text("•")
                            .foregroundColor(themeManager.secondaryTextColor)

                        Text(node.comment.timeAgo)
                            .font(.system(size: themeManager.fontSize.captionSize))
                            .foregroundColor(themeManager.secondaryTextColor)

                        Spacer()

                        if !node.children.isEmpty {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.toggleCollapse(for: node)
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    if node.isCollapsed {
                                        Text("+\(node.totalChildCount)")
                                            .font(.system(size: themeManager.fontSize.captionSize - 2))
                                    }
                                    Image(systemName: node.isCollapsed ? "chevron.down" : "chevron.up")
                                        .font(.system(size: 10))
                                }
                                .foregroundColor(themeManager.secondaryTextColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(themeManager.cardBackgroundColor)
                                .cornerRadius(4)
                            }
                        }
                    }

                    // Comment text
                    if !node.isCollapsed {
                        if node.comment.isDeleted {
                            Text("[deleted]")
                                .font(.system(size: themeManager.fontSize.bodySize))
                                .foregroundColor(themeManager.secondaryTextColor)
                                .italic()
                        } else {
                            HTMLTextView(html: node.comment.displayText)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.trailing, 16)
            }
            .padding(.leading, 16)
            .contentShape(Rectangle())
            .onTapGesture {
                if !node.children.isEmpty {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.toggleCollapse(for: node)
                    }
                }
            }

            Divider()
                .padding(.leading, CGFloat(16 + node.depth * 11))

            // Children
            if !node.isCollapsed {
                ForEach(node.children) { child in
                    CommentNodeView(node: child, viewModel: viewModel)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        StoryDetailView(story: Story(
            id: 1,
            title: "Test Story",
            url: "https://example.com",
            text: nil,
            by: "testuser",
            time: Int(Date().timeIntervalSince1970),
            score: 100,
            descendants: 50,
            kids: [],
            type: "story",
            deleted: nil,
            dead: nil
        ))
    }
    .environmentObject(ThemeManager())
    .environmentObject(BookmarkManager())
}
