import Foundation

enum JSONInputNormalizer {
    static func parseableVariant(of text: String) -> String? {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let f = t.first, f == "{" || f == "[" else { return nil }
        if jsonParses(t) { return t }
        let relaxed = quoteJavaScriptKeys(t)
        if jsonParses(relaxed) { return relaxed }
        return nil
    }

    static func jsonParses(_ s: String) -> Bool {
        guard let d = s.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: d, options: [])) != nil
    }

    private static func quoteJavaScriptKeys(_ text: String) -> String {
        guard let re = try? NSRegularExpression(pattern: #"(\{|\,)\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*:"#, options: []) else { return text }
        let range = NSRange(text.startIndex..., in: text)
        return re.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "$1\"$2\":")
    }
}
