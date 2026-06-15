import AppKit
import SwiftUI

@MainActor
final class EdgeWindowController {
    private var screen: NSScreen
    private let window: EdgeWindow
    private let progressView: ProgressBarView
    private let tooltipWindow: TooltipWindow
    private var position: BarPosition = PreferenceStore.barPosition
    private var hoverThickness: CGFloat = 5
    private var isHovering = false
    private var progressItems: [ProgressInfo] = []

    init(screen: NSScreen) {
        self.screen = screen
        progressItems = TimeProgress.snapshot()
        progressView = ProgressBarView(frame: .zero)
        window = EdgeWindow(frame: .zero)
        tooltipWindow = TooltipWindow()

        progressView.items = progressItems
        progressView.position = position
        progressView.thickness = PreferenceStore.barThickness
        progressView.opacity = PreferenceStore.barOpacity
        window.contentView = progressView
        applyCurrentPreferences()
    }

    func show() {
        window.orderFrontRegardless()
    }

    func close() {
        tooltipWindow.orderOut(nil)
        window.orderOut(nil)
    }

    func update(screen: NSScreen) {
        self.screen = screen
        applyCurrentPreferences()
    }

    func applyCurrentPreferences() {
        position = PreferenceStore.barPosition
        progressItems = TimeProgress.snapshot()

        progressView.items = progressItems
        progressView.position = position
        progressView.thickness = PreferenceStore.barThickness
        progressView.opacity = PreferenceStore.barOpacity
        progressView.needsDisplay = true

        window.setFrame(windowFrame(), display: true)
        window.ignoresMouseEvents = !isHovering
    }

    func refreshProgress() {
        progressItems = TimeProgress.snapshot()
        progressView.items = progressItems
        progressView.needsDisplay = true
    }

    func updateHover(globalMouseLocation: NSPoint) {
        let frame = window.frame
        let shouldHover = frame.insetBy(dx: -1, dy: -1).contains(globalMouseLocation)
        guard shouldHover || isHovering else {
            return
        }

        isHovering = shouldHover
        window.ignoresMouseEvents = !shouldHover
        progressView.isHovering = shouldHover
        progressView.needsDisplay = true

        guard shouldHover else {
            tooltipWindow.orderOut(nil)
            return
        }

        let windowPoint = NSPoint(
            x: globalMouseLocation.x - frame.minX,
            y: globalMouseLocation.y - frame.minY
        )
        if let item = progressView.item(at: windowPoint) {
            tooltipWindow.show(item: item, near: globalMouseLocation)
        }
    }

    private func windowFrame() -> NSRect {
        let count = max(1, PreferenceStore.enabledDimensions.count)
        let size = CGFloat(count) * hoverThickness
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame

        switch position {
        case .bottom:
            return NSRect(x: screenFrame.minX, y: screenFrame.minY, width: screenFrame.width, height: size)
        case .top:
            return NSRect(x: screenFrame.minX, y: visibleFrame.maxY - size, width: screenFrame.width, height: size)
        case .left:
            return NSRect(x: screenFrame.minX, y: screenFrame.minY, width: size, height: screenFrame.height)
        case .right:
            return NSRect(x: screenFrame.maxX - size, y: screenFrame.minY, width: size, height: screenFrame.height)
        }
    }
}

final class TooltipWindow: NSPanel {
    private let hostingView = NSHostingView(rootView: TooltipContentView(item: nil))

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 190, height: 72),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        level = .floating
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        contentView = hostingView
    }

    func show(item: ProgressInfo, near point: NSPoint) {
        hostingView.rootView = TooltipContentView(item: item)
        let frame = NSRect(x: point.x + 12, y: point.y + 12, width: 190, height: 72)
        setFrame(frame, display: true)
        orderFrontRegardless()
    }
}
