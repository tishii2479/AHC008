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
