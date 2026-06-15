import SwiftUI

public struct SettingsView: View {
    public init() {}

    public var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }

            ProgressBarsSettingsView()
                .tabItem { Label("Progress Bars", systemImage: "chart.bar") }

            AppearanceSettingsView()
                .tabItem { Label("Appearance", systemImage: "paintpalette") }
        }
        .padding(20)
        .frame(width: 520, height: 390)
    }
}

extension Color {
    init(hexString: String) {
        self.init(nsColor: NSColor(hexString: hexString) ?? .white)
    }

    var hexString: String {
        NSColor(self).hexString
    }
}

private struct GeneralSettingsView: View {
    @AppStorage(PreferenceKey.launchAtLogin) private var launchAtLogin = true
    @AppStorage(PreferenceKey.showMenuBarIcon) private var showMenuBarIcon = true

    var body: some View {
        Form {
            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { newValue in
                    LaunchAtLoginController.setEnabled(newValue)
                }
            Toggle("Show menubar icon", isOn: $showMenuBarIcon)

            Text("Wane keeps running in the background when the settings window closes.")
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
            Toggle("Today", isOn: $todayEnabled)
            HStack {
                DatePicker("Work start", selection: timeBinding(for: $workStart), displayedComponents: .hourAndMinute)
                DatePicker("Work end", selection: timeBinding(for: $workEnd), displayedComponents: .hourAndMinute)
            }

            Toggle("This week", isOn: $weekEnabled)
            Toggle("This month", isOn: $monthEnabled)
            Toggle("This year", isOn: $yearEnabled)

            Picker("Bar position", selection: $barPosition) {
                ForEach(BarPosition.allCases) { position in
                    Text(position.title).tag(position.rawValue)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Slider(value: $barThickness, in: 1...4, step: 1)
                Text("\(Int(barThickness)) px")
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
            ColorPicker("Today color", selection: colorBinding(for: $todayColor))
            ColorPicker("This week color", selection: colorBinding(for: $weekColor))
            ColorPicker("This month color", selection: colorBinding(for: $monthColor))
            ColorPicker("This year color", selection: colorBinding(for: $yearColor))

            HStack {
                Slider(value: $barOpacity, in: 0.2...1.0, step: 0.05)
                Text("\(Int((barOpacity * 100).rounded()))%")
                    .font(.system(.body, design: .monospaced))
                    .frame(width: 48, alignment: .trailing)
            }
        }
        .formStyle(.grouped)
    }

    private func colorBinding(for value: Binding<String>) -> Binding<Color> {
        Binding<Color>(
            get: { Color(hexString: value.wrappedValue) },
            set: { value.wrappedValue = $0.hexString }
        )
    }
}
