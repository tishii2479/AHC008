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
        
        for i in 0 ..< points.count - 1 {
            let from = points[i], to = points[i + 1]
            if from.x == to.x {
                if from.y < to.y {
                    for y in from.y ... to.y {
                        units.append(.init(kind: .block, pos: Position(x: from.x, y: y)))
                    }
                }
                else {
                    for y in to.y ... from.y {
                        units.append(.init(kind: .block, pos: Position(x: from.x, y: y)))
                    }
                    units.reverse()
                }
            }
            else if from.y == to.y {
                if from.x < to.x {
                    for x in from.x ... to.x {
                        units.append(.init(kind: .block, pos: Position(x: x, y: from.y)))
                    }
                }
                else {
                    for x in to.x ... from.x {
                        units.append(.init(kind: .block, pos: Position(x: x, y: from.y)))
                    }
                    units.reverse()
                }
            }
            else {
                IO.log("Points are not align at \(i)->\(i + 1), points: \(points)", type: .warn)
            }
        }
        
        return Schedule.Job(units: units)
    }
}

class CommandUtil {
    static func getCandidateMove(from delta: Position) -> [Command] {
        var cand = [Command]()
        if delta.x > 0 { cand.append(.moveRight) }
        if delta.x < 0 { cand.append(.moveLeft) }
        if delta.y < 0 { cand.append(.moveUp) }
        if delta.y > 0 { cand.append(.moveDown) }
        return cand
    }
    
    static func getBlock(from delta: Position) -> Command? {
        if delta.x > 0 { return .blockRight }
        if delta.x < 0 { return .blockLeft }
        if delta.y < 0 { return .blockUp }
        if delta.y > 0 { return .blockDown }
        return nil
    }
}

class Queue<T> {
    private var elements: [T] = []

    func push(_ value: T) {
        elements.append(value)
    }

    @discardableResult
    func pop() -> T? {
        guard !elements.isEmpty else {
            return nil
        }
        return elements.removeFirst()
    }

    var front: T? {
        elements.first
    }
    
    var tail: T? {
        elements.last
    }
    
    var isEmpty: Bool {
        elements.isEmpty
    }
}
