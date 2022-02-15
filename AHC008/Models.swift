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
    // Job to place wall to position
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
        
        // Add cost to go from previous job
        if let from = jobs.tail?.walls.tail,
           let to = job.walls.front {
            cost += from.dist(to: to)
        }

        jobs.push(job)
    }
}

// There should be two types of human job
// 1. Place wall
// 2. Move to space
// Type 2 should be performed only at the end of the game
struct Job {
    // Positions to place walls
    var walls: Queue<Position>
    // Estimated time to end this job
    var cost: Int
    init(walls: [Position]) {
        self.walls = Queue<Position>()

        for wall in walls {
            self.walls.push(wall)
        }

        // ISSUE: Does not consider current wall, if there is a wall
        // between the path, the cost will be bigger.
        cost = 0
        for i in 0 ..< walls.count - 1 {
            // Add 1 to place wall
            cost += walls[i].dist(to: walls[i + 1]) + 1
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
