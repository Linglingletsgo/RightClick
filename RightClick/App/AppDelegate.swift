import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls where url.scheme == "rightclick" {
            handle(url)
        }
    }

    private func handle(_ url: URL) {
        switch url.host {
        case "toggle-hidden-files":
            HiddenFilesController.toggle()
        default:
            ActionLogger.error("Unsupported URL command: \(url.absoluteString)")
        }
    }
}
