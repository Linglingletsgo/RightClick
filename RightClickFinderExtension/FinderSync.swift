import AppKit
import FinderSync
import Foundation

final class FinderSync: FIFinderSync {
    private let controller = FIFinderSyncController.default()
    private let store = ConfigStore()
    private let actions = FinderActions()

    override init() {
        super.init()
        reloadObservedDirectories(from: store.load())
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

        switch context {
        case .selectedItems(let urls):
            return selectedItemsMenu(urls: urls, config: config)
        case .container(let directory):
            return containerMenu(directory: directory, config: config)
        case .unsupported:
            return nil
        }
    }

    private func selectedItemsMenu(urls: [URL], config: RightClickConfig) -> NSMenu {
        let menu = NSMenu(title: "RightClick")

        if config.enabledItems.copyPath {
            menu.addItem(menuItem(title: "Copy Path", action: #selector(copyPath(_:)), payload: .urls(urls)))
        }

        if config.enabledItems.copyName {
            menu.addItem(menuItem(title: "Copy Name", action: #selector(copyName(_:)), payload: .urls(urls)))
        }

        if config.enabledItems.openWith {
            for app in config.openWithApps {
                menu.addItem(menuItem(title: "Open with \(app.name)", action: #selector(openWith(_:)), payload: .openWith(app, urls)))
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
                        action: #selector(newFile(_:)),
                        payload: .newFile(template, directory)
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
        let item = NSMenuItem(title: "Open Favorites", action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: "Open Favorites")

        if favorites.isEmpty {
            let emptyItem = NSMenuItem(title: "No Favorites", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            submenu.addItem(emptyItem)
        } else {
            for favorite in favorites {
                submenu.addItem(
                    menuItem(title: favorite.name, action: #selector(openFavorite(_:)), payload: .favorite(favorite))
                )
            }
        }

        item.submenu = submenu
        return item
    }

    private func menuItem(title: String, action: Selector, payload: FinderMenuPayload) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        item.representedObject = payload
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
        guard case .urls(let urls)? = sender.representedObject as? FinderMenuPayload else { return }
        actions.copyPaths(urls)
    }

    @objc private func copyName(_ sender: NSMenuItem) {
        guard case .urls(let urls)? = sender.representedObject as? FinderMenuPayload else { return }
        actions.copyNames(urls)
    }

    @objc private func newFile(_ sender: NSMenuItem) {
        guard case .newFile(let template, let directory)? = sender.representedObject as? FinderMenuPayload else { return }
        actions.createFile(from: template, in: directory)
    }

    @objc private func openWith(_ sender: NSMenuItem) {
        guard case .openWith(let app, let urls)? = sender.representedObject as? FinderMenuPayload else { return }
        actions.open(urls, with: app)
    }

    @objc private func openFavorite(_ sender: NSMenuItem) {
        guard case .favorite(let favorite)? = sender.representedObject as? FinderMenuPayload else { return }
        actions.openFavorite(favorite)
    }
}

private enum FinderMenuPayload {
    case urls([URL])
    case newFile(NewFileTemplate, URL)
    case openWith(OpenWithApp, [URL])
    case favorite(FavoriteFolder)
}
