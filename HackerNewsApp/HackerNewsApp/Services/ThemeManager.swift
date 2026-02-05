import Foundation
import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case sepia = "Sepia"
    case black = "Black (AMOLED)"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light, .sepia: return .light
        case .dark, .black: return .dark
        }
    }
}

enum FontSize: String, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "Extra Large"

    var id: String { rawValue }

    var titleSize: CGFloat {
        switch self {
        case .small: return 15
        case .medium: return 17
        case .large: return 19
        case .extraLarge: return 21
        }
    }

    var bodySize: CGFloat {
        switch self {
        case .small: return 13
        case .medium: return 15
        case .large: return 17
        case .extraLarge: return 19
        }
    }

    var captionSize: CGFloat {
        switch self {
        case .small: return 11
        case .medium: return 13
        case .large: return 15
        case .extraLarge: return 17
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme")
        }
    }

    @Published var fontSize: FontSize {
        didSet {
            UserDefaults.standard.set(fontSize.rawValue, forKey: "fontSize")
        }
    }

    @Published var useCompactMode: Bool {
        didSet {
            UserDefaults.standard.set(useCompactMode, forKey: "compactMode")
        }
    }

    @Published var showThumbnails: Bool {
        didSet {
            UserDefaults.standard.set(showThumbnails, forKey: "showThumbnails")
        }
    }

    @Published var openLinksInApp: Bool {
        didSet {
            UserDefaults.standard.set(openLinksInApp, forKey: "openLinksInApp")
        }
    }

    @Published var autoCollapseComments: Bool {
        didSet {
            UserDefaults.standard.set(autoCollapseComments, forKey: "autoCollapseComments")
        }
    }

    init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "appTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
        } else {
            currentTheme = .system
        }

        if let savedSize = UserDefaults.standard.string(forKey: "fontSize"),
           let size = FontSize(rawValue: savedSize) {
            fontSize = size
        } else {
            fontSize = .medium
        }

        useCompactMode = UserDefaults.standard.bool(forKey: "compactMode")
        showThumbnails = UserDefaults.standard.object(forKey: "showThumbnails") as? Bool ?? true
        openLinksInApp = UserDefaults.standard.object(forKey: "openLinksInApp") as? Bool ?? true
        autoCollapseComments = UserDefaults.standard.bool(forKey: "autoCollapseComments")
    }

    var colorScheme: ColorScheme? {
        currentTheme.colorScheme
    }

    // MARK: - Theme Colors

    var backgroundColor: Color {
        switch currentTheme {
        case .system, .light:
            return Color(.systemBackground)
        case .dark:
            return Color(.systemBackground)
        case .sepia:
            return Color(red: 0.96, green: 0.94, blue: 0.89)
        case .black:
            return Color.black
        }
    }

    var cardBackgroundColor: Color {
        switch currentTheme {
        case .system, .light:
            return Color(.secondarySystemBackground)
        case .dark:
            return Color(.secondarySystemBackground)
        case .sepia:
            return Color(red: 0.94, green: 0.91, blue: 0.84)
        case .black:
            return Color(white: 0.1)
        }
    }

    var primaryTextColor: Color {
        switch currentTheme {
        case .sepia:
            return Color(red: 0.35, green: 0.25, blue: 0.15)
        default:
            return Color.primary
        }
    }

    var secondaryTextColor: Color {
        switch currentTheme {
        case .sepia:
            return Color(red: 0.5, green: 0.4, blue: 0.3)
        default:
            return Color.secondary
        }
    }

    var accentColor: Color {
        Color("AccentOrange")
    }
}
