import AppKit
import FinderSync
import Foundation

final class FinderSync: FIFinderSync {
    private let controller = FIFinderSyncController.default()
    private let store = ConfigStore()
    private let actions = FinderActions()
    private var lastSelectedURLs: [URL] = []
    private var lastContainerURL: URL?

    override init() {
        super.init()
        reloadObservedDirectories(from: store.load())
        ActionLogger.info("FinderSync initialized")
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        let config = store.load()
        reloadObservedDirectories(from: config)

        let selectedURLs = controller.selectedItemURLs() ?? []
        let targetedURL = controller.targetedURL()
        let context = MenuContextResolver.resolve(
            menuKind: rightClickMenuKind(from: menuKind),
            selectedURLs: selectedURLs,
            targetedURL: targetedURL,
            watchedFolders: config.watchedFolders.map(\.url)
        )
        ActionLogger.info(
            "Menu requested kind=\(menuKind) selected=\(selectedURLs.map(\.path).joined(separator: "|")) targeted=\(targetedURL?.path ?? "nil") context=\(context.logDescription)"
        )

        switch context {
        case .selectedItems(let urls):
            lastSelectedURLs = urls
            lastContainerURL = nil
            return selectedItemsMenu(urls: urls, config: config)
        case .container(let directory):
            lastSelectedURLs = []
            lastContainerURL = directory
            return containerMenu(directory: directory, config: config)
        case .unsupported:
            return nil
        }
    }

    private func selectedItemsMenu(urls: [URL], config: RightClickConfig) -> NSMenu {
        let menu = NSMenu(title: "RightClick")

        if config.enabledItems.copyPath {
            menu.addItem(menuItem(title: "Copy Path", action: #selector(copyPath(_:))))
        }

        if config.enabledItems.copyName {
            menu.addItem(menuItem(title: "Copy Name", action: #selector(copyName(_:))))
        }

        if config.enabledItems.openWith {
            for app in config.openWithApps {
                menu.addItem(menuItem(title: "Open with \(app.name)", action: #selector(openWith(_:))))
            }
        }

        if config.enabledItems.favorites {
            menu.addItem(favoritesMenuItem(config.favorites))
        }

        return menu
    }

    private func containerMenu(directory: URL, config: RightClickConfig) -> NSMenu {
        let menu = NSMenu(title: "RightClick")

        if config.enabledItems.newFile {
            for template in config.newFileTemplates {
                menu.addItem(
                    menuItem(
                        title: "New \(template.name) File",
                        action: #selector(newFile(_:))
                    )
                )
            }
        }

        if config.enabledItems.favorites {
            menu.addItem(favoritesMenuItem(config.favorites))
        }

        return menu
    }

    private func favoritesMenuItem(_ favorites: [FavoriteFolder]) -> NSMenuItem {
        let item = NSMenuItem(title: "Open Folder", action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: "Open Folder")

        if favorites.isEmpty {
            let emptyItem = NSMenuItem(title: "No Favorites", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            submenu.addItem(emptyItem)
        } else {
            for favorite in favorites {
                submenu.addItem(
                    menuItem(title: favorite.name, action: #selector(openFavorite(_:)))
                )
            }
        }

        item.submenu = submenu
        return item
    }

    private func menuItem(title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    private func reloadObservedDirectories(from config: RightClickConfig) {
        controller.directoryURLs = Set(config.watchedFolders.map(\.url))
    }

    private func rightClickMenuKind(from menuKind: FIMenuKind) -> RightClickMenuKind {
        switch menuKind {
        case .contextualMenuForItems:
            return .items
        case .contextualMenuForContainer:
            return .container
        default:
            return .unsupported
        }
    }

    @objc private func copyPath(_ sender: NSMenuItem) {
        ActionLogger.info("Copy Path selected")
        let urls = selectedURLsForAction()
        guard !urls.isEmpty else {
            ActionLogger.error("Copy Path missing selected URLs")
            return
        }
        actions.copyPaths(urls)
    }

    @objc private func copyName(_ sender: NSMenuItem) {
        ActionLogger.info("Copy Name selected")
        let urls = selectedURLsForAction()
        guard !urls.isEmpty else {
            ActionLogger.error("Copy Name missing selected URLs")
            return
        }
        actions.copyNames(urls)
    }

    @objc private func newFile(_ sender: NSMenuItem) {
        ActionLogger.info("New File selected")
        let config = store.load()
        guard let template = config.newFileTemplates.first(where: { sender.title == "New \($0.name) File" }) else {
            ActionLogger.error("New File template not found for menu title: \(sender.title)")
            return
        }

        guard let directory = directoryURLForAction() else {
            ActionLogger.error("New File missing target directory")
            return
        }

        actions.createFile(from: template, in: directory)
    }

    @objc private func openWith(_ sender: NSMenuItem) {
        ActionLogger.info("Open With selected")
        let config = store.load()
        guard let app = config.openWithApps.first(where: { sender.title == "Open with \($0.name)" }) else {
            ActionLogger.error("Open With app not found for menu title: \(sender.title)")
            return
        }

        let urls = selectedURLsForAction()
        guard !urls.isEmpty else {
            ActionLogger.error("Open With missing selected URLs")
            return
        }

        actions.open(urls, with: app)
    }

    @objc private func openFavorite(_ sender: NSMenuItem) {
        ActionLogger.info("Open Favorite selected")
        let config = store.load()
        guard let favorite = config.favorites.first(where: { $0.name == sender.title }) else {
            ActionLogger.error("Favorite not found for menu title: \(sender.title)")
            return
        }
        actions.openFavorite(favorite)
    }

    private func selectedURLsForAction() -> [URL] {
        let currentURLs = controller.selectedItemURLs() ?? []
        return currentURLs.isEmpty ? lastSelectedURLs : currentURLs
    }

    private func directoryURLForAction() -> URL? {
        if let targetedURL = controller.targetedURL() {
            return targetedURL
        }

        if let lastContainerURL {
            return lastContainerURL
        }

        return controller.selectedItemURLs()?.first?.deletingLastPathComponent()
    }
}

private extension RightClickMenuContext {
    var logDescription: String {
        switch self {
        case .selectedItems(let urls):
            return "selectedItems(\(urls.count))"
        case .container(let url):
            return "container(\(url.path))"
        case .unsupported:
            return "unsupported"
        }
    }
}
