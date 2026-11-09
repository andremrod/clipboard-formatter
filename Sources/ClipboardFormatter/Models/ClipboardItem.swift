struct ClipboardItem: Sendable {
    let rawText: String
    let type: ClipboardType
    let actions: [ClipboardAction]
}
