import Foundation

public enum ObservedDirectoryProvider {
    public static func directories(for folders: [WatchedFolder], homeDirectory: URL = UserHomeDirectory.current()) -> [URL] {
        let allowedFolders = WatchedFolderPolicy.allowedFolders(from: folders)
        var observed = allowedFolders.map(\.url)

        if allowedFolders.contains(where: { isHomeFolder($0.url, homeDirectory: homeDirectory) }) {
            observed.append(contentsOf: standardHomeDirectories(homeDirectory: homeDirectory))
        }

        return uniqueURLs(observed)
    }

    private static func standardHomeDirectories(homeDirectory: URL) -> [URL] {
        [
            homeDirectory.appendingPathComponent("Desktop", isDirectory: true),
            homeDirectory.appendingPathComponent("Documents", isDirectory: true),
            homeDirectory.appendingPathComponent("Downloads", isDirectory: true),
            homeDirectory.appendingPathComponent("Movies", isDirectory: true),
            homeDirectory.appendingPathComponent("Music", isDirectory: true),
            homeDirectory.appendingPathComponent("Pictures", isDirectory: true)
        ]
    }

    private static func isHomeFolder(_ url: URL, homeDirectory: URL) -> Bool {
        standardizedPath(url) == standardizedPath(homeDirectory)
    }

    private static func uniqueURLs(_ urls: [URL]) -> [URL] {
        var seen = Set<String>()
        var unique: [URL] = []

        for url in urls {
            let path = standardizedPath(url)
            guard seen.insert(path).inserted else { continue }
            unique.append(url)
        }

        return unique
    }

    private static func standardizedPath(_ url: URL) -> String {
        url.standardizedFileURL.path
    }
}
