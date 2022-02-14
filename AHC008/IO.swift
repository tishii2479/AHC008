import Darwin.C
import Foundation

class IO {
    static func readInt() -> Int {
        guard let str = readLine(),
              let val = Int(str) else {
            fatalError("Failed to read integer")
        }
        return val
    }

    static func readIntArray() -> [Int] {
        guard let str = readLine() else {
            fatalError("Failed to read integer array")
        }
        let val: [Int] = str.components(separatedBy: " ").map {
            guard let i = Int($0) else {
                fatalError("Failed to parse integer array")
            }
            return i
        }
        return val
    }

    static func output(_ str: String) {
        print(str)
        flush()
    }

    static func log(_ str: String) {
        fputs(str + "\n", stderr)
    }

    static func flush() {
        fflush(stdout)
    }
}
