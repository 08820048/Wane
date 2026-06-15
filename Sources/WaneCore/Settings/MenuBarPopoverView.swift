import SwiftUI

struct MenuBarPopoverView: View {
    let onPreferences: () -> Void
    let onQuit: () -> Void

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
                Button("Preferences...", action: onPreferences)
                Spacer()
                Button("Quit", action: onQuit)
            }
            .buttonStyle(.link)
        }
        .padding(16)
        .frame(width: 280)
        .onReceive(timer) { _ in
            items = TimeProgress.snapshot()
        }
    }
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
