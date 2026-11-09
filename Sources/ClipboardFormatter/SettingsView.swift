import SwiftUI

struct SettingsView: View {
    @Environment(ClipboardService.self) private var clipboard
    @State private var launchAtLogin = false
    @State private var launchError: String?

    var body: some View {
        Form {
            Section {
                Toggle(
                    "Monitorar área de transferência",
                    isOn: Binding(
                        get: { clipboard.monitoringEnabled },
                        set: { new in
                            clipboard.monitoringEnabled = new
                            if new {
                                clipboard.startMonitoring()
                            } else {
                                clipboard.stopMonitoring()
                            }
                        }
                    )
                )
                .toggleStyle(.switch)
            } header: {
                Label("Clipboard", systemImage: "doc.on.clipboard")
            }

            Section {
                if LaunchAtLogin.isSupported {
                    Toggle("Abrir ao iniciar o login", isOn: $launchAtLogin)
                        .toggleStyle(.switch)
                        .onChange(of: launchAtLogin) { _, newValue in
                            do {
                                try LaunchAtLogin.setEnabled(newValue)
                                launchError = nil
                            } catch {
                                launchError = error.localizedDescription
                                launchAtLogin = LaunchAtLogin.statusIsEnabled()
                            }
                        }
                }
                if let launchError {
                    Text(launchError)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            } header: {
                Label("Sistema", systemImage: "gear")
            }

            Section {
                LabeledContent("Versão", value: "\(AppVersion.marketing) (\(AppVersion.build))")
            } header: {
                Label("Sobre", systemImage: "info.circle")
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(.thinMaterial)
        .frame(width: 440, height: 280)
        .clipShape(RoundedRectangle(cornerRadius: GlassChrome.radiusLarge, style: .continuous))
        .onAppear {
            launchAtLogin = LaunchAtLogin.statusIsEnabled()
        }
    }
}
