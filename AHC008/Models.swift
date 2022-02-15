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


class Human: Player {
    var schedule: Schedule = Schedule()
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

struct Position: Equatable {
    var x: Int
    var y: Int
    
    var isValid: Bool {
        0 <= x && x < fieldSize && 0 <= y && y < fieldSize
    }
    
    func dist(to: Position) -> Int {
        abs(self.y - to.y) + abs(self.x - to.x)
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

// Schedule of human moves
struct Schedule {
    // Job to place block to position
    private(set) var jobs = Queue<Job>()
    // Current job length
    private(set) var cost: Int = 0
    
    init(jobs: [Job] = []) {
        for job in jobs {
            assign(job: job)
        }
    }
    
    mutating func assign(job: Job) {
        cost += job.cost
        
        // Add cost of the dist from the previous job if exists
        if let from = jobs.tail?.blocks.tail,
           let to = job.blocks.front {
            cost += from.dist(to: to)
        }

        jobs.push(job)
    }

    // There should be two types of human job
    // 1. Place block
    // 2. Move to space
    // Type 2 should be performed only at the end of the game
    struct Job {
        enum Kind {
            case move
            case block
        }

        // Positions to place blocks
        var blocks: Queue<Position>
        // Estimated time to end this job
        var cost: Int
        init(blocks: [Position]) {
            self.blocks = Queue<Position>()

            for block in blocks {
                self.blocks.push(block)
            }

            // ISSUE: Does not consider current block, if there is a block
            // between the path, the cost will be bigger.
            cost = 0
            for i in 0 ..< blocks.count - 1 {
                // Add 1 to place block
                cost += blocks[i].dist(to: blocks[i + 1]) + 1
            }
        }
    }
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
