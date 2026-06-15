import Foundation
import ServiceManagement

enum LaunchAtLoginController {
    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Unable to update launch-at-login setting: \(error.localizedDescription)")
        }
    }
}
