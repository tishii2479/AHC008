class Player: Equatable {
    var pos: Position
    var id: Int
    var x: Int { pos.x }
    var y: Int { pos.y }

    init(pos: Position, id: Int) {
        self.pos = pos
        self.id = id
    }

    func applyMove(move: Move) {
        switch move {
        case .up:
            pos.y -= 1
        case .down:
            pos.y += 1
        case .left:
            pos.x -= 1
        case .right:
            pos.x += 1
        default:
            break
        }
    }
    
    static func ==(lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
}

struct Position: Equatable {
    var x: Int
    var y: Int
    
    var isValid: Bool {
        0 <= x && x < fieldSize && 0 <= y && y < fieldSize
    }
    
    static func +(lhs: Position, rhs: Position) -> Position {
        Position(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func ==(lhs: Position, rhs: Position) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    static let zero = Position(x: 0, y: 0)
    static let up = Position(x: 0, y: -1)
    static let down = Position(x: 0, y: 0)
    static let left = Position(x: -1, y: 0)
    static let right = Position(x: 1, y: 0)
}

enum Move: Character {
    case none = "."
    
    case up = "U"
    case down = "D"
    case left = "L"
    case right = "R"
    
    static func toEnum(_ c: Character) -> Move {
        guard let m = Move(rawValue: c) else {
            fatalError("Failed to convert move: \(c)")
        }
        return m
    }
    
    var delta: Position {
        switch self {
        case .up:
            return .up
        case .down:
            return .down
        case .left:
            return .left
        case .right:
            return .right
        default:
            return .zero
        }
    }
}

enum BlockMove: Character {
    case none = "."
    
    case up = "u"
    case down = "d"
    case left = "l"
    case right = "r"
    
    static func toEnum(_ c: Character) -> BlockMove {
        guard let m = BlockMove(rawValue: c) else {
            fatalError("Failed to convert block move: \(c)")
        }
        return m
    }
    
    var delta: Position {
        switch self {
        case .up:
            return .up
        case .down:
            return .down
        case .left:
            return .left
        case .right:
            return .right
        default:
            return .zero
        }
    }
}

class Human: Player {
    func applyBlockMove(move: BlockMove) {
        
    }
}

class Pet: Player {
    enum Kind: Int {
        case cow
        case pig
        case rabbit
        case dog
        case cat
    }
    
    var kind: Kind
    
    init(kind: Kind, pos: Position, id: Int) {
        self.kind = kind
        super.init(pos: pos, id: id)
    }
}
