import Foundation

enum ContentDetector {
    private static let actionsJSON: [ClipboardAction] = [
        ClipboardAction(kind: .formatJSON, title: "Formatar"),
        ClipboardAction(kind: .minifyJSON, title: "Minificar"),
    ]
    private static let actionsJWT: [ClipboardAction] = [
        ClipboardAction(kind: .jwtDecodePayload, title: "Decodificar payload (JSON)"),
    ]
    private static let actionsUUID: [ClipboardAction] = [
        ClipboardAction(kind: .uuidLowerHyphens, title: "UUID minúsculo com hífens"),
        ClipboardAction(kind: .uuidUpperHyphens, title: "UUID maiúsculo com hífens"),
        ClipboardAction(kind: .uuidCompactLower, title: "UUID compacto (sem hífens)"),
    ]
    private static let actionsPIX: [ClipboardAction] = [
        ClipboardAction(kind: .normalizePIXKey, title: "Normalizar chave PIX"),
    ]
    private static let actionsXML: [ClipboardAction] = [
        ClipboardAction(kind: .formatXML, title: "Formatar XML"),
        ClipboardAction(kind: .minifyXML, title: "Minificar XML"),
    ]
    private static let actionsBase64: [ClipboardAction] = [
        ClipboardAction(kind: .base64Decode, title: "Decodificar (texto UTF-8)"),
        ClipboardAction(kind: .base64Encode, title: "Codificar em Base64"),
    ]
    private static let actionsColor: [ClipboardAction] = [
        ClipboardAction(kind: .colorToHex, title: "Hex (#RRGGBB)"),
        ClipboardAction(kind: .colorToRgb, title: "rgb()"),
        ClipboardAction(kind: .colorToRgba, title: "rgba()"),
        ClipboardAction(kind: .colorToHsl, title: "hsl()"),
        ClipboardAction(kind: .colorToHsla, title: "hsla()"),
    ]
    private static let actionsDateTime: [ClipboardAction] = [
        ClipboardAction(kind: .dateToShortBR, title: "dd/MM/yyyy"),
        ClipboardAction(kind: .dateToDMYY, title: "dd/MM/aa"),
        ClipboardAction(kind: .dateToUSMDY, title: "MM/dd/yyyy (EUA)"),
        ClipboardAction(kind: .dateToYMDSlash, title: "yyyy/MM/dd"),
        ClipboardAction(kind: .dateToISO8601, title: "ISO 8601"),
        ClipboardAction(kind: .dateToUnixSeconds, title: "Unix (segundos)"),
        ClipboardAction(kind: .dateToReadablePTBR, title: "Legível (completo)"),
    ]
    private static let actionsURL: [ClipboardAction] = [
        ClipboardAction(kind: .removeTrackingParameters, title: "Limpar rastreamento (UTM, fbclid…)"),
        ClipboardAction(kind: .copyDomainOnly, title: "Copiar apenas domínio"),
        ClipboardAction(kind: .urlEncode, title: "Codificar URL (percent)"),
        ClipboardAction(kind: .urlDecode, title: "Decodificar URL"),
        ClipboardAction(kind: .queryToJSON, title: "Query string → JSON"),
    ]
    private static let actionsCNPJ: [ClipboardAction] = [
        ClipboardAction(kind: .maskCNPJ, title: "Aplicar máscara"),
        ClipboardAction(kind: .unmaskCNPJ, title: "Remover máscara"),
    ]
    private static let actionsCPF: [ClipboardAction] = [
        ClipboardAction(kind: .maskCPF, title: "Aplicar máscara"),
        ClipboardAction(kind: .unmaskCPF, title: "Remover máscara"),
    ]
    private static let actionsCEP: [ClipboardAction] = [
        ClipboardAction(kind: .maskCEP, title: "Aplicar máscara CEP"),
        ClipboardAction(kind: .unmaskCEP, title: "Só números (CEP)"),
    ]
    private static let actionsPhone: [ClipboardAction] = [
        ClipboardAction(kind: .maskPhoneBR, title: "Máscara telefone"),
        ClipboardAction(kind: .unmaskPhoneBR, title: "Só números"),
    ]
    private static let actionsCurrency: [ClipboardAction] = [
        ClipboardAction(kind: .brlToDecimalPoint, title: "Decimal com ponto (1234.56)"),
        ClipboardAction(kind: .decimalPointToBrlFormatted, title: "Formato brasileiro (1.234,56)"),
    ]
    private static let actionsPlainText: [ClipboardAction] = [
        ClipboardAction(kind: .uppercase, title: "UPPERCASE"),
        ClipboardAction(kind: .lowercase, title: "lowercase"),
        ClipboardAction(kind: .titleCase, title: "Title Case"),
        ClipboardAction(kind: .removeDuplicateSpaces, title: "Remover espaços duplicados"),
        ClipboardAction(kind: .removeLineBreaks, title: "Remover quebras de linha"),
        ClipboardAction(kind: .normalizeSmartQuotes, title: "Aspas tipográficas → simples"),
        ClipboardAction(kind: .linesJoinComma, title: "Linhas → separadas por vírgula"),
        ClipboardAction(kind: .commaSplitLines, title: "Vírgulas → uma linha cada"),
        ClipboardAction(kind: .tabsToSpaces4, title: "Tabs → 4 espaços"),
        ClipboardAction(kind: .spacesToTabs4, title: "4 espaços → tab"),
        ClipboardAction(kind: .normalizePIXKey, title: "Normalizar chave PIX"),
    ]

    static func detect(_ text: String) -> (ClipboardType, [ClipboardAction]) {
        if text.count > 320_000 {
            return (.plainText, actionsPlainText)
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return (.plainText, actionsPlainText)
        }
        if isJSON(trimmed) {
            return (.json, actionsJSON)
        }
        if isJWT(trimmed) {
            return (.jwt, actionsJWT)
        }
        if isUUID(trimmed) {
            return (.uuid, actionsUUID)
        }
        if isPIXEVP(trimmed) {
            return (.pixKey, actionsPIX)
        }
        if isXML(trimmed) {
            return (.xml, actionsXML)
        }
        if isBase64(trimmed) {
            return (.base64, actionsBase64)
        }
        if isDateTime(trimmed) {
            return (.dateTime, actionsDateTime)
        }
        if isColor(trimmed) {
            return (.color, actionsColor)
        }
        if isStandaloneEmail(trimmed) {
            return (.email, actionsPlainText)
        }
        if isURL(trimmed) {
            return (.url, actionsURL)
        }
        let digits = FormatterService.digitsOnly(trimmed)
        if digits.count == 14, isLikelyCNPJ(trimmed, digits: digits) {
            return (.cnpj, actionsCNPJ)
        }
        if digits.count == 11, isLikelyCPF(trimmed, digits: digits) {
            return (.cpf, actionsCPF)
        }
        if digits.count == 8, isLikelyCEP(trimmed, digits: digits) {
            return (.cep, actionsCEP)
        }
        if isPhoneBR(trimmed, digits: digits) {
            return (.phone, actionsPhone)
        }
        if isCurrencyBRL(trimmed) {
            return (.currency, actionsCurrency)
        }
        return (.plainText, actionsPlainText)
    }

    private static func isJSON(_ text: String) -> Bool {
        JSONInputNormalizer.parseableVariant(of: text) != nil
    }

    private static func isJWT(_ text: String) -> Bool {
        let parts = text.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3 else { return false }
        let p0 = String(parts[0])
        guard p0.hasPrefix("eyJ") || p0.hasPrefix("ey") else { return false }
        guard parts.allSatisfy({ !$0.isEmpty }) else { return false }
        return true
    }

    private static func isUUID(_ text: String) -> Bool {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.contains("-") else { return false }
        guard let re = try? NSRegularExpression(
            pattern: #"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$"#,
            options: []
        ) else { return false }
        let ns = t as NSString
        return re.firstMatch(in: t, options: [], range: NSRange(location: 0, length: ns.length)) != nil
    }

    private static func isXML(_ text: String) -> Bool {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.hasPrefix("<") else { return false }
        if t.lowercased().hasPrefix("<!doctype") || t.lowercased().hasPrefix("<?xml") { return true }
        return t.contains("</") || t.contains("/>") || t.contains("<?xml")
    }

    private static func isBase64(_ text: String) -> Bool {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        guard (16...120_000).contains(t.count) else { return false }
        guard t.unicodeScalars.allSatisfy({ CharacterSet.base64URLCharset.contains($0) || $0 == "=" }) else { return false }
        guard isJWT(t) == false else { return false }
        var s = t
        while s.count % 4 != 0 { s += "=" }
        guard let data = Data(base64Encoded: s) else { return false }
        guard String(data: data, encoding: .utf8) != nil else { return false }
        return true
    }

    private static func isColor(_ text: String) -> Bool {
        ColorFormats.parse(text) != nil
    }

    private static func isDateTime(_ text: String) -> Bool {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.contains("/") || t.contains("T") || (t.contains("-") && t.contains(where: \.isNumber)) {
            if DateFormats.parseDate(from: t) != nil { return true }
        }
        if t.allSatisfy(\.isNumber), (12...13).contains(t.count) {
            return DateFormats.parseDate(from: t) != nil
        }
        return false
    }

    private static func isStandaloneEmail(_ text: String) -> Bool {
        guard !text.isEmpty, text.allSatisfy({ !$0.isNewline && !$0.isWhitespace }) else { return false }
        guard let re = try? NSRegularExpression(
            pattern: #"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$"#,
            options: []
        ) else { return false }
        let ns = text as NSString
        let range = NSRange(location: 0, length: ns.length)
        guard let m = re.firstMatch(in: text, options: [], range: range), m.range.length == ns.length else { return false }
        return true
    }

    private static func isURL(_ text: String) -> Bool {
        if isStandaloneEmail(text) { return false }
        if let u = URL(string: text), u.scheme != nil, u.host != nil {
            return true
        }
        guard !text.contains("://") else { return false }
        let candidate = "https://\(text)"
        guard let u = URL(string: candidate), let host = u.host else { return false }
        if u.user != nil {
            return false
        }
        return host.contains(".") || host.contains(":")
    }

    private static func isLikelyCEP(_ raw: String, digits: String) -> Bool {
        guard digits.count == 8 else { return false }
        if raw.contains(where: { $0.isLetter }) { return false }
        return true
    }

    private static func isPhoneBR(_ raw: String, digits: String) -> Bool {
        guard digits.count == 10 || digits.count == 11 else { return false }
        if digits.count == 11, isLikelyCPF(raw, digits: digits) {
            return false
        }
        let letters = raw.filter(\.isLetter).count
        if raw.contains(where: \.isNewline), letters >= 12 {
            return false
        }
        if raw.count > 90, letters >= 14 {
            return false
        }
        let ddd = Int(digits.prefix(2)) ?? 0
        guard (11...99).contains(ddd) else { return false }
        return true
    }

    private static func isPIXEVP(_ text: String) -> Bool {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.count == 32 else { return false }
        return t.allSatisfy(\.isHexDigit)
    }

    private static func isCurrencyBRL(_ text: String) -> Bool {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let ns = t as NSString
        let r = NSRange(location: 0, length: ns.length)
        if let re1 = try? NSRegularExpression(pattern: #"^\d{1,3}(\.\d{3})*,\d{2}$"#, options: []),
           re1.firstMatch(in: t, options: [], range: r) != nil {
            return true
        }
        guard let re2 = try? NSRegularExpression(pattern: #"^\d+,\d{2}$"#, options: []) else { return false }
        return re2.firstMatch(in: t, options: [], range: r) != nil
    }

    private static func isLikelyCPF(_ raw: String, digits: String) -> Bool {
        guard digits.count == 11 else { return false }
        let invalidAllEqual = Set(digits).count == 1
        if invalidAllEqual { return false }
        return validateCPFDigits(digits)
    }

    private static func isLikelyCNPJ(_ raw: String, digits: String) -> Bool {
        guard digits.count == 14 else { return false }
        let invalidAllEqual = Set(digits).count == 1
        if invalidAllEqual { return false }
        return validateCNPJDigits(digits)
    }

    private static func validateCPFDigits(_ d: String) -> Bool {
        let nums = d.compactMap { Int(String($0)) }
        guard nums.count == 11 else { return false }
        var sum1 = 0
        for i in 0..<9 {
            sum1 += nums[i] * (10 - i)
        }
        var r1 = (sum1 * 10) % 11
        if r1 == 10 { r1 = 0 }
        guard r1 == nums[9] else { return false }
        var sum2 = 0
        for i in 0..<10 {
            sum2 += nums[i] * (11 - i)
        }
        var r2 = (sum2 * 10) % 11
        if r2 == 10 { r2 = 0 }
        return r2 == nums[10]
    }

    private static func validateCNPJDigits(_ d: String) -> Bool {
        let nums = d.compactMap { Int(String($0)) }
        guard nums.count == 14 else { return false }
        let weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
        let weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
        let sum1 = zip(nums.prefix(12), weights1).map(*).reduce(0, +)
        let dv1 = sum1 % 11 < 2 ? 0 : 11 - sum1 % 11
        guard dv1 == nums[12] else { return false }
        let sum2 = zip(nums.prefix(13), weights2).map(*).reduce(0, +)
        let dv2 = sum2 % 11 < 2 ? 0 : 11 - sum2 % 11
        return dv2 == nums[13]
    }
}

private extension CharacterSet {
    static let base64URLCharset: CharacterSet = {
        var c = CharacterSet.alphanumerics
        c.insert(charactersIn: "+/=")
        return c
    }()
}
