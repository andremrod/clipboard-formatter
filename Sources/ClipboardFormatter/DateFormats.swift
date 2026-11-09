import Foundation

enum DateFormats {
    static func parseDate(from text: String) -> Date? {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return nil }
        if let d = parseUnixString(t) { return d }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: t) { return d }
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: t) { return d }
        iso.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        if let d = iso.date(from: t) { return d }
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        let patterns = [
            "dd/MM/yyyy HH:mm:ss",
            "dd/MM/yyyy HH:mm",
            "dd/MM/yyyy",
            "dd/MM/yy HH:mm:ss",
            "dd/MM/yy HH:mm",
            "dd/MM/yy",
            "MM/dd/yyyy HH:mm:ss",
            "MM/dd/yyyy HH:mm",
            "MM/dd/yyyy",
            "MM/dd/yy HH:mm:ss",
            "MM/dd/yy HH:mm",
            "MM/dd/yy",
            "M/d/yyyy HH:mm:ss",
            "M/d/yyyy HH:mm",
            "M/d/yyyy",
            "M/d/yy HH:mm:ss",
            "M/d/yy HH:mm",
            "M/d/yy",
            "yyyy/MM/dd HH:mm:ss",
            "yyyy/MM/dd HH:mm",
            "yyyy/MM/dd",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
            "yyyy-MM-dd",
        ]
        for p in patterns {
            df.dateFormat = p
            if let d = df.date(from: t) { return d }
        }
        return nil
    }

    private static func parseUnixString(_ t: String) -> Date? {
        guard t.allSatisfy({ $0.isNumber }) else { return nil }
        guard (10...13).contains(t.count) else { return nil }
        guard let v = Int64(t) else { return nil }
        if t.count >= 13 {
            return Date(timeIntervalSince1970: TimeInterval(v) / 1000)
        }
        return Date(timeIntervalSince1970: TimeInterval(v))
    }

    static func toISO8601(_ text: String) -> String {
        guard let d = parseDate(from: text) else { return text }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return iso.string(from: d)
    }

    static func toUnixSeconds(_ text: String) -> String {
        guard let d = parseDate(from: text) else { return text }
        return String(Int64(d.timeIntervalSince1970.rounded()))
    }

    static func toReadablePTBR(_ text: String) -> String {
        guard let d = parseDate(from: text) else { return text }
        let df = DateFormatter()
        df.locale = Locale(identifier: "pt_BR")
        df.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        df.dateStyle = .long
        df.timeStyle = .medium
        return df.string(from: d)
    }

    static func toShortBR(_ text: String) -> String {
        guard let d = parseDate(from: text) else { return text }
        let df = DateFormatter()
        df.locale = Locale(identifier: "pt_BR")
        df.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        df.dateFormat = "dd/MM/yyyy"
        return df.string(from: d)
    }

    static func toUSMDY(_ text: String) -> String {
        guard let d = parseDate(from: text) else { return text }
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        df.dateFormat = "MM/dd/yyyy"
        return df.string(from: d)
    }

    static func toYMDSlash(_ text: String) -> String {
        guard let d = parseDate(from: text) else { return text }
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        df.dateFormat = "yyyy/MM/dd"
        return df.string(from: d)
    }

    static func toDMYY(_ text: String) -> String {
        guard let d = parseDate(from: text) else { return text }
        let df = DateFormatter()
        df.locale = Locale(identifier: "pt_BR")
        df.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        df.dateFormat = "dd/MM/yy"
        return df.string(from: d)
    }
}
