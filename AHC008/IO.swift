#if os(Linux)
import Glibc
#else
import Darwin.C
#endif
import Foundation

class IO {}

extension IO {

    // MARK: Input

    static func readStringArray() -> [String] {
        guard let str = readLine() else {
            fatalError("Failed to read integer array")
        }
        return str.components(separatedBy: " ")
    }

    static func readIntArray() -> [Int] {
        let val: [Int] = readStringArray().map {
            guard let i = Int($0) else {
                fatalError("Failed to parse integer array")
            }
            return i
        }
        return val
    }

    static func readInt() -> Int {
        let arr = readIntArray()
        guard arr.count == 1 else {
            fatalError("Failed to read integer")
        }
        return arr[0]
    }
    
    static func readString() -> String {
        let arr = readStringArray()
        guard arr.count == 1 else {
            fatalError("Failed to read string")
        }
        return arr[0]
    }
    
}

extension IO {

    // MARK: Output
    
    enum LogType: String {
        case none   = ""
        case info   = "[INFO]"
        case warn   = "[WARN]"
        case error  = "[ERROR]"
        case out    = "[OUT]"
    }
    
    static func output(_ str: String) {
        print(str)
        flush()
    }
    
    static func log(
        _ items: Any...,
        separator: String = " ",
        terminator: String = "\n",
        type: LogType = .none
    ) {
//        if type == .error || type == .warn {
            let output =
                "[LOG]" + type.rawValue + " "
                + items.map { "\($0)" }.joined(separator: separator)
                + terminator
            fputs(output, stderr)
//        }
    }

    static func flush() {
        fflush(stdout)
    }
}
