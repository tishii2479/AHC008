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
