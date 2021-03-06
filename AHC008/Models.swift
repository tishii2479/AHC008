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
    
    static func +=(lhs: inout Position, rhs: Position) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    
    static func +(lhs: Position, rhs: Position) -> Position {
        Position(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: Position, rhs: Position) -> Position {
        Position(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func ==(lhs: Position, rhs: Position) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    static let zero     = Position(x:  0, y:  0)
    static let up       = Position(x:  0, y: -1)
    static let down     = Position(x:  0, y:  1)
    static let left     = Position(x: -1, y:  0)
    static let right    = Position(x:  1, y:  0)
    static let directions = [up, down, left, right]
    
    static func around(pos: Position) -> [Position] {
        var positions = [Position]()
        for dir in directions {
            let target = pos + dir
            if target.isValid { positions.append(target) }
        }
        return positions
    }
}

// Schedule of human commands
struct Schedule {
    // Job to place block to position
    private(set) var jobs = Queue<Job>()
    // Current job length
    // The value will be the sum of the dist of each jobs
    // In addition to this cost, the true cost will be the sum of the distance
    // from the human position to the first job unit position
    // This true cost can be accessed by `human.jobCost`
    private(set) var cost: Int = 0
    
    var nextUnit: Job.Unit? {
        while jobs.front?.units.isEmpty == true { jobs.pop() }
        return jobs.front?.nextUnit
    }
    
    init(jobs: [Job] = []) {
        for job in jobs {
            assign(job: job)
        }
    }
    
    // Call if finished `nextUnit`
    // Return jobs[0].units[0] if exists
    @discardableResult
    mutating func consume() -> Job.Unit? {
        guard var job = jobs.front else { return nil }
        guard let unit = job.consume() else { return nil }
        
        // End job unit, so reduce cost
        cost -= unit.pos.dist(to: nextUnit?.pos)
        if unit.kind == .block { cost -= 1 }
        return unit
    }
    
    mutating func assign(job: Job, isMajor: Bool = false) {
        cost += job.cost
        if isMajor {
            jobs.pushFront(job)

            // Add cost of the dist from the added job if exists
            if let from = job.units.tail?.pos,
               let to = jobs.front?.units.front?.pos {
                cost += from.dist(to: to)
            }
        }
        else {
            // Add cost of the dist from the previous job if exists
            if let from = jobs.tail?.units.tail?.pos,
               let to = job.units.front?.pos {
                cost += from.dist(to: to)
            }

            jobs.push(job)
        }
    }

    // Schedule is composed of multiple jobs
    struct Job {
        // There are three types of human job
        // 1. move  := Mommand to space
        // 2. block := Place a block
        // 3. close := Patrol to pos, and close the gate if pet is in the grid
        struct Unit: Equatable {
            enum Kind {
                case move
                case block
                case close
                case forceMove
            }
            var kind: Kind
            var pos: Position
        }

        private(set) var units = Queue<Unit>()
        // Estimated time to end this job
        var cost: Int = 0
        var nextUnit: Unit? {
            units.front
        }
        var startPosition: Position? {
            units.front?.pos
        }
        var endPosition: Position? {
            units.tail?.pos
        }

        init(units: [Unit]) {
            for unit in units {
                self.units.push(unit)
                if unit.kind == .block { cost += 1 }
            }

            // Cacluate distance of adjacent job units
            // ISSUE: Does not consider current block, if there is a block
            // between the path, the cost will be bigger.
            if units.count > 0 {
                for i in 0 ..< units.count - 1 {
                    var dist = units[i].pos.dist(to: units[i + 1].pos)
                    if (units[i].kind == .block && units[i + 1].kind != .block)
                        || (units[i].kind != .block && units[i + 1].kind == .block) {
                        dist -= 1
                    }
                    cost += dist
                }
            }
        }

        @discardableResult
        mutating func consume() -> Unit? {
            units.pop()
        }
        
        static func +=(lhs: inout Job, rhs: Job) {
            var rhs = rhs
            lhs.cost += rhs.cost
            if let end = lhs.units.tail?.pos,
               let to = rhs.units.front?.pos {
                lhs.cost += end.dist(to: to)
            }
            while !rhs.units.isEmpty {
                if let unit = rhs.consume() {
                    lhs.units.push(unit)
                }
            }
        }
        
        static func +(lhs: Job, rhs: Job) -> Job {
            var lhs = lhs
            lhs += rhs
            return lhs
        }
        
        func reversed() -> Job {
            var copiedJob = copy()
            var units = [Unit]()
            while copiedJob.nextUnit != nil {
                units.append(copiedJob.consume()!)
            }
            units.reverse()
            return Job(units: units)
        }
        
        func copy() -> Job {
            return Job(units: self.units.elements)
        }
    }
}

enum Command: Character {
    case none = "."

    case moveUp = "U"
    case moveDown = "D"
    case moveLeft = "L"
    case moveRight = "R"
    
    case blockUp = "u"
    case blockDown = "d"
    case blockLeft = "l"
    case blockRight = "r"
    
    static let moves = [moveUp, moveRight, moveDown, moveLeft]
    static let blocks = [blockUp, blockRight, blockDown, blockLeft]
    
    var isMove: Bool {
        Command.moves.contains(self)
    }
    
    var isBlock: Bool {
        Command.blocks.contains(self)
    }

    static func toEnum(_ c: Character) -> Command {
        guard let m = Command(rawValue: c) else {
            fatalError("Failed to convert command: \(c)")
        }
        return m
    }
    
    var delta: Position {
        switch self {
        case .moveUp, .blockUp:
            return .up
        case .moveDown, .blockDown:
            return .down
        case .moveLeft, .blockLeft:
            return .left
        case .moveRight, .blockRight:
            return .right
        default:
            return .zero
        }
    }
}

struct Grid {
    var zone: [Position]
    var gates: [Position]
    var assignee: Human? = nil
    
    init(zone: [Position], gates: [Position]) {
        self.zone = zone
        self.gates = gates
    }
    
    init(top: Int, left: Int, width: Int, height: Int, gates: [Position]) {
        self.zone = []
        for x in left ..< left + width {
            for y in top ..< top + height {
                zone.append(Position(x: x, y: y))
            }
        }
        self.gates = gates
    }
    
    func petCountInGrid(field: Field) -> Int {
        var petCount = 0
        for pos in zone {
           petCount += field.getPetCount(at: pos)
        }
        return petCount
    }
    
    func humanCountInGrid(field: Field) -> Int {
        var humanCount = 0
        for pos in zone {
            humanCount += field.getHumanCount(at: pos)
        }
        return humanCount
    }
    
    func isPrepared(field: Field) -> Bool {
        let unrequired = zone + gates
        for pos in zone {
            for dir in Position.directions {
                let target = pos + dir
                if target.isValid && !unrequired.contains(target) && !field.checkBlock(at: target) {
                    return false
                }
            }
        }
        return true
    }
    
    func isClosed(field: Field) -> Bool {
        for gate in gates {
            if !field.checkBlock(at: gate) {
                return false
            }
        }
        return true
    }
}
