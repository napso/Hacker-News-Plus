import SwiftUI

struct UserProfileView: View {
    let userId: String

    @StateObject private var viewModel: UserProfileViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var bookmarkManager: BookmarkManager

    init(userId: String) {
        self.userId = userId
        self._viewModel = StateObject(wrappedValue: UserProfileViewModel(userId: userId))
    }

    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()

            if viewModel.isLoading && viewModel.user == nil {
                LoadingView()
            } else if let error = viewModel.error, viewModel.user == nil {
                ErrorView(message: error) {
                    Task {
                        await viewModel.loadUser()
                    }
                }
            } else if let user = viewModel.user {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Profile header
                        profileHeader(user: user)

                        Divider()
                            .padding(.vertical, 16)

                        // About section
                        if !user.aboutText.isEmpty && user.about != nil {
                            aboutSection(user: user)

                            Divider()
                                .padding(.vertical, 16)
                        }

                        // Submissions
                        submissionsSection
                    }
                }
                .refreshable {
                    await viewModel.loadUser()
                }
            }
        }
        .navigationTitle(userId)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadUser()
        }
    }

    private func profileHeader(user: User) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Avatar and name
            HStack(spacing: 16) {
                // Avatar placeholder
                ZStack {
                    Circle()
                        .fill(Color("AccentOrange").opacity(0.2))
                        .frame(width: 80, height: 80)

                    Text(String(user.id.prefix(1)).uppercased())
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color("AccentOrange"))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(user.id)
                        .font(.system(size: themeManager.fontSize.titleSize + 4, weight: .bold))
                        .foregroundColor(themeManager.primaryTextColor)

                    Text("Member since \(user.memberSince)")
                        .font(.system(size: themeManager.fontSize.captionSize))
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            }

            // Stats
            HStack(spacing: 32) {
                StatView(value: user.displayKarma, label: "Karma")
                StatView(value: "\(user.submissionCount)", label: "Submissions")
            }
        }
        .padding(16)
    }

    private func aboutSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.system(size: themeManager.fontSize.titleSize, weight: .semibold))
                .foregroundColor(themeManager.primaryTextColor)

            HTMLTextView(html: user.aboutText)
        }
        .padding(.horizontal, 16)
    }

    private var submissionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Submissions")
                    .font(.system(size: themeManager.fontSize.titleSize, weight: .semibold))
                    .foregroundColor(themeManager.primaryTextColor)

                Spacer()

                if viewModel.isLoadingSubmissions {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal, 16)

            if viewModel.submissions.isEmpty && !viewModel.isLoadingSubmissions {
                Text("No submissions yet")
                    .font(.system(size: themeManager.fontSize.bodySize))
                    .foregroundColor(themeManager.secondaryTextColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.submissions) { story in
                        NavigationLink(value: story) {
                            SubmissionRowView(story: story)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            if story.id == viewModel.submissions.last?.id {
                                Task {
                                    await viewModel.loadMoreSubmissions()
                                }
                            }
                        }
                    }

                    if viewModel.isLoadingSubmissions {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .navigationDestination(for: Story.self) { story in
            StoryDetailView(story: story)
        }
    }
}

struct StatView: View {
    let value: String
    let label: String

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: themeManager.fontSize.titleSize + 2, weight: .bold))
                .foregroundColor(Color("AccentOrange"))

            Text(label)
                .font(.system(size: themeManager.fontSize.captionSize))
                .foregroundColor(themeManager.secondaryTextColor)
        }
    }
}

struct SubmissionRowView: View {
    let story: Story

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(story.displayTitle)
                .font(.system(size: themeManager.fontSize.bodySize, weight: .medium))
                .foregroundColor(themeManager.primaryTextColor)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: 12) {
                Label("\(story.displayScore)", systemImage: "arrow.up")
                Label("\(story.commentCount)", systemImage: "bubble.right")
                Text(story.timeAgo)
            }
            .font(.system(size: themeManager.fontSize.captionSize))
            .foregroundColor(themeManager.secondaryTextColor)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        UserProfileView(userId: "pg")
    }
    .environmentObject(ThemeManager())
    .environmentObject(BookmarkManager())
}
