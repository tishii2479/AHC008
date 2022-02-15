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
    var jobCost: Int {
        schedule.cost + pos.dist(to: schedule.nextUnit?.pos)
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

struct Position: Equatable {
    var x: Int
    var y: Int
    
    var isValid: Bool {
        0 <= x && x < fieldSize && 0 <= y && y < fieldSize
    }
    
    func dist(to: Position?) -> Int {
        guard let to = to else { return 0 }
        return abs(self.y - to.y) + abs(self.x - to.x)
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
    // In addition to this cost, the true cost will be the sum of the distance
    // from the human position to the first job unit position
    private(set) var cost: Int = 0
    
    var nextUnit: Job.Unit? {
        while jobs.front?.units.isEmpty == true {
            jobs.pop()
        }
        return jobs.front?.nextUnit
    }
    
    init(jobs: [Job] = []) {
        for job in jobs {
            assign(job: job)
        }
    }
    
    // Return jobs[0].units[0] if exists
    @discardableResult
    mutating func consume() -> Job.Unit? {
        guard var job = jobs.front else { return nil }
        guard let unit = job.consume() else { return nil }
        // Reduce cost
        cost -= unit.pos.dist(to: nextUnit?.pos)
        return unit
    }
    
    mutating func assign(job: Job) {
        cost += job.cost
        
        // Add cost of the dist from the previous job if exists
        if let from = jobs.tail?.units.tail?.pos,
           let to = job.units.front?.pos {
            cost += from.dist(to: to)
        }

        jobs.push(job)
    }

    // Schedule is composed of multiple jobs
    struct Job {
        // There should be two types of human job
        // 1. move  := Move to space
        // 2. block := Place a block
        struct Unit: Equatable {
            enum Kind {
                case move
                case block
            }
            var kind: Kind
            var pos: Position
        }

        var units = Queue<Unit>()
        // Estimated time to end this job
        var cost: Int = 0
        var nextUnit: Unit? {
            units.front
        }

        init(units: [Unit]) {
            for unit in units {
                self.units.push(unit)
                if unit.kind == .block { cost += 1 }
            }

            // Cacluate distance of adjacent job units
            // ISSUE: Does not consider current block, if there is a block
            // between the path, the cost will be bigger.
            for i in 0 ..< units.count - 1 {
                cost += units[i].pos.dist(to: units[i + 1].pos)
            }
        }

        @discardableResult
        mutating func consume() -> Unit? {
            units.pop()
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
