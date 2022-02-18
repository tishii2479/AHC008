import Foundation

class JobUtil {
    static func createSquareBlockJob(
        points: [Position],
        skipBlocks: [Position] = []
    ) -> Schedule.Job {
        var job = Schedule.Job(units: [])
        guard points.count > 0 else {
            IO.log("Points.count is 0", type: .warn)
            return job
        }
        for i in 0 ..< points.count - 1 {
            job += createLineBlockJob(from: points[i], to: points[i + 1], skipBlocks: skipBlocks)
        }
        return job
    }
    
    static func createLineBlockJob(
        from: Position,
        to: Position,
        skipBlocks: [Position] = []
    ) -> Schedule.Job {
        var units = [Schedule.Job.Unit]()
        let direction = CommandUtil.deltaToMoveCommand(delta: to - from).first?.delta ?? .zero
        if direction == .zero {
            IO.log("Direction is zero from \(from) to \(to)", type: .warn)
        }
        var current = from
        // Go to [from, to + direction)
        while current != to + direction {
            let movePosition = current + direction
            if movePosition.isValid {
                units.append(.init(kind: .move, pos: movePosition))
            }
            else {
                IO.log("Move position is invalid \(movePosition)", type: .warn)
            }
            if !skipBlocks.contains(current) {
                units.append(.init(kind: .block, pos: current))
            }
            current = movePosition
        }

        return Schedule.Job(units: units)
    }
    
    // Create blocks when moving a path [from, to]
    // ######
    // oooooo
    // ######
    static func createBlockJobWithMove(
        from: Position,
        to: Position,
        checkDirections: [Position],
        skipBlocks: [Position] = []
    ) -> Schedule.Job {
        var units = [Schedule.Job.Unit]()
        let direction = CommandUtil.deltaToMoveCommand(delta: to - from).first?.delta ?? .zero
        if direction == .zero {
            IO.log("Direction is zero from \(from) to \(to)", type: .warn)
        }
        var current = from
        units.append(.init(kind: .move, pos: from))
        // Go to [from, to + direction)
        while current != to + direction {
            for direction in checkDirections {
                let target = current + direction
                if skipBlocks.contains(target) { continue }
                units.append(.init(kind: .block, pos: target))
            }
            let movePosition = current + direction
            if movePosition.isValid {
                units.append(.init(kind: .move, pos: movePosition))
            }
            else {
                IO.log("Move position is invalid \(movePosition)", type: .warn)
            }
            current = movePosition
        }
        
        return Schedule.Job(units: units)
    }
}

class CommandUtil {
    static func deltaToMoveCommand(delta: Position) -> [Command] {
        var cand = [Command]()
        if delta.x > 0 { cand.append(.moveRight) }
        if delta.x < 0 { cand.append(.moveLeft) }
        if delta.y < 0 { cand.append(.moveUp) }
        if delta.y > 0 { cand.append(.moveDown) }
        return cand
    }
    
    // BFS to find move, but slow?
    static func getCandidateMove(from: Position, to: Position, field: Field) -> [Command] {
        let queue = Queue<Position>()
        var dist = [[Int]](repeating: [Int](repeating: 123456, count: fieldSize), count: fieldSize)
        queue.push(to)
        dist[to.y][to.x] = 0
        while !queue.isEmpty {
            guard let cur = queue.pop() else { break }
            // Prune unrequired search
            guard dist[cur.y][cur.x] < dist[from.y][from.x] else { break }

            for dir in Position.directions {
                let nxt = cur + dir
                guard nxt.isValid,
                      !field.checkBlock(at: nxt),
                      dist[nxt.y][nxt.x] > dist[cur.y][cur.x] + 1 else { continue }
                dist[nxt.y][nxt.x] = dist[cur.y][cur.x] + 1
                queue.push(nxt)
            }
        }
        var cand = [Command]()
        for dir in Position.directions {
            let nxt = from + dir
            if nxt.isValid && dist[from.y][from.x] == dist[nxt.y][nxt.x] + 1 {
                cand.append(deltaToMoveCommand(delta: dir)[0])
            }
        }
        return cand
    }
    
    static func deltaToBlockCommand(delta: Position) -> Command? {
        if delta.x > 0 { return .blockRight }
        if delta.x < 0 { return .blockLeft }
        if delta.y < 0 { return .blockUp }
        if delta.y > 0 { return .blockDown }
        return nil
    }
}

class Node<T> : Equatable {
    let id: UUID
    var value: T
    var next: Node?
    
    init(value: T, next: Node? = nil) {
        self.id = UUID()
        self.value = value
        self.next = next
    }
    
    static func == (lhs: Node<T>, rhs: Node<T>) -> Bool {
        lhs.id == rhs.id
    }
}

class Queue<T> {
    private(set) var frontNode: Node<T>?
    private(set) var tailNode: Node<T>?
    private(set) var count: Int = 0
    var elements: [T] {
        var res = [T]()
        var currentNode = frontNode
        while currentNode != tailNode {
            if let value = currentNode?.value {
                res.append(value)
            }
            currentNode = currentNode?.next
        }
        if let value = currentNode?.value {
            res.append(value)
        }
        return res
    }
    var isEmpty: Bool {
        frontNode == nil
    }
    var front: T? {
        frontNode?.value
    }
    var tail: T? {
        tailNode?.value
    }
    
    func pushFront(_ value: T) {
        count += 1
        frontNode = Node(value: value, next: frontNode)
        if tailNode == nil {
            tailNode = frontNode
        }
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
