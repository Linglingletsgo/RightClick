import Darwin
import Foundation

public enum UserHomeDirectory {
    public static func current() -> URL {
        if let passwd = getpwuid(getuid()),
           let homePath = passwd.pointee.pw_dir {
            return URL(fileURLWithPath: String(cString: homePath), isDirectory: true)
        }

        return FileManager.default.homeDirectoryForCurrentUser
    }
}
