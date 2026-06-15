import SwiftUI
import WaneCore

@main
struct WaneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage(PreferenceKey.appLanguage) private var appLanguage = AppLanguage.automatic.rawValue

    init() {
        PreferenceStore.registerDefaults()
    }

    var body: some Scene {
        Settings {
            SettingsView()
                .id(appLanguage)
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button(L10n.text("app.preferences")) {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    NSApp.activate(ignoringOtherApps: true)
                }
                .keyboardShortcut(",", modifiers: .command)
            }

            CommandGroup(after: .appInfo) {
                Button(L10n.text("updates.check")) {
                    SoftwareUpdateController.shared.checkForUpdates()
                }
            }
        }
    }
}
