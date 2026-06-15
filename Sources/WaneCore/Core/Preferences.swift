import AppKit
import Foundation

public enum PreferenceKey {
    static let launchAtLogin = "general.launchAtLogin"
    static let showMenuBarIcon = "general.showMenuBarIcon"
    static let hasShownOnboarding = "general.hasShownOnboarding"

    static let todayEnabled = "bars.today.enabled"
    static let weekEnabled = "bars.week.enabled"
    static let monthEnabled = "bars.month.enabled"
    static let yearEnabled = "bars.year.enabled"
    static let workStart = "bars.today.workStart"
    static let workEnd = "bars.today.workEnd"
    static let barPosition = "bars.position"
    static let barThickness = "bars.thickness"

    static let todayColor = "appearance.today.color"
    static let weekColor = "appearance.week.color"
    static let monthColor = "appearance.month.color"
    static let yearColor = "appearance.year.color"
    static let barOpacity = "appearance.barOpacity"
}

enum BarPosition: String, CaseIterable, Identifiable {
    case bottom
    case top
    case left
    case right

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bottom: "Bottom"
        case .top: "Top"
        case .left: "Left"
        case .right: "Right"
        }
    }

    var isHorizontal: Bool {
        self == .bottom || self == .top
    }
}

enum TimeDimension: String, CaseIterable, Identifiable {
    case today
    case week
    case month
    case year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: "Today"
        case .week: "This week"
        case .month: "This month"
        case .year: "This year"
        }
    }

    var enabledKey: String {
        switch self {
        case .today: PreferenceKey.todayEnabled
        case .week: PreferenceKey.weekEnabled
        case .month: PreferenceKey.monthEnabled
        case .year: PreferenceKey.yearEnabled
        }
    }

    var colorKey: String {
        switch self {
        case .today: PreferenceKey.todayColor
        case .week: PreferenceKey.weekColor
        case .month: PreferenceKey.monthColor
        case .year: PreferenceKey.yearColor
        }
    }
}

public enum PreferenceStore {
    public static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            PreferenceKey.launchAtLogin: true,
            PreferenceKey.showMenuBarIcon: true,
            PreferenceKey.todayEnabled: true,
            PreferenceKey.weekEnabled: true,
            PreferenceKey.monthEnabled: true,
            PreferenceKey.yearEnabled: true,
            PreferenceKey.workStart: "09:00",
            PreferenceKey.workEnd: "18:00",
            PreferenceKey.barPosition: BarPosition.bottom.rawValue,
            PreferenceKey.barThickness: 2.0,
            PreferenceKey.todayColor: "#ff4f9a",
            PreferenceKey.weekColor: "#f5a623",
            PreferenceKey.monthColor: "#2dd4bf",
            PreferenceKey.yearColor: "#a78bfa",
            PreferenceKey.barOpacity: 0.7
        ])
    }

    static var enabledDimensions: [TimeDimension] {
        TimeDimension.allCases.filter { UserDefaults.standard.bool(forKey: $0.enabledKey) }
    }

    static var workStart: TimeOfDay {
        TimeOfDay(string: UserDefaults.standard.string(forKey: PreferenceKey.workStart) ?? "09:00")
    }

    static var workEnd: TimeOfDay {
        TimeOfDay(string: UserDefaults.standard.string(forKey: PreferenceKey.workEnd) ?? "18:00")
    }

    static var barPosition: BarPosition {
        let rawValue = UserDefaults.standard.string(forKey: PreferenceKey.barPosition) ?? BarPosition.bottom.rawValue
        return BarPosition(rawValue: rawValue) ?? .bottom
    }

    static var barThickness: CGFloat {
        CGFloat(max(1.0, min(4.0, UserDefaults.standard.double(forKey: PreferenceKey.barThickness))))
    }

    static var barOpacity: CGFloat {
        CGFloat(max(0.2, min(1.0, UserDefaults.standard.double(forKey: PreferenceKey.barOpacity))))
    }

    static func color(for dimension: TimeDimension) -> NSColor {
        let hex = UserDefaults.standard.string(forKey: dimension.colorKey) ?? "#ffffff"
        return NSColor(hexString: hex) ?? .white
    }
}

struct TimeOfDay: Equatable {
    var hour: Int
    var minute: Int

    init(hour: Int, minute: Int) {
        self.hour = max(0, min(23, hour))
        self.minute = max(0, min(59, minute))
    }

    init(string: String) {
        let parts = string.split(separator: ":").compactMap { Int($0) }
        self.init(hour: parts.first ?? 9, minute: parts.dropFirst().first ?? 0)
    }

    var storageString: String {
        String(format: "%02d:%02d", hour, minute)
    }

    func date(on date: Date, calendar: Calendar) -> Date {
        calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: date
        ) ?? date
    }
}

extension NSColor {
    convenience init?(hexString: String) {
        var value = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("#") {
            value.removeFirst()
        }
        guard value.count == 6, let intValue = Int(value, radix: 16) else {
            return nil
        }

        let red = CGFloat((intValue >> 16) & 0xff) / 255.0
        let green = CGFloat((intValue >> 8) & 0xff) / 255.0
        let blue = CGFloat(intValue & 0xff) / 255.0

        self.init(calibratedRed: red, green: green, blue: blue, alpha: 1)
    }

    var hexString: String {
        guard let rgb = usingColorSpace(.sRGB) else {
            return "#ffffff"
        }

        let red = Int(round(rgb.redComponent * 255))
        let green = Int(round(rgb.greenComponent * 255))
        let blue = Int(round(rgb.blueComponent * 255))
        return String(format: "#%02x%02x%02x", red, green, blue)
    }
}
