import AppKit
import SwiftUI

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var screenManager: ScreenManager?
    private var defaultsObserver: NSObjectProtocol?

    public override init() {
        super.init()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        syncLaunchAtLoginPreference()

        let manager = ScreenManager()
        manager.start()
        screenManager = manager

        configureStatusItem()
        showFirstLaunchAlertIfNeeded()

        defaultsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.configureStatusItem()
            }
        }
    }

    public func applicationWillTerminate(_ notification: Notification) {
        if let defaultsObserver {
            NotificationCenter.default.removeObserver(defaultsObserver)
        }
        screenManager?.stop()
    }

    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func configureStatusItem() {
        let shouldShow = UserDefaults.standard.bool(forKey: PreferenceKey.showMenuBarIcon)

        guard shouldShow else {
            if let statusItem {
                NSStatusBar.system.removeStatusItem(statusItem)
                self.statusItem = nil
            }
            return
        }

        if statusItem == nil {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        }

        statusItem?.button?.image = MenubarIcon.makeImage()
        statusItem?.button?.imagePosition = .imageOnly
        statusItem?.button?.target = self
        statusItem?.button?.action = #selector(togglePopover(_:))
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        if popover?.isShown == true {
            popover?.performClose(sender)
            return
        }

        let popover = NSPopover()
        popover.behavior = .transient
        popover.delegate = self
        popover.contentSize = NSSize(width: 280, height: 230)
        popover.contentViewController = NSHostingController(
            rootView: MenuBarPopoverView(
                onPreferences: { [weak self] in
                    self?.popover?.performClose(nil)
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    NSApp.activate(ignoringOtherApps: true)
                },
                onQuit: { NSApp.terminate(nil) }
            )
        )
        self.popover = popover
        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeFirstResponder(nil)
    }

    private func showFirstLaunchAlertIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: PreferenceKey.hasShownOnboarding) else {
            return
        }

        let alert = NSAlert()
        alert.messageText = L10n.text("onboarding.title")
        alert.informativeText = L10n.text("onboarding.message")
        alert.addButton(withTitle: L10n.text("onboarding.getStarted"))
        alert.runModal()

        UserDefaults.standard.set(true, forKey: PreferenceKey.hasShownOnboarding)
    }

    private func syncLaunchAtLoginPreference() {
        guard UserDefaults.standard.bool(forKey: PreferenceKey.launchAtLogin) else {
            return
        }
        LaunchAtLoginController.setEnabled(true)
    }
}

private enum MenubarIcon {
    static func makeImage() -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18))
        image.lockFocus()

        let bounds = NSRect(x: 2, y: 8, width: 14, height: 2)
        NSColor.labelColor.withAlphaComponent(0.22).setFill()
        bounds.fill()

        NSColor.labelColor.setFill()
        NSRect(x: 2, y: 8, width: 7, height: 2).fill()

        image.unlockFocus()
        image.isTemplate = true
        return image
    }
}
