import Foundation

public enum RightClickDefaults {
    public static func config(
        homeDirectory: URL = UserHomeDirectory.current()
    ) -> RightClickConfig {
        RightClickConfig(
            watchedFolders: [
                WatchedFolder(name: "Home", url: homeDirectory, isDefault: true)
            ],
            enabledItems: EnabledMenuItems(),
            newFileTemplates: [
                NewFileTemplate(name: "Markdown", fileExtension: "md"),
                NewFileTemplate(name: "Text", fileExtension: "txt"),
                NewFileTemplate(name: "Swift", fileExtension: "swift"),
                NewFileTemplate(name: "Word", fileExtension: "docx"),
                NewFileTemplate(name: "Excel", fileExtension: "xlsx"),
                NewFileTemplate(name: "PowerPoint", fileExtension: "pptx")
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
