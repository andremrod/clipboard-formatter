enum ActionKind: String, Identifiable, Hashable, Sendable {
    case formatJSON
    case minifyJSON
    case maskCPF
    case unmaskCPF
    case maskCNPJ
    case unmaskCNPJ
    case removeTrackingParameters
    case copyDomainOnly
    case urlEncode
    case urlDecode
    case queryToJSON
    case maskPhoneBR
    case unmaskPhoneBR
    case maskCEP
    case unmaskCEP
    case normalizePIXKey
    case brlToDecimalPoint
    case decimalPointToBrlFormatted
    case uppercase
    case lowercase
    case titleCase
    case removeDuplicateSpaces
    case removeLineBreaks
    case normalizeSmartQuotes
    case linesJoinComma
    case commaSplitLines
    case tabsToSpaces4
    case spacesToTabs4
    case uuidLowerHyphens
    case uuidUpperHyphens
    case uuidCompactLower
    case jwtDecodePayload
    case base64Decode
    case base64Encode
    case formatXML
    case minifyXML
    case colorToHex
    case colorToRgb
    case colorToRgba
    case colorToHsl
    case colorToHsla
    case dateToShortBR
    case dateToUSMDY
    case dateToYMDSlash
    case dateToDMYY
    case dateToISO8601
    case dateToUnixSeconds
    case dateToReadablePTBR

    var id: String { rawValue }
}

struct ClipboardAction: Identifiable, Hashable, Sendable {
    let kind: ActionKind
    let title: String

    var id: ActionKind { kind }
}
