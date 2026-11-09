import Foundation

enum FormatterService {
    static func apply(_ kind: ActionKind, to text: String) -> String {
        switch kind {
        case .formatJSON:
            return formatJSON(text)
        case .minifyJSON:
            return minifyJSON(text)
        case .maskCPF:
            return maskCPF(text)
        case .unmaskCPF:
            return unmaskCPF(text)
        case .maskCNPJ:
            return maskCNPJ(text)
        case .unmaskCNPJ:
            return unmaskCNPJ(text)
        case .removeTrackingParameters:
            return WebDataFormats.stripTracking(from: text)
        case .copyDomainOnly:
            return domainOnly(from: text)
        case .urlEncode:
            return WebDataFormats.urlEncode(text)
        case .urlDecode:
            return WebDataFormats.urlDecode(text)
        case .queryToJSON:
            return WebDataFormats.queryToJSON(text)
        case .maskPhoneBR:
            return BrazilPIXFormats.maskPhoneBR(text)
        case .unmaskPhoneBR:
            return BrazilPIXFormats.unmaskPhoneBR(text)
        case .maskCEP:
            return BrazilPIXFormats.maskCEP(text)
        case .unmaskCEP:
            return BrazilPIXFormats.unmaskCEP(text)
        case .normalizePIXKey:
            return BrazilPIXFormats.normalizePIXKey(text)
        case .brlToDecimalPoint:
            return BrazilPIXFormats.brlToDecimalPoint(text)
        case .decimalPointToBrlFormatted:
            return BrazilPIXFormats.decimalPointToBrlFormatted(text)
        case .uppercase:
            return text.uppercased(with: Locale(identifier: "pt_BR"))
        case .lowercase:
            return text.lowercased(with: Locale(identifier: "pt_BR"))
        case .titleCase:
            return titleCase(text)
        case .removeDuplicateSpaces:
            return removeDuplicateSpaces(text)
        case .removeLineBreaks:
            return removeLineBreaks(text)
        case .normalizeSmartQuotes:
            return TextExtraFormats.normalizeSmartQuotes(text)
        case .linesJoinComma:
            return TextExtraFormats.linesJoinComma(text)
        case .commaSplitLines:
            return TextExtraFormats.commaSplitLines(text)
        case .tabsToSpaces4:
            return TextExtraFormats.tabsToSpaces4(text)
        case .spacesToTabs4:
            return TextExtraFormats.spacesToTabs4(text)
        case .uuidLowerHyphens:
            return WebDataFormats.formatUUIDString(text, upper: false, hyphens: true)
        case .uuidUpperHyphens:
            return WebDataFormats.formatUUIDString(text, upper: true, hyphens: true)
        case .uuidCompactLower:
            return WebDataFormats.formatUUIDString(text, upper: false, hyphens: false)
        case .jwtDecodePayload:
            return WebDataFormats.jwtDecodePayload(text)
        case .base64Decode:
            return WebDataFormats.base64DecodeText(text)
        case .base64Encode:
            return WebDataFormats.base64EncodeText(text)
        case .formatXML:
            return WebDataFormats.formatXMLString(text)
        case .minifyXML:
            return WebDataFormats.minifyXMLString(text)
        case .colorToHex:
            guard let c = ColorFormats.parse(text) else { return text }
            return c.hexRGB()
        case .colorToRgb:
            guard let c = ColorFormats.parse(text) else { return text }
            return c.cssRgb()
        case .colorToRgba:
            guard let c = ColorFormats.parse(text) else { return text }
            return c.cssRgba()
        case .colorToHsl:
            guard let c = ColorFormats.parse(text) else { return text }
            return c.cssHsl()
        case .colorToHsla:
            guard let c = ColorFormats.parse(text) else { return text }
            return c.cssHsla()
        case .dateToShortBR:
            return DateFormats.toShortBR(text)
        case .dateToUSMDY:
            return DateFormats.toUSMDY(text)
        case .dateToYMDSlash:
            return DateFormats.toYMDSlash(text)
        case .dateToDMYY:
            return DateFormats.toDMYY(text)
        case .dateToISO8601:
            return DateFormats.toISO8601(text)
        case .dateToUnixSeconds:
            return DateFormats.toUnixSeconds(text)
        case .dateToReadablePTBR:
            return DateFormats.toReadablePTBR(text)
        }
    }

    static func formatJSON(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let parseable = JSONInputNormalizer.parseableVariant(of: trimmed),
              let data = parseable.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let out = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
              let str = String(data: out, encoding: .utf8) else { return text }
        return str
    }

    static func minifyJSON(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let parseable = JSONInputNormalizer.parseableVariant(of: trimmed),
              let data = parseable.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let out = try? JSONSerialization.data(withJSONObject: obj, options: []),
              let str = String(data: out, encoding: .utf8) else { return text }
        return str
    }

    static func digitsOnly(_ text: String) -> String {
        text.filter(\.isNumber)
    }

    static func maskCPF(_ text: String) -> String {
        let d = digitsOnly(text)
        guard d.count == 11 else { return text }
        let s = String(d.prefix(11))
        return "\(s.prefix(3)).\(s.dropFirst(3).prefix(3)).\(s.dropFirst(6).prefix(3))-\(s.suffix(2))"
    }

    static func unmaskCPF(_ text: String) -> String {
        let d = digitsOnly(text)
        return d.count == 11 ? d : text
    }

    static func maskCNPJ(_ text: String) -> String {
        let d = digitsOnly(text)
        guard d.count == 14 else { return text }
        let s = String(d)
        return "\(s.prefix(2)).\(s.dropFirst(2).prefix(3)).\(s.dropFirst(5).prefix(3))/\(s.dropFirst(8).prefix(4))-\(s.suffix(2))"
    }

    static func unmaskCNPJ(_ text: String) -> String {
        let d = digitsOnly(text)
        return d.count == 14 ? d : text
    }

    static func domainOnly(from text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = (t.hasPrefix("http://") || t.hasPrefix("https://")) ? t : "https://\(t)"
        guard let components = URLComponents(string: base), let host = components.host else { return text }
        return host
    }

    private static func titleCase(_ text: String) -> String {
        text.lowercased(with: Locale(identifier: "pt_BR"))
            .split(separator: " ", omittingEmptySubsequences: true)
            .map { part in
                guard let f = part.first else { return "" }
                return String(f).uppercased(with: Locale(identifier: "pt_BR")) + String(part.dropFirst())
            }
            .joined(separator: " ")
    }

    private static func removeDuplicateSpaces(_ text: String) -> String {
        let collapsed = text.replacingOccurrences(of: "[ \\t]+", with: " ", options: .regularExpression)
        return collapsed.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func removeLineBreaks(_ text: String) -> String {
        let joined = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: .newlines)
            .joined(separator: " ")
        return removeDuplicateSpaces(joined)
    }
}
