import Foundation
import SwiftUI

class BookmarkManager: ObservableObject {
    @Published var bookmarkedStories: [Story] = []
    @Published var readStoryIds: Set<Int> = []

    private let bookmarksKey = "bookmarkedStories"
    private let readStoriesKey = "readStoryIds"

    init() {
        loadBookmarks()
        loadReadStories()
    }

    // MARK: - Bookmarks

    func isBookmarked(_ story: Story) -> Bool {
        bookmarkedStories.contains { $0.id == story.id }
    }

    func toggleBookmark(_ story: Story) {
        if isBookmarked(story) {
            removeBookmark(story)
        } else {
            addBookmark(story)
        }
    }

    func addBookmark(_ story: Story) {
        guard !isBookmarked(story) else { return }
        bookmarkedStories.insert(story, at: 0)
        saveBookmarks()
    }

    func removeBookmark(_ story: Story) {
        bookmarkedStories.removeAll { $0.id == story.id }
        saveBookmarks()
    }

    private func saveBookmarks() {
        if let encoded = try? JSONEncoder().encode(bookmarkedStories) {
            UserDefaults.standard.set(encoded, forKey: bookmarksKey)
        }
    }

    private func loadBookmarks() {
        if let data = UserDefaults.standard.data(forKey: bookmarksKey),
           let decoded = try? JSONDecoder().decode([Story].self, from: data) {
            bookmarkedStories = decoded
        }
    }

    // MARK: - Read Stories

    func isRead(_ story: Story) -> Bool {
        readStoryIds.contains(story.id)
    }

    func markAsRead(_ story: Story) {
        readStoryIds.insert(story.id)
        saveReadStories()
    }

    func markAsUnread(_ story: Story) {
        readStoryIds.remove(story.id)
        saveReadStories()
    }

    func clearReadHistory() {
        readStoryIds.removeAll()
        saveReadStories()
    }

    private func saveReadStories() {
        let array = Array(readStoryIds)
        UserDefaults.standard.set(array, forKey: readStoriesKey)
    }

    private func loadReadStories() {
        if let array = UserDefaults.standard.array(forKey: readStoriesKey) as? [Int] {
            readStoryIds = Set(array)
        }
    }
}
