import Foundation

struct ParsedColor: Sendable {
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    init(r: Double, g: Double, b: Double, a: Double = 1) {
        self.r = Self.clamp01(r)
        self.g = Self.clamp01(g)
        self.b = Self.clamp01(b)
        self.a = Self.clamp01(a)
    }

    private static func clamp01(_ x: Double) -> Double {
        min(1, max(0, x))
    }

    private static func clampByte(_ x: Double) -> Int {
        Int(round(min(255, max(0, x * 255))))
    }

    func hexRGB() -> String {
        let ri = Self.clampByte(r)
        let gi = Self.clampByte(g)
        let bi = Self.clampByte(b)
        return String(format: "#%02X%02X%02X", ri, gi, bi)
    }

    func hexRGBA() -> String {
        let ri = Self.clampByte(r)
        let gi = Self.clampByte(g)
        let bi = Self.clampByte(b)
        let ai = Self.clampByte(a)
        return String(format: "#%02X%02X%02X%02X", ri, gi, bi, ai)
    }

    func cssRgb() -> String {
        let ri = Self.clampByte(r)
        let gi = Self.clampByte(g)
        let bi = Self.clampByte(b)
        return "rgb(\(ri), \(gi), \(bi))"
    }

    func cssRgba() -> String {
        let ri = Self.clampByte(r)
        let gi = Self.clampByte(g)
        let bi = Self.clampByte(b)
        let af = (round(a * 1000) / 1000)
        return "rgba(\(ri), \(gi), \(bi), \(af))"
    }

    func cssHsl() -> String {
        let h = hslHue()
        let s = hslSaturation() * 100
        let l = hslLightness() * 100
        return String(format: "hsl(%.1f, %.1f%%, %.1f%%)", h, s, l)
    }

    func cssHsla() -> String {
        let h = hslHue()
        let s = hslSaturation() * 100
        let l = hslLightness() * 100
        let af = (round(a * 1000) / 1000)
        return String(format: "hsla(%.1f, %.1f%%, %.1f%%, %.3f)", h, s, l, af)
    }

    private func hslHue() -> Double {
        let maxv = max(r, g, b)
        let minv = min(r, g, b)
        let d = maxv - minv
        if d < 1e-9 { return 0 }
        var h: Double = 0
        if maxv == r {
            h = 60 * (((g - b) / d).truncatingRemainder(dividingBy: 6))
        } else if maxv == g {
            h = 60 * (((b - r) / d) + 2)
        } else {
            h = 60 * (((r - g) / d) + 4)
        }
        if h < 0 { h += 360 }
        return h
    }

    private func hslLightness() -> Double {
        (max(r, g, b) + min(r, g, b)) / 2
    }

    private func hslSaturation() -> Double {
        let maxv = max(r, g, b)
        let minv = min(r, g, b)
        let l = (maxv + minv) / 2
        let d = maxv - minv
        if d < 1e-9 { return 0 }
        if l > 0.5 {
            return d / (2 - maxv - minv)
        }
        return d / (maxv + minv)
    }
}

enum ColorFormats {
    static func parse(_ raw: String) -> ParsedColor? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return nil }
        if let c = parseHex(t) { return c }
        if let c = parseRgbLike(t) { return c }
        if let c = parseHslLike(t) { return c }
        return nil
    }

    private static func parseHex(_ t: String) -> ParsedColor? {
        let raw = t.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }
        let s: String
        if raw.hasPrefix("#") {
            let rest = String(raw.dropFirst())
            let hexOnly = rest.filter(\.isHexDigit)
            guard hexOnly.count == rest.count else { return nil }
            guard [3, 6, 8].contains(hexOnly.count) else { return nil }
            s = hexOnly
        } else {
            let hexOnly = raw.filter(\.isHexDigit)
            guard hexOnly.count == raw.count else { return nil }
            guard [3, 6, 8].contains(hexOnly.count) else { return nil }
            s = hexOnly
        }
        if s.count == 3 {
            let chars = Array(s)
            let r = expandHex(String(chars[0]))
            let g = expandHex(String(chars[1]))
            let b = expandHex(String(chars[2]))
            return ParsedColor(r: r, g: g, b: b, a: 1)
        }
        if s.count == 6 {
            guard let r = byteFromHex(String(s.prefix(2))),
                  let g = byteFromHex(String(s.dropFirst(2).prefix(2))),
                  let b = byteFromHex(String(s.suffix(2))) else { return nil }
            return ParsedColor(r: Double(r) / 255, g: Double(g) / 255, b: Double(b) / 255, a: 1)
        }
        if s.count == 8 {
            guard let r = byteFromHex(String(s.prefix(2))),
                  let g = byteFromHex(String(s.dropFirst(2).prefix(2))),
                  let b = byteFromHex(String(s.dropFirst(4).prefix(2))),
                  let a = byteFromHex(String(s.suffix(2))) else { return nil }
            return ParsedColor(r: Double(r) / 255, g: Double(g) / 255, b: Double(b) / 255, a: Double(a) / 255)
        }
        return nil
    }

    private static func expandHex(_ one: String) -> Double {
        Double(byteFromHex(one + one) ?? 0) / 255
    }

    private static func byteFromHex(_ two: String) -> Int? {
        guard two.count == 2 else { return nil }
        return Int(two, radix: 16)
    }

    private static func parseRgbLike(_ t: String) -> ParsedColor? {
        let low = t.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if low.hasPrefix("rgba") {
            return parseFuncValues(t, prefixes: ["rgba"]) { vals in
                guard vals.count >= 3 else { return nil }
                let r = parseChannel(vals[0])
                let g = parseChannel(vals[1])
                let b = parseChannel(vals[2])
                let a = vals.count > 3 ? parseAlpha(vals[3]) : 1
                return ParsedColor(r: r, g: g, b: b, a: a)
            }
        }
        if low.hasPrefix("rgb") {
            return parseFuncValues(t, prefixes: ["rgb"]) { vals in
                guard vals.count >= 3 else { return nil }
                let r = parseChannel(vals[0])
                let g = parseChannel(vals[1])
                let b = parseChannel(vals[2])
                return ParsedColor(r: r, g: g, b: b, a: 1)
            }
        }
        return nil
    }

    private static func parseFuncValues(_ t: String, prefixes: [String], builder: ([String]) -> ParsedColor?) -> ParsedColor? {
        let s = t.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let open = s.firstIndex(of: "("), let close = s.lastIndex(of: ")"), open < close else { return nil }
        let fname = String(s[..<open]).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard prefixes.contains(fname) else { return nil }
        let inner = String(s[s.index(after: open)..<close])
        let parts = splitTopLevelCommas(inner)
        return builder(parts)
    }

    private static func splitTopLevelCommas(_ inner: String) -> [String] {
        var out: [String] = []
        var cur = ""
        var depth = 0
        for ch in inner {
            if ch == "(" { depth += 1 }
            if ch == ")" { depth -= 1 }
            if ch == ",", depth == 0 {
                out.append(cur.trimmingCharacters(in: .whitespacesAndNewlines))
                cur = ""
            } else {
                cur.append(ch)
            }
        }
        if !cur.isEmpty {
            out.append(cur.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return out
    }

    private static func parseChannel(_ s: String) -> Double {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.hasSuffix("%") {
            let n = Double(t.dropLast().filter { $0.isNumber || $0 == "." || $0 == "-" }) ?? 0
            return (n / 100).clamped01()
        }
        let n = Double(t.filter { $0.isNumber || $0 == "." || $0 == "-" }) ?? 0
        if t.contains(".") {
            return n.clamped01()
        }
        if n > 1 {
            return (n / 255).clamped01()
        }
        return n.clamped01()
    }

    private static func parseAlpha(_ s: String) -> Double {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.hasSuffix("%") {
            let n = Double(t.dropLast().filter { $0.isNumber || $0 == "." || $0 == "-" }) ?? 100
            return (n / 100).clamped01()
        }
        return (Double(t.filter { $0.isNumber || $0 == "." || $0 == "-" }) ?? 1).clamped01()
    }

    private static func parseHslLike(_ t: String) -> ParsedColor? {
        let low = t.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if low.hasPrefix("hsla") {
            return parseFuncValues(t, prefixes: ["hsla"]) { vals in
                guard vals.count >= 3 else { return nil }
                let h = Double(vals[0].filter { $0.isNumber || $0 == "." || $0 == "-" }) ?? 0
                let s = parsePercentOrUnit(vals[1])
                let l = parsePercentOrUnit(vals[2])
                let a = vals.count > 3 ? parseAlpha(vals[3]) : 1
                return hslToRgb(h: h, s: s, l: l, a: a)
            }
        }
        if low.hasPrefix("hsl") {
            return parseFuncValues(t, prefixes: ["hsl"]) { vals in
                guard vals.count >= 3 else { return nil }
                let h = Double(vals[0].filter { $0.isNumber || $0 == "." || $0 == "-" }) ?? 0
                let s = parsePercentOrUnit(vals[1])
                let l = parsePercentOrUnit(vals[2])
                return hslToRgb(h: h, s: s, l: l, a: 1)
            }
        }
        return nil
    }

    private static func parsePercentOrUnit(_ s: String) -> Double {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.hasSuffix("%") {
            let n = Double(t.dropLast().filter { $0.isNumber || $0 == "." || $0 == "-" }) ?? 0
            return (n / 100).clamped01()
        }
        let n = Double(t.filter { $0.isNumber || $0 == "." || $0 == "-" }) ?? 0
        if n <= 1 { return n.clamped01() }
        return (n / 100).clamped01()
    }

    private static func hslToRgb(h: Double, s: Double, l: Double, a: Double) -> ParsedColor {
        let hh = (h.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360) / 360
        let s1 = s.clamped01()
        let l1 = l.clamped01()
        if s1 < 1e-9 {
            return ParsedColor(r: l1, g: l1, b: l1, a: a)
        }
        let q = l1 < 0.5 ? l1 * (1 + s1) : l1 + s1 - l1 * s1
        let p = 2 * l1 - q
        let r = hueToRgb(p, q, hh + 1 / 3)
        let g = hueToRgb(p, q, hh)
        let b = hueToRgb(p, q, hh - 1 / 3)
        return ParsedColor(r: r, g: g, b: b, a: a)
    }

    private static func hueToRgb(_ p: Double, _ q: Double, _ t: Double) -> Double {
        var tt = t
        if tt < 0 { tt += 1 }
        if tt > 1 { tt -= 1 }
        if tt < 1 / 6 { return p + (q - p) * 6 * tt }
        if tt < 1 / 2 { return q }
        if tt < 2 / 3 { return p + (q - p) * (2 / 3 - tt) * 6 }
        return p
    }
}

private extension Double {
    func clamped01() -> Double {
        min(1, max(0, self))
    }
}
