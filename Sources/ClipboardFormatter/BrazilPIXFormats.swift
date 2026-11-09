import Foundation

enum BrazilPIXFormats {
    static func maskPhoneBR(_ text: String) -> String {
        let d = FormatterService.digitsOnly(text)
        guard d.count == 10 || d.count == 11 else { return text }
        let ddd = String(d.prefix(2))
        let rest = String(d.dropFirst(2))
        if rest.count == 9 {
            let f = rest.first
            if f == "9" || f == "8" || f == "7" {
                return "(\(ddd)) \(rest.prefix(5))-\(rest.suffix(4))"
            }
        }
        if rest.count == 8 {
            return "(\(ddd)) \(rest.prefix(4))-\(rest.suffix(4))"
        }
        return text
    }

    static func unmaskPhoneBR(_ text: String) -> String {
        let d = FormatterService.digitsOnly(text)
        guard d.count == 10 || d.count == 11 else { return text }
        return d
    }

    static func maskCEP(_ text: String) -> String {
        let d = FormatterService.digitsOnly(text)
        guard d.count == 8 else { return text }
        return "\(d.prefix(5))-\(d.suffix(3))"
    }

    static func unmaskCEP(_ text: String) -> String {
        let d = FormatterService.digitsOnly(text)
        return d.count == 8 ? d : text
    }

    static func normalizePIXKey(_ text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.contains("@") {
            return t.lowercased()
        }
        let d = FormatterService.digitsOnly(t)
        if d.count == 10 || d.count == 11 || d.count == 14 {
            return d
        }
        let hex = t.filter(\.isHexDigit)
        if hex.count == 32 {
            return hex.lowercased()
        }
        if t.count == 36, t.filter({ $0 == "-" }).count == 4 {
            return t.lowercased()
        }
        return t
    }

    static func brlToDecimalPoint(_ text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.contains(",") == false {
            let nums = t.filter(\.isNumber)
            guard !nums.isEmpty else { return text }
            return String(nums)
        }
        let noThousands = t.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: " ", with: "")
        guard let commaIdx = noThousands.lastIndex(of: ",") else { return text }
        let whole = String(noThousands[..<commaIdx]).filter(\.isNumber)
        let frac = String(noThousands[noThousands.index(after: commaIdx)...]).prefix(4).filter(\.isNumber)
        let f2 = String(frac.prefix(2))
        if f2.isEmpty {
            return whole.isEmpty ? text : whole
        }
        return "\(whole).\(f2)"
    }

    static func decimalPointToBrlFormatted(_ text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = t.split(separator: ".", omittingEmptySubsequences: false)
        guard let intPart = parts.first else { return text }
        let intDigits = String(intPart).filter(\.isNumber)
        guard !intDigits.isEmpty else { return text }
        let frac: String
        if parts.count > 1 {
            frac = String(parts[1].prefix(2)).filter(\.isNumber)
        } else {
            frac = ""
        }
        let grouped = groupThousands(intDigits)
        if frac.isEmpty {
            return grouped
        }
        let f2 = (frac + "00").prefix(2)
        return "\(grouped),\(f2)"
    }

    private static func groupThousands(_ digits: String) -> String {
        var out = ""
        var i = 0
        for ch in digits.reversed() {
            if i > 0, i % 3 == 0 {
                out = "." + out
            }
            out = String(ch) + out
            i += 1
        }
        return out
    }
}
