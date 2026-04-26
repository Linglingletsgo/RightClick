import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private let viewModel = ConfigViewModel()
    private var settingsWindow: NSWindow?
    private var pendingInitialWindow: DispatchWorkItem?
    private var handledBackgroundCommand = false

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        scheduleInitialWindow()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls where url.scheme == "rightclick" {
            handle(url)
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showSettingsWindow()
        return false
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func showSettingsWindow() {
        pendingInitialWindow?.cancel()
        NSApp.setActivationPolicy(.regular)

        let window = settingsWindow ?? makeSettingsWindow()
        settingsWindow = window

        if window.isMiniaturized {
            window.deminiaturize(nil)
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func handle(_ url: URL) {
        switch url.host {
        case "toggle-hidden-files":
            handledBackgroundCommand = true
            pendingInitialWindow?.cancel()
            HiddenFilesController.toggle()
            terminateIfOnlyBackgroundCommand()
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

    private func scheduleInitialWindow() {
        let workItem = DispatchWorkItem { [weak self] in
            guard let self, !handledBackgroundCommand else { return }
            showSettingsWindow()
        }

        pendingInitialWindow = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }

    private func makeSettingsWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 760, height: 520),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "RightClick"
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.contentViewController = NSHostingController(
            rootView: ContentView(viewModel: viewModel)
                .frame(minWidth: 760, minHeight: 520)
        )
        return window
    }

    private func terminateIfOnlyBackgroundCommand() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            if settingsWindow?.isVisible != true {
                NSApp.terminate(nil)
            }
        }
    }
}
