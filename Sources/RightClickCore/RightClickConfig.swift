import Foundation

public struct RightClickConfig: Codable, Equatable, Sendable {
    public var watchedFolders: [WatchedFolder]
    public var enabledItems: EnabledMenuItems
    public var newFileTemplates: [NewFileTemplate]
    public var openWithApps: [OpenWithApp]
    public var favorites: [FavoriteFolder]

    public init(
        watchedFolders: [WatchedFolder],
        enabledItems: EnabledMenuItems,
        newFileTemplates: [NewFileTemplate],
        openWithApps: [OpenWithApp],
        favorites: [FavoriteFolder]
    ) {
        self.watchedFolders = watchedFolders
        self.enabledItems = enabledItems
        self.newFileTemplates = newFileTemplates
        self.openWithApps = openWithApps
        self.favorites = favorites
    }
}

public struct WatchedFolder: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var url: URL
    public var isDefault: Bool

    public init(id: UUID = UUID(), name: String, url: URL, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.url = url
        self.isDefault = isDefault
    }
}

public struct EnabledMenuItems: Codable, Equatable, Sendable {
    public var copyPath: Bool
    public var copyName: Bool
    public var newFile: Bool
    public var openWith: Bool
    public var favorites: Bool

    public init(
        copyPath: Bool = true,
        copyName: Bool = true,
        newFile: Bool = true,
        openWith: Bool = true,
        favorites: Bool = true
    ) {
        self.copyPath = copyPath
        self.copyName = copyName
        self.newFile = newFile
        self.openWith = openWith
        self.favorites = favorites
    }
}

public struct NewFileTemplate: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var fileExtension: String

    public init(id: UUID = UUID(), name: String, fileExtension: String) {
        self.id = id
        self.name = name
        self.fileExtension = fileExtension
    }
}

public struct OpenWithApp: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var bundleIdentifier: String?
    public var appURL: URL?

    public init(
        id: UUID = UUID(),
        name: String,
        bundleIdentifier: String? = nil,
        appURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.appURL = appURL
    }
}

public struct FavoriteFolder: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var url: URL

    public init(id: UUID = UUID(), name: String, url: URL) {
        self.id = id
        self.name = name
        self.url = url
    }
}
