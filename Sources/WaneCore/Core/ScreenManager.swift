import AppKit

@MainActor
final class ScreenManager {
    private var controllers: [String: EdgeWindowController] = [:]
    private var screenObserver: NSObjectProtocol?
    private var defaultsObserver: NSObjectProtocol?
    private var localMouseMonitor: Any?
    private var globalMouseMonitor: Any?
    private var timer: Timer?

    func start() {
        rebuildWindows()

        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.rebuildWindows() }
        }

        defaultsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refreshSettings() }
        }

        localMouseMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            Task { @MainActor in self?.updateHover(at: NSEvent.mouseLocation) }
            return event
        }

        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] _ in
            Task { @MainActor in self?.updateHover(at: NSEvent.mouseLocation) }
        }

        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refreshProgress() }
        }
    }

    func stop() {
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }
        if let defaultsObserver {
            NotificationCenter.default.removeObserver(defaultsObserver)
        }
        if let localMouseMonitor {
            NSEvent.removeMonitor(localMouseMonitor)
        }
        if let globalMouseMonitor {
            NSEvent.removeMonitor(globalMouseMonitor)
        }
        timer?.invalidate()
        controllers.values.forEach { $0.close() }
        controllers.removeAll()
    }

    private func rebuildWindows() {
        let screens = NSScreen.screens
        let currentIDs = Set(screens.map(screenID))

        for (id, controller) in controllers where !currentIDs.contains(id) {
            controller.close()
            controllers[id] = nil
        }

        for screen in screens {
            let id = screenID(screen)
            if let controller = controllers[id] {
                controller.update(screen: screen)
            } else {
                let controller = EdgeWindowController(screen: screen)
                controllers[id] = controller
                controller.show()
            }
        }
    }

    private func refreshSettings() {
        controllers.values.forEach { $0.applyCurrentPreferences() }
    }

    private func refreshProgress() {
        controllers.values.forEach { $0.refreshProgress() }
    }

    private func updateHover(at point: NSPoint) {
        controllers.values.forEach { $0.updateHover(globalMouseLocation: point) }
    }

    private func screenID(_ screen: NSScreen) -> String {
        if let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber {
            return number.stringValue
        }
        return "\(screen.frame.origin.x),\(screen.frame.origin.y),\(screen.frame.width),\(screen.frame.height)"
    }
}
