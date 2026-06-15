import Foundation

public enum L10n {
    public static func text(_ key: String, _ arguments: CVarArg...) -> String {
        let format = localizedString(for: key)
        guard !arguments.isEmpty else {
            return format
        }

        return String(
            format: format,
            locale: Locale(identifier: localeIdentifier),
            arguments: arguments
        )
    }

    private static func localizedString(for key: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: bundle, value: key, comment: "")
    }

    private static var bundle: Bundle {
        let identifier = selectedLanguage.localizationIdentifier ?? systemLanguageIdentifier
        if let path = resourcesBundle.path(forResource: identifier, ofType: "lproj"),
           let localizedBundle = Bundle(path: path) {
            return localizedBundle
        }

        if let path = resourcesBundle.path(forResource: "en", ofType: "lproj"),
           let englishBundle = Bundle(path: path) {
            return englishBundle
        }

        return resourcesBundle
    }

    private static var localeIdentifier: String {
        selectedLanguage.localizationIdentifier ?? systemLanguageIdentifier
    }

    private static var selectedLanguage: AppLanguage {
        let rawValue = UserDefaults.standard.string(forKey: PreferenceKey.appLanguage) ?? AppLanguage.automatic.rawValue
        return AppLanguage(rawValue: rawValue) ?? .automatic
    }

    private static var systemLanguageIdentifier: String {
        let preferred = Locale.preferredLanguages.first ?? "en"
        if preferred.hasPrefix("zh-Hans") || preferred == "zh-CN" || preferred == "zh-SG" {
            return "zh-Hans"
        }
        return "en"
    }

    private static var resourcesBundle: Bundle {
        #if SWIFT_PACKAGE
        .module
        #else
        Bundle(for: BundleToken.self)
        #endif
    }
}

private final class BundleToken {
}
