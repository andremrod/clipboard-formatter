import Foundation

enum WebDataFormats {
    private static let trackingNames: Set<String> = [
        "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content",
        "fbclid", "gclid", "mc_cid", "mc_eid", "igshid", "ref", "twclid",
        "wbraid", "gbraid", "yclid", "msclkid", "dclid", "s_kwcid", "epik",
        "ttclid", "_ga", "_gl", "si", "vero_conv", "pk_campaign", "pk_kwd",
        "spm", "ved", "ei", "oq", "gs_lcp", "gbv",
    ]

    static func stripTracking(from text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let hadScheme = t.hasPrefix("http://") || t.hasPrefix("https://")
        let baseString = hadScheme ? t : "https://\(t)"
        guard var components = URLComponents(string: baseString) else { return text }
        guard let items = components.queryItems, !items.isEmpty else { return t }
        let filtered = items.filter { item in
            let n = item.name.lowercased().split(separator: "[").first.map(String.init) ?? item.name.lowercased()
            if n.hasPrefix("utm_") { return false }
            if trackingNames.contains(n) { return false }
            return true
        }
        guard filtered.count != items.count else { return t }
        components.queryItems = filtered.isEmpty ? nil : filtered
        guard let url = components.url else { return text }
        if hadScheme {
            var out = url.absoluteString
            if out.hasSuffix("?") { out.removeLast() }
            return out
        }
        let host = url.host ?? ""
        let path = url.path == "/" ? "" : url.path
        let query = components.percentEncodedQuery.map { "?\($0)" } ?? ""
        return "\(host)\(path)\(query)"
    }

    static func urlEncode(_ text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return t.addingPercentEncoding(withAllowedCharacters: allowed.inverted) ?? text
    }

    static func urlDecode(_ text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.removingPercentEncoding ?? text
    }

    static func queryToJSON(_ text: String, maxBytes: Int = 8192) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseString = (t.hasPrefix("http://") || t.hasPrefix("https://")) ? t : "https://\(t)"
        guard let c = URLComponents(string: baseString), let items = c.queryItems, !items.isEmpty else { return text }
        var dict: [String: String] = [:]
        for item in items {
            dict[item.name] = item.value ?? ""
        }
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
              data.count <= maxBytes,
              let str = String(data: data, encoding: .utf8) else { return text }
        return str
    }

    static func jwtDecodePayload(_ text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = t.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
        guard parts.count >= 2 else { return text }
        var payload = parts[1]
        payload = payload.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        while payload.count % 4 != 0 {
            payload += "="
        }
        guard let data = Data(base64Encoded: payload) else { return text }
        if let obj = try? JSONSerialization.jsonObject(with: data),
           let out = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
           let str = String(data: out, encoding: .utf8) {
            return str
        }
        return String(data: data, encoding: .utf8) ?? text
    }

    static func base64DecodeText(_ text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        var s = t
        while s.count % 4 != 0 {
            s += "="
        }
        guard let data = Data(base64Encoded: s) else { return text }
        return String(data: data, encoding: .utf8) ?? text
    }

    static func base64EncodeText(_ text: String) -> String {
        guard let d = text.data(using: .utf8) else { return text }
        return d.base64EncodedString()
    }

    static func formatXMLString(_ text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return text }
        do {
            let doc = try XMLDocument(xmlString: t, options: [.nodePreserveWhitespace])
            doc.documentContentKind = .xml
            return doc.xmlString(options: [.nodePrettyPrint])
        } catch {
            return text
        }
    }

    static func minifyXMLString(_ text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return text }
        do {
            let doc = try XMLDocument(xmlString: t, options: [])
            doc.documentContentKind = .xml
            return doc.xmlString(options: [.nodeCompactEmptyElement])
        } catch {
            return t.replacingOccurrences(of: #">\s+<"#, with: "><", options: .regularExpression)
        }
    }

    static func formatUUIDString(_ text: String, upper: Bool, hyphens: Bool) -> String {
        var hex = text.filter(\.isHexDigit)
        guard hex.count >= 32 else { return text }
        hex = String(hex.prefix(32))
        if upper {
            hex = hex.uppercased()
        } else {
            hex = hex.lowercased()
        }
        guard hyphens else { return hex }
        let p1 = hex.prefix(8)
        let p2 = hex.dropFirst(8).prefix(4)
        let p3 = hex.dropFirst(12).prefix(4)
        let p4 = hex.dropFirst(16).prefix(4)
        let p5 = hex.dropFirst(20).prefix(12)
        return "\(p1)-\(p2)-\(p3)-\(p4)-\(p5)"
    }
}
