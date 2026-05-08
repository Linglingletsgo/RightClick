import AppKit
import Foundation

final class FinderActions {
    func copyPaths(_ urls: [URL]) {
        let value = FinderActionFormatting.paths(for: urls)
        copyToPasteboard(value)
        ActionLogger.info("Copied \(urls.count) path(s) to pasteboard")
    }

    func copyNames(_ urls: [URL]) {
        let value = FinderActionFormatting.names(for: urls)
        copyToPasteboard(value)
        ActionLogger.info("Copied \(urls.count) name(s) to pasteboard")
    }

    func createFile(from template: NewFileTemplate, in directory: URL) {
        guard FileManager.default.fileExists(atPath: directory.path) else {
            ActionLogger.error("Target directory does not exist: \(directory.path)")
            return
        }

        let fileURL = FileNameGenerator.nextAvailableFileURL(
            in: directory,
            fileExtension: template.fileExtension
        )

        let contents = OfficeTemplateData.data(forFileExtension: template.fileExtension) ?? Data()

        guard FileManager.default.createFile(atPath: fileURL.path, contents: contents) else {
            ActionLogger.error("Could not create file: \(fileURL.path)")
            return
        }

        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
        ActionLogger.info("Created file: \(fileURL.path)")
    }

    func open(_ urls: [URL], with app: OpenWithApp) {
        guard let appURL = resolveApplicationURL(app) else {
            ActionLogger.error("Application not found: \(app.name)")
            return
        }

        let targetURLs = app.bundleIdentifier == "com.apple.Terminal" ? terminalTargets(for: urls) : urls
        guard !targetURLs.isEmpty else { return }

        NSWorkspace.shared.open(
            targetURLs,
            withApplicationAt: appURL,
            configuration: NSWorkspace.OpenConfiguration()
        ) { _, error in
            if let error {
                ActionLogger.error("Could not open with \(app.name): \(error.localizedDescription)")
            } else {
                ActionLogger.info("Opened \(targetURLs.count) item(s) with \(app.name)")
            }
        }
    }

    func openFolder(_ folder: FavoriteFolder) {
        guard FileManager.default.fileExists(atPath: folder.url.path) else {
            ActionLogger.error("Open folder target does not exist: \(folder.url.path)")
            return
        }

        guard var components = URLComponents(string: "rightclick://open-folder") else {
            ActionLogger.error("Could not create open-folder command")
            return
        }

        components.queryItems = [
            URLQueryItem(name: "url", value: folder.url.absoluteString)
        ]

        guard let commandURL = components.url else {
            ActionLogger.error("Could not encode open-folder command for: \(folder.url.path)")
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-g", "-j", commandURL.absoluteString]

        do {
            try process.run()
            ActionLogger.info("Dispatched open folder command: \(folder.url.path)")
        } catch {
            ActionLogger.error("Could not dispatch open folder command: \(error.localizedDescription)")
        }
    }

    private func copyToPasteboard(_ value: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
    }

    private func resolveApplicationURL(_ app: OpenWithApp) -> URL? {
        if let bundleIdentifier = app.bundleIdentifier,
           let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            return url
        }

        return app.appURL
    }

    private func terminalTargets(for urls: [URL]) -> [URL] {
        var seen = Set<String>()

        return urls.compactMap { url in
            let directory = url.hasDirectoryPath ? url : url.deletingLastPathComponent()
            let path = directory.standardizedFileURL.path
            guard !seen.contains(path) else { return nil }
            seen.insert(path)
            return directory
        }
    }
}
