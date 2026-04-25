import Foundation

public enum RightClickDefaults {
    public static func config(
        homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser
    ) -> RightClickConfig {
        RightClickConfig(
            watchedFolders: [
                WatchedFolder(name: "Home", url: homeDirectory, isDefault: true)
            ],
            enabledItems: EnabledMenuItems(),
            newFileTemplates: [
                NewFileTemplate(name: "Markdown", fileExtension: "md"),
                NewFileTemplate(name: "Text", fileExtension: "txt"),
                NewFileTemplate(name: "Swift", fileExtension: "swift")
            ],
            openWithApps: [
                OpenWithApp(name: "TextEdit", bundleIdentifier: "com.apple.TextEdit"),
                OpenWithApp(name: "Terminal", bundleIdentifier: "com.apple.Terminal")
            ],
            favorites: [
                FavoriteFolder(
                    name: "Projects",
                    url: homeDirectory.appendingPathComponent("Projects", isDirectory: true)
                )
            ]
        )
    }
}
