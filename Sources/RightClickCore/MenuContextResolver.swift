import Foundation

public enum RightClickMenuKind: Equatable {
    case items
    case container
    case unsupported
}

public enum RightClickMenuContext: Equatable {
    case selectedItems([URL])
    case container(URL)
    case unsupported
}

public enum MenuContextResolver {
    public static func resolve(
        menuKind: RightClickMenuKind,
        selectedURLs: [URL],
        targetedURL: URL?,
        watchedFolders: [URL]
    ) -> RightClickMenuContext {
        switch menuKind {
        case .items:
            if let targetedURL,
               isCovered(targetedURL, by: watchedFolders),
               selectedURLs.allSatisfy({ !isInside($0, directory: targetedURL) }) {
                return .container(targetedURL)
            }

            guard !selectedURLs.isEmpty else { return .unsupported }
            return selectedURLs.allSatisfy { isCovered($0, by: watchedFolders) }
                ? .selectedItems(selectedURLs)
                : .unsupported

        case .container:
            guard let targetedURL else { return .unsupported }
            return isCovered(targetedURL, by: watchedFolders)
                ? .container(targetedURL)
                : .unsupported

        case .unsupported:
            return .unsupported
        }
    }

    public static func isCovered(_ url: URL, by watchedFolders: [URL]) -> Bool {
        let path = standardizedPath(url)

        return watchedFolders.contains { folder in
            let folderPath = standardizedPath(folder)
            return path == folderPath || path.hasPrefix(folderPath + "/")
        }
    }

    private static func isInside(_ url: URL, directory: URL) -> Bool {
        let path = standardizedPath(url)
        let directoryPath = standardizedPath(directory)
        return path == directoryPath || path.hasPrefix(directoryPath + "/")
    }

    private static func standardizedPath(_ url: URL) -> String {
        url.standardizedFileURL.path
    }
}
