import AppKit
import SwiftUI

struct MenuBarHostWindowFix: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let v = NSView()
        v.isHidden = true
        return v
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let w = nsView.window else { return }
            w.isOpaque = false
            w.backgroundColor = .clear
            w.contentView?.wantsLayer = true
            w.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
        }
    }
}
