import AppKit
import SwiftUI

@main
struct ClipboardFormatterApp: App {
    @State private var clipboard = ClipboardService()

    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra("ClipboardFormatter", systemImage: "doc.on.clipboard.fill") {
            MenuBarView()
                .environment(clipboard)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environment(clipboard)
        }
    }
}
