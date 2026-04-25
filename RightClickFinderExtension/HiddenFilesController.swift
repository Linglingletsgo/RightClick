import AppKit
import Foundation

enum HiddenFilesController {
    private static var finderBundleIdentifier: CFString {
        "com.apple.finder" as CFString
    }

    private static var settingKey: CFString {
        "AppleShowAllFiles" as CFString
    }

    static var isShowingHiddenFiles: Bool {
        CFPreferencesCopyAppValue(settingKey, finderBundleIdentifier) as? Bool ?? false
    }

    static func toggle() {
        let nextValue = !isShowingHiddenFiles
        CFPreferencesSetAppValue(settingKey, nextValue as CFBoolean, finderBundleIdentifier)
        CFPreferencesAppSynchronize(finderBundleIdentifier)
        restartFinder()
        ActionLogger.info(nextValue ? "Enabled hidden files in Finder" : "Disabled hidden files in Finder")
    }

    private static func restartFinder() {
        let finderApplications = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.finder")

        if finderApplications.isEmpty {
            openFinder()
            return
        }

        for application in finderApplications {
            application.terminate()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            openFinder()
        }
    }

    private static func openFinder() {
        let finderURL = URL(fileURLWithPath: "/System/Library/CoreServices/Finder.app", isDirectory: true)
        NSWorkspace.shared.openApplication(at: finderURL, configuration: NSWorkspace.OpenConfiguration()) { _, error in
            if let error {
                ActionLogger.error("Could not relaunch Finder: \(error.localizedDescription)")
            }
        }
    }
}
