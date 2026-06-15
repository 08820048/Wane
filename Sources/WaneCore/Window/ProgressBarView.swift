import AppKit

final class ProgressBarView: NSView {
    var items: [ProgressInfo] = []
    var position: BarPosition = .bottom
    var thickness: CGFloat = 2
    var hoverThickness: CGFloat = 5
    var opacity: CGFloat = 0.7
    var isHovering = false

    override var isFlipped: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard !items.isEmpty else {
            return
        }

        let slotSize = isHovering ? hoverThickness : thickness
        let trackColor = NSColor(white: 1, alpha: 0.06)

        for (index, item) in items.enumerated() {
            let slot = rectForSlot(index: index, thickness: slotSize)
            trackColor.setFill()
            slot.fill()

            var progressRect = slot
            switch position {
            case .bottom, .top:
                progressRect.size.width = slot.width * item.progress
            case .left, .right:
                progressRect.size.height = slot.height * item.progress
            }

            PreferenceStore.color(for: item.dimension)
                .withAlphaComponent(opacity)
                .setFill()
            progressRect.fill()
        }
    }

    func item(at point: NSPoint) -> ProgressInfo? {
        guard !items.isEmpty else {
            return nil
        }

        let slotSize = hoverThickness
        let rawIndex: Int

        switch position {
        case .bottom:
            rawIndex = Int(point.y / slotSize)
        case .top:
            rawIndex = Int((bounds.height - point.y) / slotSize)
        case .left:
            rawIndex = Int(point.x / slotSize)
        case .right:
            rawIndex = Int((bounds.width - point.x) / slotSize)
        }

        guard items.indices.contains(rawIndex) else {
            return nil
        }
        return items[rawIndex]
    }

    private func rectForSlot(index: Int, thickness: CGFloat) -> NSRect {
        switch position {
        case .bottom:
            return NSRect(x: 0, y: CGFloat(index) * thickness, width: bounds.width, height: thickness)
        case .top:
            return NSRect(
                x: 0,
                y: bounds.height - CGFloat(index + 1) * thickness,
                width: bounds.width,
                height: thickness
            )
        case .left:
            return NSRect(x: CGFloat(index) * thickness, y: 0, width: thickness, height: bounds.height)
        case .right:
            return NSRect(
                x: bounds.width - CGFloat(index + 1) * thickness,
                y: 0,
                width: thickness,
                height: bounds.height
            )
        }
    }
}
