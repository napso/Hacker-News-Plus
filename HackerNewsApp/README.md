# HackerNewsApp for iOS

A beautiful, Material Design-inspired Hacker News client for iOS, modeled after the popular [Materialistic](https://github.com/hidroh/materialistic) Android app.

## Features

### Story Browsing
- **Multiple Feed Types**: Top Stories, Best, New, Ask HN, Show HN, and Jobs
- **Infinite Scroll**: Automatically loads more stories as you scroll
- **Pull to Refresh**: Swipe down to refresh the feed
- **Score Highlighting**: Visual indicators for high-scoring posts (orange for 100+, red for 200+)
- **Read Tracking**: Read stories are dimmed for easy identification

### Comments
- **Color-Coded Threads**: Each nesting level has a distinct color for easy navigation
- **Collapsible Comments**: Tap to collapse/expand comment threads
- **Bulk Actions**: Expand all or collapse all comments at once
- **Author Links**: Tap usernames to view profiles

### Search
- **Algolia-Powered**: Fast, full-text search across all Hacker News content
- **Filters**: Sort by relevance, date, or points
- **Time Ranges**: Filter by past 24h, week, month, year, or all time
- **Debounced Input**: Smart search that waits for you to finish typing

### User Profiles
- **Profile Stats**: View karma and submission count
- **About Section**: User bios with HTML rendering
- **Submission History**: Browse user's past submissions

### Bookmarks
- **Save Stories**: Bookmark stories for later reading
- **Offline Access**: Bookmarked stories are stored locally
- **Easy Management**: Swipe to remove bookmarks

### Customization
- **Multiple Themes**: System, Light, Dark, Sepia, and AMOLED Black
- **Adjustable Font Sizes**: Small, Medium, Large, Extra Large
- **Compact Mode**: Denser layout for power users
- **In-App Browser**: Choose between Safari View Controller or external browser

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository
2. Open `HackerNewsApp.xcodeproj` in Xcode
3. Select your development team in Signing & Capabilities
4. Build and run on your device or simulator

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

```
HackerNewsApp/
├── Models/
│   ├── Story.swift          # Story data model
│   ├── Comment.swift         # Comment and CommentNode models
│   ├── User.swift            # User profile model
│   └── SearchResult.swift    # Algolia search response models
├── Views/
│   ├── ContentView.swift     # Main tab view
│   ├── StoryListView.swift   # Story feed with filtering
│   ├── StoryDetailView.swift # Story details and comments
│   ├── SearchView.swift      # Search interface
│   ├── UserProfileView.swift # User profile display
│   ├── BookmarksView.swift   # Saved stories
│   └── SettingsView.swift    # App preferences
├── ViewModels/
│   ├── StoryListViewModel.swift
│   ├── StoryDetailViewModel.swift
│   ├── SearchViewModel.swift
│   └── UserProfileViewModel.swift
├── Services/
│   ├── HackerNewsAPI.swift   # API client with caching
│   ├── BookmarkManager.swift # Local storage management
│   └── ThemeManager.swift    # Theme and preferences
├── Utils/
│   ├── HTMLTextView.swift    # HTML to SwiftUI text
│   ├── SafariView.swift      # In-app browser
│   └── LoadingView.swift     # Loading and error states
└── Resources/
    └── Assets.xcassets       # Colors and app icon
```

## APIs Used

- **[Hacker News API](https://github.com/HackerNews/API)**: Official Firebase-based API for stories, comments, and users
- **[Algolia HN Search API](https://hn.algolia.com/api)**: Full-text search functionality

## Credits

- Inspired by [Materialistic](https://github.com/hidroh/materialistic) by Ha Duy Trung
- Uses the official Hacker News API
- Search powered by Algolia

## License

MIT License - see LICENSE file for details
