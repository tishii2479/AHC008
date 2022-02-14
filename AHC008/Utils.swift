import Foundation

func readInt() -> Int {
    guard let str = readLine(),
          let val = Int(str) else {
        fatalError("Failed to read integer")
    }
    return val
}

func readIntArray() -> [Int] {
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
