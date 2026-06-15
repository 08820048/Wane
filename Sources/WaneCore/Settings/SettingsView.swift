import AppKit
import SwiftUI

public struct SettingsView: View {
    @AppStorage(PreferenceKey.appLanguage) private var appLanguage = AppLanguage.automatic.rawValue

    public init() {}

    public var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label(L10n.text("settings.tab.general"), systemImage: "gearshape") }

            ProgressBarsSettingsView()
                .tabItem { Label(L10n.text("settings.tab.progressBars"), systemImage: "chart.bar") }

            AppearanceSettingsView()
                .tabItem { Label(L10n.text("settings.tab.appearance"), systemImage: "paintpalette") }
        }
        .padding(20)
        .frame(width: 520, height: 390)
        .id(appLanguage)
    }
}

private struct GeneralSettingsView: View {
    @AppStorage(PreferenceKey.launchAtLogin) private var launchAtLogin = true
    @AppStorage(PreferenceKey.showMenuBarIcon) private var showMenuBarIcon = true
    @AppStorage(PreferenceKey.appLanguage) private var appLanguage = AppLanguage.automatic.rawValue

    var body: some View {
        Form {
            Toggle(L10n.text("general.launchAtLogin"), isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { newValue in
                    LaunchAtLoginController.setEnabled(newValue)
                }
            Toggle(L10n.text("general.showMenuBarIcon"), isOn: $showMenuBarIcon)

            Picker(L10n.text("general.language"), selection: $appLanguage) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.title).tag(language.rawValue)
                }
            }
            .pickerStyle(.menu)

            Text(L10n.text("general.backgroundNote"))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .formStyle(.grouped)
    }
}

private struct ProgressBarsSettingsView: View {
    @AppStorage(PreferenceKey.todayEnabled) private var todayEnabled = true
    @AppStorage(PreferenceKey.weekEnabled) private var weekEnabled = true
    @AppStorage(PreferenceKey.monthEnabled) private var monthEnabled = true
    @AppStorage(PreferenceKey.yearEnabled) private var yearEnabled = true
    @AppStorage(PreferenceKey.workStart) private var workStart = "09:00"
    @AppStorage(PreferenceKey.workEnd) private var workEnd = "18:00"
    @AppStorage(PreferenceKey.barPosition) private var barPosition = BarPosition.bottom.rawValue
    @AppStorage(PreferenceKey.barThickness) private var barThickness = 2.0

    var body: some View {
        Form {
            Toggle(TimeDimension.today.title, isOn: $todayEnabled)
            HStack {
                DatePicker(L10n.text("progress.workStart"), selection: timeBinding(for: $workStart), displayedComponents: .hourAndMinute)
                DatePicker(L10n.text("progress.workEnd"), selection: timeBinding(for: $workEnd), displayedComponents: .hourAndMinute)
            }

            Toggle(TimeDimension.week.title, isOn: $weekEnabled)
            Toggle(TimeDimension.month.title, isOn: $monthEnabled)
            Toggle(TimeDimension.year.title, isOn: $yearEnabled)

            Picker(L10n.text("progress.barPosition"), selection: $barPosition) {
                ForEach(BarPosition.allCases) { position in
                    Text(position.title).tag(position.rawValue)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Text(L10n.text("progress.barThickness"))
                Slider(value: $barThickness, in: 1...4, step: 1)
                Text(L10n.text("progress.thicknessValue", Int(barThickness)))
                    .font(.system(.body, design: .monospaced))
                    .frame(width: 44, alignment: .trailing)
            }
        }
        .formStyle(.grouped)
    }

    private func timeBinding(for value: Binding<String>) -> Binding<Date> {
        Binding<Date>(
            get: {
                let time = TimeOfDay(string: value.wrappedValue)
                return time.date(on: Date(), calendar: .current)
            },
            set: { date in
                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                value.wrappedValue = TimeOfDay(
                    hour: components.hour ?? 9,
                    minute: components.minute ?? 0
                ).storageString
            }
        )
    }
}

private struct AppearanceSettingsView: View {
    @AppStorage(PreferenceKey.todayColor) private var todayColor = "#ff4f9a"
    @AppStorage(PreferenceKey.weekColor) private var weekColor = "#f5a623"
    @AppStorage(PreferenceKey.monthColor) private var monthColor = "#2dd4bf"
    @AppStorage(PreferenceKey.yearColor) private var yearColor = "#a78bfa"
    @AppStorage(PreferenceKey.barOpacity) private var barOpacity = 0.7

    var body: some View {
        Form {
            ColorSelectionRow(title: L10n.text("appearance.todayColor"), colorHex: $todayColor)
            ColorSelectionRow(title: L10n.text("appearance.weekColor"), colorHex: $weekColor)
            ColorSelectionRow(title: L10n.text("appearance.monthColor"), colorHex: $monthColor)
            ColorSelectionRow(title: L10n.text("appearance.yearColor"), colorHex: $yearColor)

            HStack {
                Text(L10n.text("appearance.barOpacity"))
                Slider(value: $barOpacity, in: 0.2...1.0, step: 0.05)
                Text("\(Int((barOpacity * 100).rounded()))%")
                    .font(.system(.body, design: .monospaced))
                    .frame(width: 48, alignment: .trailing)
            }
        }
        .formStyle(.grouped)
    }
}

private struct ColorSelectionRow: View {
    let title: String
    @Binding var colorHex: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            ColorWell(colorHex: $colorHex)
                .frame(width: 44, height: 24)
                .help(L10n.text("appearance.chooseColorHelp"))
        }
    }
}

private struct ColorWell: NSViewRepresentable {
    @Binding var colorHex: String

    func makeNSView(context: Context) -> NSColorWell {
        let colorWell = NSColorWell(frame: NSRect(x: 0, y: 0, width: 44, height: 24))
        colorWell.isBordered = true
        colorWell.target = context.coordinator
        colorWell.action = #selector(Coordinator.colorDidChange(_:))
        colorWell.color = NSColor(hexString: colorHex) ?? .white
        return colorWell
    }

    func updateNSView(_ colorWell: NSColorWell, context: Context) {
        context.coordinator.update(colorHex: $colorHex)

        let nextColor = NSColor(hexString: colorHex) ?? .white
        if colorWell.color.hexString != nextColor.hexString {
            colorWell.color = nextColor
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(colorHex: $colorHex)
    }

    final class Coordinator: NSObject {
        private var colorHex: Binding<String>

        init(colorHex: Binding<String>) {
            self.colorHex = colorHex
        }

        func update(colorHex: Binding<String>) {
            self.colorHex = colorHex
        }

        @objc func colorDidChange(_ sender: NSColorWell) {
            colorHex.wrappedValue = sender.color.hexString
        }
    }
}
