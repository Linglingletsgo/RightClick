import ApplicationServices
import CoreGraphics
import Foundation

enum HiddenFilesController {
    private static let periodKeyCode: CGKeyCode = 47

    static func toggle() {
        guard hasAccessibilityPermission(promptIfNeeded: true) else {
            ActionLogger.error("Accessibility permission is required to post the hidden files shortcut")
            return
        }

        let source = CGEventSource(stateID: .hidSystemState)
        let flags: CGEventFlags = [.maskCommand, .maskShift]

        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: periodKeyCode, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: periodKeyCode, keyDown: false) else {
            ActionLogger.error("Could not create hidden files shortcut event")
            return
        }

        keyDown.flags = flags
        keyUp.flags = flags
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
        ActionLogger.info("Posted Shift-Command-. hidden files shortcut")
    }

    private static func hasAccessibilityPermission(promptIfNeeded: Bool) -> Bool {
        let promptKey = "AXTrustedCheckOptionPrompt"
        let options = [promptKey: promptIfNeeded] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }
}
