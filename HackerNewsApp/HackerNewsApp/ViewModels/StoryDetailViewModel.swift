import Foundation
import SwiftUI

@MainActor
class StoryDetailViewModel: ObservableObject {
    @Published var story: Story
    @Published var comments: [CommentNode] = []
    @Published var isLoading = false
    @Published var error: String?

    private let api = HackerNewsAPI.shared

    init(story: Story) {
        self.story = story
    }

    func loadComments() async {
        guard let kids = story.kids, !kids.isEmpty else {
            comments = []
            return
        }

        guard !isLoading else { return }
        isLoading = true
        error = nil

        do {
            comments = try await api.fetchCommentTree(ids: kids, depth: 0, maxDepth: 8)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func refreshStory() async {
        do {
            story = try await api.fetchStory(id: story.id)
            await loadComments()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func toggleCollapse(for node: CommentNode) {
        node.isCollapsed.toggle()
        objectWillChange.send()
    }

    func collapseAll() {
        setCollapseState(for: comments, collapsed: true)
        objectWillChange.send()
    }

    func expandAll() {
        setCollapseState(for: comments, collapsed: false)
        objectWillChange.send()
    }

    private func setCollapseState(for nodes: [CommentNode], collapsed: Bool) {
        for node in nodes {
            node.isCollapsed = collapsed
            setCollapseState(for: node.children, collapsed: collapsed)
        }
    }
}
