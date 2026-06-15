import AppKit
import Sparkle

@MainActor
public final class SoftwareUpdateController: NSObject, SPUUpdaterDelegate {
    public static let shared = SoftwareUpdateController()

    private var updaterController: SPUStandardUpdaterController?
    private var hasStarted = false

    public var isConfigured: Bool {
        Self.appcastURLString != nil && Self.publicEDKey != nil
    }

    private override init() {
        super.init()
    }

    public func start() {
        guard !hasStarted else {
            return
        }
        hasStarted = true

        guard isConfigured else {
            NSLog("Sparkle updates are not configured. Add SUFeedURL and SUPublicEDKey to the app Info.plist.")
            return
        }

        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: self,
            userDriverDelegate: nil
        )
    }

    public func checkForUpdates() {
        start()

        guard let updaterController else {
            showNotConfiguredAlert()
            return
        }

        updaterController.checkForUpdates(nil)
    }

    public func feedURLString(for updater: SPUUpdater) -> String? {
        Self.appcastURLString
    }

    private func showNotConfiguredAlert() {
        let alert = NSAlert()
        alert.messageText = L10n.text("updates.notConfiguredTitle")
        alert.informativeText = L10n.text("updates.notConfiguredMessage")
        alert.addButton(withTitle: L10n.text("updates.notConfiguredOK"))
        alert.runModal()
    }

    private static var appcastURLString: String? {
        configuredString(forInfoKey: "SUFeedURL")
    }

    private static var publicEDKey: String? {
        configuredString(forInfoKey: "SUPublicEDKey")
    }

    private static func configuredString(forInfoKey key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.contains("REPLACE_ME") else {
            return nil
        }
        return trimmed
    }
}
