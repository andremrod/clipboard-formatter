import AppKit
import Foundation
import Observation

@MainActor
@Observable
final class ClipboardService {
    private(set) var currentItem: ClipboardItem?
    var feedbackMessage: String?
    var monitoringEnabled = true

    private var timer: Timer?
    private var lastChangeCount: Int

    private static let pollInterval: TimeInterval = 0.78
    private static let pollTolerance: TimeInterval = 0.32

    init() {
        lastChangeCount = NSPasteboard.general.changeCount
        refreshFromPasteboard(isInitial: true)
        startMonitoring()
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    func startMonitoring() {
        stopMonitoring()
        guard monitoringEnabled else { return }
        let interval = Self.pollInterval
        let tol = Self.pollTolerance
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            MainActor.assumeIsolated {
                self.tick()
            }
        }
        timer?.tolerance = tol
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func tick() {
        guard monitoringEnabled else { return }
        let pb = NSPasteboard.general
        guard pb.changeCount != lastChangeCount else { return }
        lastChangeCount = pb.changeCount
        refreshFromPasteboard(isInitial: false)
    }

    private func refreshFromPasteboard(isInitial: Bool) {
        guard let str = NSPasteboard.general.string(forType: .string) else {
            if !isInitial {
                currentItem = nil
            }
            return
        }
        guard !str.isEmpty else {
            currentItem = nil
            return
        }
        let (type, actions) = autoreleasepool {
            ContentDetector.detect(str)
        }
        currentItem = ClipboardItem(rawText: str, type: type, actions: actions)
    }

    func apply(_ kind: ActionKind) {
        guard let item = currentItem else { return }
        let result = FormatterService.apply(kind, to: item.rawText)
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(result, forType: .string)
        lastChangeCount = pb.changeCount
        let (newType, actions) = autoreleasepool {
            ContentDetector.detect(result)
        }
        currentItem = ClipboardItem(rawText: result, type: newType, actions: actions)
        let msg = feedback(for: kind)
        feedbackMessage = msg
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            if self?.feedbackMessage == msg {
                self?.feedbackMessage = nil
            }
        }
    }

    private func feedback(for kind: ActionKind) -> String {
        switch kind {
        case .formatJSON: return "JSON formatado"
        case .minifyJSON: return "JSON minificado"
        case .maskCPF, .maskCNPJ, .maskPhoneBR, .maskCEP: return "Máscara aplicada"
        case .unmaskCPF, .unmaskCNPJ, .unmaskPhoneBR, .unmaskCEP: return "Só números"
        case .removeTrackingParameters: return "URL limpa"
        case .copyDomainOnly: return "Domínio copiado"
        case .urlEncode: return "Texto codificado (URL)"
        case .urlDecode: return "Texto decodificado"
        case .queryToJSON: return "Query em JSON"
        case .normalizePIXKey: return "Chave PIX normalizada"
        case .brlToDecimalPoint: return "Valor em decimal (ponto)"
        case .decimalPointToBrlFormatted: return "Valor em formato R$"
        case .uppercase: return "Maiúsculas"
        case .lowercase: return "Minúsculas"
        case .titleCase: return "Title case"
        case .removeDuplicateSpaces: return "Espaços ajustados"
        case .removeLineBreaks: return "Quebras removidas"
        case .normalizeSmartQuotes: return "Aspas normalizadas"
        case .linesJoinComma: return "Linhas unidas"
        case .commaSplitLines: return "Separado em linhas"
        case .tabsToSpaces4: return "Tabs convertidos"
        case .spacesToTabs4: return "Espaços em tabs"
        case .uuidLowerHyphens, .uuidUpperHyphens, .uuidCompactLower: return "UUID ajustado"
        case .jwtDecodePayload: return "Payload JWT copiado"
        case .base64Decode: return "Base64 decodificado"
        case .base64Encode: return "Base64 codificado"
        case .formatXML: return "XML formatado"
        case .minifyXML: return "XML minificado"
        case .colorToHex, .colorToRgb, .colorToRgba, .colorToHsl, .colorToHsla: return "Cor convertida"
        case .dateToShortBR: return "Data dd/MM/yyyy"
        case .dateToDMYY: return "Data dd/MM/aa"
        case .dateToUSMDY: return "Data MM/dd/yyyy (EUA)"
        case .dateToYMDSlash: return "Data yyyy/MM/dd"
        case .dateToISO8601: return "Data em ISO 8601"
        case .dateToUnixSeconds: return "Unix (segundos)"
        case .dateToReadablePTBR: return "Data legível"
        }
    }
}
