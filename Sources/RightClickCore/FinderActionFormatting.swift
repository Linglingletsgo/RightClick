import Foundation

public enum FinderActionFormatting {
    public static func paths(for urls: [URL]) -> String {
        urls.map(\.path).joined(separator: "\n")
    }

    public static func names(for urls: [URL]) -> String {
        urls.map(\.lastPathComponent).joined(separator: "\n")
    }
}
