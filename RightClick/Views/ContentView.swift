import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var viewModel: ConfigViewModel
    @State private var selection: SettingsSection? = .watchedFolders

    var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $selection) { section in
                Label(section.title, systemImage: section.systemImage)
                    .tag(section)
            }
            .listStyle(.sidebar)
            .navigationTitle("RightClick")
        } detail: {
            detailView
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .onChange(of: viewModel.config) { _, _ in
                    viewModel.persist()
                }
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection ?? .watchedFolders {
        case .watchedFolders:
            WatchedFoldersView(viewModel: viewModel)
        case .menuItems:
            MenuItemsView(viewModel: viewModel)
        case .newFileTemplates:
            NewFileTemplatesView(templates: viewModel.config.newFileTemplates)
        case .openWithApps:
            OpenWithAppsView(viewModel: viewModel)
        case .favorites:
            FavoritesView(viewModel: viewModel)
        }
    }
}

private enum SettingsSection: String, CaseIterable, Identifiable {
    case watchedFolders
    case menuItems
    case newFileTemplates
    case openWithApps
    case favorites

    var id: String { rawValue }

    var title: String {
        switch self {
        case .watchedFolders: "Watched Folders"
        case .menuItems: "Menu Items"
        case .newFileTemplates: "New File Templates"
        case .openWithApps: "Open With Apps"
        case .favorites: "Favorites"
        }
    }

    var systemImage: String {
        switch self {
        case .watchedFolders: "folder"
        case .menuItems: "switch.2"
        case .newFileTemplates: "doc.badge.plus"
        case .openWithApps: "app"
        case .favorites: "star"
        }
    }
}

private struct WatchedFoldersView: View {
    @ObservedObject var viewModel: ConfigViewModel

    var body: some View {
        SettingsPane(title: "Watched Folders") {
            Table(viewModel.config.watchedFolders) {
                TableColumn("Name") { folder in
                    HStack {
                        Text(folder.name)
                        if folder.isDefault {
                            Text("Default")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                TableColumn("Path") { folder in
                    Text(folder.url.path)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                TableColumn("") { folder in
                    Button {
                        viewModel.removeWatchedFolder(folder)
                    } label: {
                        Image(systemName: "minus.circle")
                    }
                    .buttonStyle(.borderless)
                    .disabled(folder.isDefault)
                    .help(folder.isDefault ? "The Home folder is always watched." : "Remove watched folder")
                }
                .width(44)
            }
            .frame(minHeight: 260)

            Button {
                chooseFolder { viewModel.addWatchedFolder($0) }
            } label: {
                Label("Add Folder", systemImage: "plus")
            }
        }
    }
}

private struct MenuItemsView: View {
    @ObservedObject var viewModel: ConfigViewModel

    var body: some View {
        SettingsPane(title: "Menu Items") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Copy Path", isOn: $viewModel.config.enabledItems.copyPath)
                Toggle("Copy Name", isOn: $viewModel.config.enabledItems.copyName)
                Toggle("New File", isOn: $viewModel.config.enabledItems.newFile)
                Toggle("Open With", isOn: $viewModel.config.enabledItems.openWith)
                Toggle("Favorites", isOn: $viewModel.config.enabledItems.favorites)
            }
            .toggleStyle(.switch)
        }
    }
}

private struct NewFileTemplatesView: View {
    let templates: [NewFileTemplate]

    var body: some View {
        SettingsPane(title: "New File Templates") {
            Table(templates) {
                TableColumn("Name", value: \.name)
                TableColumn("Extension") { template in
                    Text(".\(template.fileExtension)")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minHeight: 220)
        }
    }
}

private struct OpenWithAppsView: View {
    @ObservedObject var viewModel: ConfigViewModel

    var body: some View {
        SettingsPane(title: "Open With Apps") {
            Table(viewModel.config.openWithApps) {
                TableColumn("Name", value: \.name)
                TableColumn("Bundle ID") { app in
                    Text(app.bundleIdentifier ?? app.appURL?.path ?? "Unavailable")
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                TableColumn("") { app in
                    Button {
                        viewModel.removeOpenWithApp(app)
                    } label: {
                        Image(systemName: "minus.circle")
                    }
                    .buttonStyle(.borderless)
                    .help("Remove app")
                }
                .width(44)
            }
            .frame(minHeight: 260)

            Button {
                chooseApplication { viewModel.addOpenWithApp($0) }
            } label: {
                Label("Add App", systemImage: "plus")
            }
        }
    }
}

private struct FavoritesView: View {
    @ObservedObject var viewModel: ConfigViewModel

    var body: some View {
        SettingsPane(title: "Favorites") {
            Table(viewModel.config.favorites) {
                TableColumn("Name", value: \.name)
                TableColumn("Path") { favorite in
                    HStack {
                        Image(systemName: FileManager.default.fileExists(atPath: favorite.url.path) ? "checkmark.circle" : "exclamationmark.triangle")
                            .foregroundStyle(.secondary)
                        Text(favorite.url.path)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                TableColumn("") { favorite in
                    Button {
                        viewModel.removeFavorite(favorite)
                    } label: {
                        Image(systemName: "minus.circle")
                    }
                    .buttonStyle(.borderless)
                    .help("Remove favorite")
                }
                .width(44)
            }
            .frame(minHeight: 260)

            Button {
                chooseFolder { viewModel.addFavorite($0) }
            } label: {
                Label("Add Favorite", systemImage: "plus")
            }
        }
    }
}

private struct SettingsPane<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2.weight(.semibold))
            content
            Spacer(minLength: 0)
        }
    }
}

@MainActor
private func chooseFolder(onSelect: (URL) -> Void) {
    let panel = NSOpenPanel()
    panel.canChooseDirectories = true
    panel.canChooseFiles = false
    panel.allowsMultipleSelection = false

    if panel.runModal() == .OK, let url = panel.url {
        onSelect(url)
    }
}

@MainActor
private func chooseApplication(onSelect: (URL) -> Void) {
    let panel = NSOpenPanel()
    panel.directoryURL = URL(fileURLWithPath: "/Applications", isDirectory: true)
    panel.canChooseDirectories = false
    panel.canChooseFiles = true
    panel.allowedContentTypes = [.applicationBundle]
    panel.allowsMultipleSelection = false

    if panel.runModal() == .OK, let url = panel.url {
        onSelect(url)
    }
}
