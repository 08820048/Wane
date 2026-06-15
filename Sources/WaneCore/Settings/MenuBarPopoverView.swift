import AppKit
import Combine
import SwiftUI

struct MenuBarPopoverView: View {
    let onPreferences: () -> Void
    let onCheckForUpdates: () -> Void
    let onQuit: () -> Void

    @AppStorage(PreferenceKey.appLanguage) private var appLanguage = AppLanguage.automatic.rawValue
    @AppStorage(PreferenceKey.todayColor) private var todayColor = "#ff4f9a"
    @AppStorage(PreferenceKey.weekColor) private var weekColor = "#f5a623"
    @AppStorage(PreferenceKey.monthColor) private var monthColor = "#2dd4bf"
    @AppStorage(PreferenceKey.yearColor) private var yearColor = "#a78bfa"
    @State private var items = TimeProgress.snapshot()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 10) {
                ForEach(items) { item in
                    ProgressReadoutRow(item: item)
                }
            }

            Divider()

            HStack {
                FocuslessLinkButton(title: L10n.text("app.preferences"), action: onPreferences)
                Spacer()
                FocuslessLinkButton(title: L10n.text("updates.check"), action: onCheckForUpdates)
                Spacer()
                FocuslessLinkButton(title: L10n.text("popover.quit"), action: onQuit)
            }
        }
        .padding(16)
        .frame(width: 280)
        .onReceive(timer) { _ in
            items = TimeProgress.snapshot()
        }
        .onChange(of: appLanguage) { _ in
            items = TimeProgress.snapshot()
        }
    }
}

private struct FocuslessLinkButton: NSViewRepresentable {
    let title: String
    let action: () -> Void

    func makeNSView(context: Context) -> NoFocusButton {
        let button = NoFocusButton()
        button.isBordered = false
        button.bezelStyle = .inline
        button.focusRingType = .none
        button.target = context.coordinator
        button.action = #selector(Coordinator.performAction)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }

    func updateNSView(_ button: NoFocusButton, context: Context) {
        context.coordinator.action = action
        button.attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
                .foregroundColor: NSColor.linkColor
            ]
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    final class Coordinator: NSObject {
        var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func performAction() {
            action()
        }
    }
}

private final class NoFocusButton: NSButton {
    override var acceptsFirstResponder: Bool { false }
    override var canBecomeKeyView: Bool { false }
}

private struct ProgressReadoutRow: View {
    let item: ProgressInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.dimension.title)
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                Text(item.percentText)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
            }

            ProgressView(value: item.progress)
                .tint(Color(nsColor: PreferenceStore.color(for: item.dimension)))
        }
    }
}
