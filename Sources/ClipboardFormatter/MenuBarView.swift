import AppKit
import SwiftUI

struct MenuBarView: View {
    @Environment(ClipboardService.self) private var clipboard

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerBar

            VStack(alignment: .leading, spacing: GlassChrome.chromePadding) {
                if let feedback = clipboard.feedbackMessage {
                    feedbackBanner(feedback)
                }

                if let item = clipboard.currentItem {
                    detectionSection(item)

                    actionsContainer(for: item)
                } else {
                    emptyState
                }

                Divider()
                    .padding(.vertical, 8)

                HStack {
                    Spacer(minLength: 0)
                    Button {
                        NSApplication.shared.terminate(nil)
                    } label: {
                        Label("Encerrar ClipboardFormatter", systemImage: "power")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding(GlassChrome.chromePadding)
        }
        .frame(minWidth: 380, maxWidth: 440)
        .glassPanelBackground()
        .background {
            MenuBarHostWindowFix()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var headerBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "doc.on.clipboard.fill")
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text("ClipboardFormatter")
                    .font(.headline)
                Text("Área de transferência inteligente")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            SettingsLink {
                Label("Ajustes", systemImage: "gearshape.fill")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.borderless)
            .font(.body.weight(.medium))
        }
        .padding(.horizontal, GlassChrome.chromePadding)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Divider()
                .opacity(0.45)
        }
    }

    private func feedbackBanner(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green, .secondary)
                .symbolRenderingMode(.palette)
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
            Spacer(minLength: 0)
        }
        .padding(12)
        .glassCard(cornerRadius: GlassChrome.radiusSmall, material: .ultraThinMaterial)
    }

    private func detectionSection(_ item: ClipboardItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.type.displayName)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)

            Text(preview(item.rawText))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(2)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .glassCard(cornerRadius: GlassChrome.radiusMedium, material: .thinMaterial)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clipboard")
                .font(.system(size: 36, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
            Text("Nada no clipboard")
                .font(.headline)
            Text("Copie texto, um link, JSON, cor ou código para ver sugestões automáticas.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 8)
        .glassCard(cornerRadius: GlassChrome.radiusMedium, material: .ultraThinMaterial)
    }

    private func preview(_ text: String) -> String {
        let t = text.replacingOccurrences(of: "\n", with: " ")
        let maxLen = 72
        if t.count <= maxLen { return t }
        let idx = t.index(t.startIndex, offsetBy: maxLen)
        return String(t[..<idx]) + "…"
    }

    @ViewBuilder
    private func actionsContainer(for item: ClipboardItem) -> some View {
        let actions = item.actions
        let needsScroll = actions.count > 9
        let stack = VStack(alignment: .leading, spacing: 4) {
            ForEach(actions) { action in
                actionRow(item: item, action: action)
            }
        }
        .frame(maxWidth: .infinity)

        if needsScroll {
            ScrollView {
                stack
            }
            .frame(minHeight: 72, maxHeight: 280)
            .clipShape(RoundedRectangle(cornerRadius: GlassChrome.radiusSmall, style: .continuous))
        } else {
            stack
        }
    }

    private func actionRow(item: ClipboardItem, action: ClipboardAction) -> some View {
        Button {
            clipboard.apply(action.kind)
        } label: {
            HStack(alignment: .center, spacing: 10) {
                Text(action.title)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if item.type == .color {
                    Text(FormatterService.apply(action.kind, to: item.rawText))
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background {
            RoundedRectangle(cornerRadius: GlassChrome.radiusSmall, style: .continuous)
                .fill(Color(nsColor: .quaternaryLabelColor).opacity(0.22))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
