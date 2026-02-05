import SwiftUI

struct HTMLTextView: View {
    let html: String
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Text(attributedString)
            .font(.system(size: themeManager.fontSize.bodySize))
            .foregroundColor(themeManager.primaryTextColor)
            .tint(Color("AccentOrange"))
    }

    private var attributedString: AttributedString {
        // Convert HTML to plain text with basic formatting
        let processed = processHTML(html)

        do {
            var attributed = try AttributedString(markdown: processed, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
            return attributed
        } catch {
            return AttributedString(stripHTML(html))
        }
    }

    private func processHTML(_ html: String) -> String {
        var result = html

        // Replace common HTML entities
        let entities: [String: String] = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&#x27;": "'",
            "&#39;": "'",
            "&apos;": "'",
            "&nbsp;": " ",
            "&#x2F;": "/",
            "&#47;": "/",
            "&mdash;": "—",
            "&ndash;": "–",
            "&hellip;": "…",
            "&copy;": "©",
            "&reg;": "®",
            "&trade;": "™"
        ]

        for (entity, replacement) in entities {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }

        // Convert <a> tags to markdown links
        let linkPattern = #"<a[^>]*href="([^"]*)"[^>]*>([^<]*)</a>"#
        if let regex = try? NSRegularExpression(pattern: linkPattern, options: .caseInsensitive) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "[$2]($1)")
        }

        // Convert <i> and <em> to markdown italic
        result = result.replacingOccurrences(of: "<i>", with: "_")
        result = result.replacingOccurrences(of: "</i>", with: "_")
        result = result.replacingOccurrences(of: "<em>", with: "_")
        result = result.replacingOccurrences(of: "</em>", with: "_")

        // Convert <b> and <strong> to markdown bold
        result = result.replacingOccurrences(of: "<b>", with: "**")
        result = result.replacingOccurrences(of: "</b>", with: "**")
        result = result.replacingOccurrences(of: "<strong>", with: "**")
        result = result.replacingOccurrences(of: "</strong>", with: "**")

        // Convert <code> to markdown code
        result = result.replacingOccurrences(of: "<code>", with: "`")
        result = result.replacingOccurrences(of: "</code>", with: "`")

        // Convert <pre> blocks
        result = result.replacingOccurrences(of: "<pre>", with: "\n```\n")
        result = result.replacingOccurrences(of: "</pre>", with: "\n```\n")

        // Convert <p> to double newlines
        result = result.replacingOccurrences(of: "<p>", with: "\n\n")
        result = result.replacingOccurrences(of: "</p>", with: "")

        // Convert <br> to newlines
        result = result.replacingOccurrences(of: "<br>", with: "\n")
        result = result.replacingOccurrences(of: "<br/>", with: "\n")
        result = result.replacingOccurrences(of: "<br />", with: "\n")

        // Remove remaining HTML tags
        result = stripHTML(result)

        // Clean up multiple newlines
        while result.contains("\n\n\n") {
            result = result.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func stripHTML(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else { return string }

        let pattern = "<[^>]+>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return string
        }

        let range = NSRange(string.startIndex..., in: string)
        return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "")
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        HTMLTextView(html: "This is <b>bold</b> and <i>italic</i> text.")
        HTMLTextView(html: "Check out <a href=\"https://example.com\">this link</a>!")
        HTMLTextView(html: "Code: <code>let x = 5</code>")
    }
    .padding()
    .environmentObject(ThemeManager())
}
