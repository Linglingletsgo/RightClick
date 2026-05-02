import AppKit
import Combine
import Foundation

@MainActor
final class ConfigViewModel: ObservableObject {
    @Published var config: RightClickConfig
    @Published var errorMessage: String?

    private let store: ConfigStore

    init(store: ConfigStore = ConfigStore()) {
        self.store = store
        self.config = store.load()
        persist()
    }

    func persist() {
        do {
            try store.save(config)
            errorMessage = nil
        } catch {
            errorMessage = "Could not save settings: \(error.localizedDescription)"
            ActionLogger.error(errorMessage ?? "Could not save settings.")
        }
    }

    func addWatchedFolder(_ url: URL) {
        let normalizedURL = WatchedFolderPolicy.normalizedURL(url)

        guard WatchedFolderPolicy.allowsWatching(normalizedURL) else {
            errorMessage = WatchedFolderPolicy.isCloudProviderLocation(normalizedURL)
                ? "iCloud Drive and other cloud provider folders are not supported."
                : "Choose a folder inside the external drive instead of the drive itself."
            ActionLogger.error(errorMessage ?? "Unsupported watched folder.")
            return
        }

        guard !config.watchedFolders.contains(where: { WatchedFolderPolicy.normalizedURL($0.url) == normalizedURL }) else {
            return
        }

        config.watchedFolders.append(
            WatchedFolder(name: normalizedURL.lastPathComponent, url: normalizedURL, isDefault: false)
        )
        persist()
    }

    func removeWatchedFolder(_ folder: WatchedFolder) {
        guard !folder.isDefault else { return }
        config.watchedFolders.removeAll { $0.id == folder.id }
        persist()
    }

    func addOpenWithApp(_ url: URL) {
        let bundle = Bundle(url: url)
        let bundleIdentifier = bundle?.bundleIdentifier
        guard !config.openWithApps.contains(where: { $0.bundleIdentifier == bundleIdentifier && bundleIdentifier != nil }) else {
            return
        }

        config.openWithApps.append(
            OpenWithApp(name: url.deletingPathExtension().lastPathComponent, bundleIdentifier: bundleIdentifier, appURL: url)
        )
        persist()
    }

    func removeOpenWithApp(_ app: OpenWithApp) {
        config.openWithApps.removeAll { $0.id == app.id }
        persist()
    }

    func addFavorite(_ url: URL) {
        guard !config.favorites.contains(where: { $0.url.standardizedFileURL == url.standardizedFileURL }) else {
            return
        }

        config.favorites.append(FavoriteFolder(name: url.lastPathComponent, url: url))
        persist()
    }

    func removeFavorite(_ favorite: FavoriteFolder) {
        config.favorites.removeAll { $0.id == favorite.id }
        persist()
    }
}
