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

        if let copyItem = copyMenuItem(config: config) {
            menu.addItem(copyItem)
        }

        if let openWithItem = openWithMenuItem(config.openWithApps, isEnabled: config.enabledItems.openWith) {
            menu.addItem(openWithItem)
        }

        if config.enabledItems.favorites {
            menu.addItem(openFolderMenuItem(config.favorites))
        }

        return menu
    }

    private func containerMenu(directory: URL, config: RightClickConfig) -> NSMenu {
        let menu = NSMenu(title: "RightClick")

        if let newFileItem = newFileMenuItem(config.newFileTemplates, isEnabled: config.enabledItems.newFile) {
            menu.addItem(newFileItem)
        }

        if config.enabledItems.favorites {
            menu.addItem(openFolderMenuItem(config.favorites))
        }

        menu.addItem(menuItem(title: hiddenFilesMenuTitle, action: #selector(toggleHiddenFiles(_:))))

        return menu
    }

    private func copyMenuItem(config: RightClickConfig) -> NSMenuItem? {
        let submenu = NSMenu(title: "Copy")

        if config.enabledItems.copyPath {
            submenu.addItem(menuItem(title: "Path", action: #selector(copyPath(_:))))
        }

        if config.enabledItems.copyName {
            submenu.addItem(menuItem(title: "Name", action: #selector(copyName(_:))))
        }

        guard submenu.numberOfItems > 0 else { return nil }
        return parentMenuItem(title: "Copy", submenu: submenu)
    }

    private func newFileMenuItem(_ templates: [NewFileTemplate], isEnabled: Bool) -> NSMenuItem? {
        guard isEnabled, !templates.isEmpty else { return nil }

        let submenu = NSMenu(title: "New")
        for template in templates {
            submenu.addItem(
                menuItem(
                    title: "\(template.name) File",
                    action: #selector(newFile(_:))
                )
            )
        }

        return parentMenuItem(title: "New", submenu: submenu)
    }

    private func openWithMenuItem(_ apps: [OpenWithApp], isEnabled: Bool) -> NSMenuItem? {
        guard isEnabled, !apps.isEmpty else { return nil }

        let submenu = NSMenu(title: "Open With")
        for app in apps {
            submenu.addItem(menuItem(title: app.name, action: #selector(openWith(_:))))
        }

        return parentMenuItem(title: "Open With", submenu: submenu)
    }

    private func openFolderMenuItem(_ folders: [FavoriteFolder]) -> NSMenuItem {
        let item = NSMenuItem(title: "Open Folder", action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: "Open Folder")

        if folders.isEmpty {
            let emptyItem = NSMenuItem(title: "No Folders", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            submenu.addItem(emptyItem)
        } else {
            for folder in folders {
                submenu.addItem(
                    menuItem(title: folder.name, action: #selector(openFolder(_:)))
                )
            }
        }

        item.submenu = submenu
        return item
    }

    private var hiddenFilesMenuTitle: String {
        HiddenFilesController.isShowingHiddenFiles ? "Hide Hidden Folders" : "Show Hidden Folders"
    }

    private func menuItem(title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    private func parentMenuItem(title: String, submenu: NSMenu) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.submenu = submenu
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
        guard let template = config.newFileTemplates.first(where: { sender.title == "\($0.name) File" }) else {
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
        guard let app = config.openWithApps.first(where: { sender.title == $0.name }) else {
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

    @objc private func openFolder(_ sender: NSMenuItem) {
        ActionLogger.info("Open Folder selected")
        let config = store.load()
        guard let folder = config.favorites.first(where: { $0.name == sender.title }) else {
            ActionLogger.error("Open folder target not found for menu title: \(sender.title)")
            return
        }
        actions.openFolder(folder)
    }

    @objc private func toggleHiddenFiles(_ sender: NSMenuItem) {
        ActionLogger.info("\(sender.title) selected")
        HiddenFilesController.toggle()
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
