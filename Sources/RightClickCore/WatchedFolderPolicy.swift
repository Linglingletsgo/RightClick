import Foundation

public enum WatchedFolderPolicy {
    private static let volumesPath = "/Volumes"
    private static let mobileDocumentsPathComponent = "/Library/Mobile Documents"
    private static let cloudStoragePathComponent = "/Library/CloudStorage"

    public static func allowsWatching(_ url: URL) -> Bool {
        !isExternalVolumeRoot(url) && !isCloudProviderLocation(url)
    }

    public static func allowedFolders(from folders: [WatchedFolder]) -> [WatchedFolder] {
        uniqueFolders(folders.filter { folder in
            folder.isDefault || allowsWatching(folder.url)
        })
    }

    public static func normalizedURL(_ url: URL) -> URL {
        url.resolvingSymlinksInPath().standardizedFileURL
    }

    private static func uniqueFolders(_ folders: [WatchedFolder]) -> [WatchedFolder] {
        var seen = Set<String>()

        return folders.compactMap { folder in
            var normalizedFolder = folder
            normalizedFolder.url = normalizedURL(folder.url)

            let path = normalizedFolder.url.path
            guard seen.insert(path).inserted else { return nil }
            return normalizedFolder
        }
    }

    public static func isExternalVolumeRoot(_ url: URL) -> Bool {
        let path = standardizedPath(url)
        guard path != volumesPath, path.hasPrefix(volumesPath + "/") else {
            return false
        }

        let relativePath = String(path.dropFirst((volumesPath + "/").count))
        return !relativePath.isEmpty && !relativePath.contains("/")
    }

    public static func isCloudProviderLocation(_ url: URL) -> Bool {
        let path = standardizedPath(normalizedURL(url))
        return path.contains(mobileDocumentsPathComponent) || path.contains(cloudStoragePathComponent)
    }

    private static func standardizedPath(_ url: URL) -> String {
        url.standardizedFileURL.path
    }
}
