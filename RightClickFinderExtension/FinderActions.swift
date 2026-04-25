import AppKit
import Foundation

final class FinderActions {
    func copyPaths(_ urls: [URL]) {
        copyToPasteboard(FinderActionFormatting.paths(for: urls))
    }

    func copyNames(_ urls: [URL]) {
        copyToPasteboard(FinderActionFormatting.names(for: urls))
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

        guard FileManager.default.createFile(atPath: fileURL.path, contents: Data()) else {
            ActionLogger.error("Could not create file: \(fileURL.path)")
            return
        }

        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
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
            }
        }
    }

    func openFavorite(_ favorite: FavoriteFolder) {
        guard FileManager.default.fileExists(atPath: favorite.url.path) else {
            ActionLogger.error("Favorite does not exist: \(favorite.url.path)")
            return
        }

        NSWorkspace.shared.open(favorite.url)
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
