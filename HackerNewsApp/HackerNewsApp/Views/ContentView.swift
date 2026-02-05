import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var bookmarkManager: BookmarkManager

    var body: some View {
        TabView(selection: $selectedTab) {
            StoryListView()
                .tabItem {
                    Label("Stories", systemImage: "newspaper.fill")
                }
                .tag(0)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)

            BookmarksView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .tint(Color("AccentOrange"))
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
        .environmentObject(BookmarkManager())
}
