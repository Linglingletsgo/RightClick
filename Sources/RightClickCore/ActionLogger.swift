import Foundation
import OSLog

public enum ActionLogger {
    private static let logger = Logger(subsystem: "com.dominicduan.RightClick", category: "actions")

    public static func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }

    public static func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }
}
