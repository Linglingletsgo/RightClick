import Foundation

public enum FileNameGenerator {
    public static func nextAvailableFileURL(
        in directory: URL,
        baseName: String = "Untitled",
        fileExtension: String,
        fileExists: (URL) -> Bool = { FileManager.default.fileExists(atPath: $0.path) }
    ) -> URL {
        let normalizedExtension = fileExtension.trimmingCharacters(in: CharacterSet(charactersIn: "."))
        var index = 1

        while true {
            let suffix = index == 1 ? "" : " \(index)"
            let fileName = "\(baseName)\(suffix).\(normalizedExtension)"
            let candidate = directory.appendingPathComponent(fileName, isDirectory: false)

            if !fileExists(candidate) {
                return candidate
            }

            index += 1
        }
    }
}
