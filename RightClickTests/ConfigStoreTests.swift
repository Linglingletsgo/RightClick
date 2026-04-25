import XCTest
@testable import RightClickCore

final class ConfigStoreTests: XCTestCase {
    func testLoadsDefaultConfigWhenFileDoesNotExist() throws {
        let directory = temporaryDirectory()
        let store = ConfigStore(configURL: directory.appendingPathComponent("missing.json"))

        let config = store.load()

        XCTAssertEqual(config.watchedFolders.first?.name, "Home")
    }

    func testSavesAndLoadsConfig() throws {
        let directory = temporaryDirectory()
        let configURL = directory.appendingPathComponent("config.json")
        let store = ConfigStore(configURL: configURL)
        var config = RightClickDefaults.config(homeDirectory: URL(fileURLWithPath: "/Users/example"))
        config.enabledItems.copyPath = false

        try store.save(config)

        XCTAssertFalse(store.load().enabledItems.copyPath)
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }
}
