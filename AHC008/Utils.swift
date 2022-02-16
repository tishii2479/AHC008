import Foundation

class JobUtil {
    static func createLineBlockJob(
        points: [Position],
        startPosition: Position? = nil
    ) -> Schedule.Job {
        var units = [Schedule.Job.Unit]()
        if let start = startPosition {
            units.append(.init(kind: .move, pos: start))
        }
        
        if points.count <= 1 {
            IO.log("Points count is \(points.count), \(points)", type: .warn)
        }
        
        // To avoid infinite loop
        let loopLimit: Int = 100
        
        if points.count > 0 {
            // Start position
            units.append(.init(kind: .block, pos: points[0]))
        }
        
        // ISSUE: Is not efficent on creating diagonal lines
        for i in 0 ..< points.count - 1 {
            var from = points[i]
            let to = points[i + 1]
            var loopCount: Int = 0
            while from != to {
                guard loopCount < loopLimit else {
                    IO.log("Loop limit exceeded from \(from) to \(to)", type: .warn)
                    break
                }
                guard let move = CommandUtil.getCandidateMove(delta: to - from).first else {
                    IO.log("Move not found from \(from) to \(to)", type: .warn)
                    break
                }
                units.append(.init(kind: .block, pos: from + move.delta))
                from += move.delta
                loopCount += 1
            }
        }
        
        return Schedule.Job(units: units)
    }
}

class CommandUtil {
    static func getCandidateMove(delta: Position) -> [Command] {
        var cand = [Command]()
        if delta.x > 0 { cand.append(.moveRight) }
        if delta.x < 0 { cand.append(.moveLeft) }
        if delta.y < 0 { cand.append(.moveUp) }
        if delta.y > 0 { cand.append(.moveDown) }
        return cand
    }
    
    // BFS to find move, but slow
    static func getCandidateMove(from: Position, to: Position, field: Field) -> [Command] {
        return []
    }
    
    static func getBlock(delta: Position) -> Command? {
        if delta.x > 0 { return .blockRight }
        if delta.x < 0 { return .blockLeft }
        if delta.y < 0 { return .blockUp }
        if delta.y > 0 { return .blockDown }
        return nil
    }
}

class Node<T> {
    var value: T
    var next: Node?
    
    init(value: T, next: Node? = nil) {
        self.value = value
        self.next = next
    }
}

class Queue<T> {
    private(set) var frontNode: Node<T>?
    private(set) var tailNode: Node<T>?
    private(set) var count: Int = 0
    var isEmpty: Bool {
        frontNode == nil
    }
    var front: T? {
        frontNode?.value
    }
    var tail: T? {
        tailNode?.value
    }
    
    func push(_ value: T) {
        count += 1
        if isEmpty {
            frontNode = Node(value: value, next: frontNode)
            if tailNode == nil {
                tailNode = frontNode
            }
            return
        }
        
        tailNode?.next = Node(value: value)
        tailNode = tailNode?.next
    }
    
    @discardableResult
    func pop() -> T? {
        defer {
            count -= 1
            frontNode = frontNode?.next
            if isEmpty {
                tailNode = nil
            }
        }
        return frontNode?.value
    }
}
