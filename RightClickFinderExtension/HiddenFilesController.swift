import Foundation

enum HiddenFilesController {
    private static var finderBundleIdentifier: CFString {
        "com.apple.finder" as CFString
    }

    private static var settingKey: CFString {
        "AppleShowAllFiles" as CFString
    }

    static var isShowingHiddenFiles: Bool {
        isEnabled(CFPreferencesCopyAppValue(settingKey, finderBundleIdentifier))
    }

    static func toggle() {
        let nextValue = !isShowingHiddenFiles
        CFPreferencesSetValue(
            settingKey,
            nextValue as CFBoolean,
            finderBundleIdentifier,
            kCFPreferencesCurrentUser,
            kCFPreferencesAnyHost
        )
        CFPreferencesSynchronize(finderBundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
        restartFinder()
        ActionLogger.info(nextValue ? "Enabled hidden files in Finder" : "Disabled hidden files in Finder")
    }

    private static func isEnabled(_ value: Any?) -> Bool {
        switch value {
        case let boolValue as Bool:
            return boolValue
        case let numberValue as NSNumber:
            return numberValue.boolValue
        case let stringValue as String:
            return ["1", "true", "yes", "on"].contains(stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
        default:
            return false
        }
    }

    private static func restartFinder() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        process.arguments = ["Finder"]

        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus != 0 {
                ActionLogger.error("Could not restart Finder. killall exited with \(process.terminationStatus)")
            }
        } catch {
            ActionLogger.error("Could not restart Finder: \(error.localizedDescription)")
        }
    }
}
