import SwiftUI

enum GlassChrome {
    static let radiusLarge: CGFloat = 16
    static let radiusMedium: CGFloat = 12
    static let radiusSmall: CGFloat = 10
    static let chromePadding: CGFloat = 16
}

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = GlassChrome.radiusMedium
    var material: Material = .ultraThinMaterial

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(material)
            }
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = GlassChrome.radiusMedium, material: Material = .ultraThinMaterial) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, material: material))
    }
}

struct GlassPanelBackground: ViewModifier {
    func body(content: Content) -> some View {
        let r = GlassChrome.radiusLarge
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: r, style: .continuous)
                .fill(.thinMaterial)
            content
        }
        .clipShape(RoundedRectangle(cornerRadius: r, style: .continuous))
    }
}

extension View {
    func glassPanelBackground() -> some View {
        modifier(GlassPanelBackground())
    }
}
