import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
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

    @objc private func handleGetURLEvent(
        _ event: NSAppleEventDescriptor,
        withReplyEvent replyEvent: NSAppleEventDescriptor
    ) {
        guard let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
              let url = URL(string: urlString),
              url.scheme == "rightclick" else {
            ActionLogger.error("Could not read URL command from Apple event")
            return
        }

        handle(url)
    }
}
