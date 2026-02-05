import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @State private var showingClearReadHistory = false

    var body: some View {
        NavigationStack {
            Form {
                // Appearance
                Section {
                    NavigationLink {
                        ThemeSelectionView()
                    } label: {
                        HStack {
                            Label("Theme", systemImage: "paintbrush.fill")
                            Spacer()
                            Text(themeManager.currentTheme.rawValue)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                    }

                    NavigationLink {
                        FontSizeSelectionView()
                    } label: {
                        HStack {
                            Label("Font Size", systemImage: "textformat.size")
                            Spacer()
                            Text(themeManager.fontSize.rawValue)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                    }

                    Toggle(isOn: $themeManager.useCompactMode) {
                        Label("Compact Mode", systemImage: "rectangle.compress.vertical")
                    }
                    .tint(Color("AccentOrange"))
                } header: {
                    Text("Appearance")
                }

                // Reading
                Section {
                    Toggle(isOn: $themeManager.openLinksInApp) {
                        Label("Open Links In-App", systemImage: "safari")
                    }
                    .tint(Color("AccentOrange"))

                    Toggle(isOn: $themeManager.autoCollapseComments) {
                        Label("Auto-Collapse Deep Comments", systemImage: "arrow.up.left.and.arrow.down.right")
                    }
                    .tint(Color("AccentOrange"))
                } header: {
                    Text("Reading")
                }

                // Data
                Section {
                    Button {
                        showingClearReadHistory = true
                    } label: {
                        Label("Clear Read History", systemImage: "clock.arrow.circlepath")
                            .foregroundColor(themeManager.primaryTextColor)
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("\(bookmarkManager.readStoryIds.count) stories marked as read")
                }

                // About
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(themeManager.secondaryTextColor)
                    }

                    Link(destination: URL(string: "https://github.com/HackerNews/API")!) {
                        Label("Hacker News API", systemImage: "link")
                    }

                    Link(destination: URL(string: "https://hn.algolia.com/api")!) {
                        Label("Algolia Search API", systemImage: "magnifyingglass")
                    }
                } header: {
                    Text("About")
                } footer: {
                    Text("Inspired by Materialistic for Android")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .tint(Color("AccentOrange"))
            .confirmationDialog(
                "Clear Read History?",
                isPresented: $showingClearReadHistory,
                titleVisibility: .visible
            ) {
                Button("Clear History", role: .destructive) {
                    bookmarkManager.clearReadHistory()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("All stories will appear as unread.")
            }
        }
    }
}

struct ThemeSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        List {
            ForEach(AppTheme.allCases) { theme in
                Button {
                    themeManager.currentTheme = theme
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(theme.rawValue)
                                .foregroundColor(themeManager.primaryTextColor)

                            Text(themeDescription(for: theme))
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }

                        Spacer()

                        if themeManager.currentTheme == theme {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color("AccentOrange"))
                        }
                    }
                }
            }
        }
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func themeDescription(for theme: AppTheme) -> String {
        switch theme {
        case .system: return "Follow system appearance"
        case .light: return "Always use light mode"
        case .dark: return "Always use dark mode"
        case .sepia: return "Warm, paper-like appearance"
        case .black: return "Pure black for OLED displays"
        }
    }
}

struct FontSizeSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        List {
            ForEach(FontSize.allCases) { size in
                Button {
                    themeManager.fontSize = size
                } label: {
                    HStack {
                        Text("Sample Text")
                            .font(.system(size: size.titleSize))
                            .foregroundColor(themeManager.primaryTextColor)

                        Spacer()

                        Text(size.rawValue)
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)

                        if themeManager.fontSize == size {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color("AccentOrange"))
                        }
                    }
                }
            }
        }
        .navigationTitle("Font Size")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
        .environmentObject(BookmarkManager())
}
