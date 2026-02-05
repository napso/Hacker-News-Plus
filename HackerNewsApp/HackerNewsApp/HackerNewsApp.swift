import SwiftUI

@main
struct HackerNewsApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var bookmarkManager = BookmarkManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(bookmarkManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
