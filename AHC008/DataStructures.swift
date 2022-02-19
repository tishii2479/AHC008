import Foundation

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
