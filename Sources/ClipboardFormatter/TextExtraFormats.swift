import Foundation

enum TextExtraFormats {
    static func normalizeSmartQuotes(_ text: String) -> String {
        var s = text
        let pairs: [(String, String)] = [
            ("\u{201C}", "\""), ("\u{201D}", "\""), ("\u{2018}", "'"), ("\u{2019}", "'"),
            ("\u{00AB}", "\""), ("\u{00BB}", "\""), ("\u{2039}", "'"), ("\u{203A}", "'"),
            ("\u{2014}", "-"), ("\u{2013}", "-"),
        ]
        for (a, b) in pairs {
            s = s.replacingOccurrences(of: a, with: b)
        }
        return s
    }

    static func linesJoinComma(_ text: String) -> String {
        text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    static func commaSplitLines(_ text: String) -> String {
        text
            .split(separator: ",", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    static func tabsToSpaces4(_ text: String) -> String {
        text.replacingOccurrences(of: "\t", with: "    ")
    }

    static func spacesToTabs4(_ text: String) -> String {
        text.replacingOccurrences(of: "    ", with: "\t")
    }
}
