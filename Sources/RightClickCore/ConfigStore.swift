import Foundation

public final class ConfigStore {
    public let configURL: URL
    private let fileManager: FileManager
    private let decoder = JSONDecoder()
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    public init(
        configURL: URL = ConfigStore.defaultConfigURL(),
        fileManager: FileManager = .default
    ) {
        self.configURL = configURL
        self.fileManager = fileManager
    }

    public func load() -> RightClickConfig {
        guard
            let data = try? Data(contentsOf: configURL),
            let config = try? decoder.decode(RightClickConfig.self, from: data)
        else {
            return RightClickDefaults.config()
        }

        return Self.mergedWithDefaults(config)
    }

    public func save(_ config: RightClickConfig) throws {
        let directory = configURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try encoder.encode(config)
        try data.write(to: configURL, options: .atomic)
    }

    public static func defaultConfigURL() -> URL {
        let directory = UserHomeDirectory.current()
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
            .appendingPathComponent("RightClick", isDirectory: true)

        return directory.appendingPathComponent("config.json", isDirectory: false)
    }

    private static func mergedWithDefaults(_ config: RightClickConfig) -> RightClickConfig {
        let defaults = RightClickDefaults.config()
        var merged = config
        var existingTemplateExtensions = Set(config.newFileTemplates.map { $0.fileExtension.lowercased() })

        for template in defaults.newFileTemplates where !existingTemplateExtensions.contains(template.fileExtension.lowercased()) {
            merged.newFileTemplates.append(template)
            existingTemplateExtensions.insert(template.fileExtension.lowercased())
        }

        return merged
    }
}
