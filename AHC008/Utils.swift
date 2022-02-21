import Foundation

class JobUtil {
    static func createLineBlockJob(
        from: Position,
        to: Position,
        skipBlocks: [Position] = [],
        addMove: Bool = true
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
            if addMove {
                if movePosition.isValid {
                    units.append(.init(kind: .move, pos: movePosition))
                }
                else {
                    IO.log("Move position is invalid \(movePosition)", type: .warn)
                }
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
    static func calcShortestMove(
        from: Position,
        to: Position,
        field: Field,
        treatAsBlocks: [Position] = []
    ) -> [Command] {
        let queue = Queue<Position>()
        var dist = [[Int]](repeating: [Int](repeating: 123456, count: fieldSize), count: fieldSize)
        queue.push(to)
        dist[to.y][to.x] = 0
        let testField = Field(players: [], blocks: field.blocks)
        for block in treatAsBlocks {
            testField.addBlock(position: block)
        }
        while !queue.isEmpty {
            guard let cur = queue.pop() else { break }
            // Prune unrequired search
            guard dist[cur.y][cur.x] < dist[from.y][from.x] else { break }

            for dir in Position.directions {
                let nxt = cur + dir
                guard nxt.isValid,
                      !testField.checkBlock(at: nxt),
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

class Util {
    static func createSquare(
        top: Int,
        left: Int,
        width: Int,
        height: Int,
        exclude: [Position]
    ) -> [Position] {
        var positions = [Position]()
        for y in top ..< top + height {
            for x in left ..< left + width {
                let pos = Position(x: x, y: y)
                if pos.isValid && !exclude.contains(pos) {
                    positions.append(pos)
                }
            }
        }
        return positions
    }
}

class PetUtil {
    static func getPetCount(pets: [Pet], for kind: Pet.Kind) -> Int {
        var count: Int = 0
        pets.forEach {
            if $0.kind == kind {
                count += 1
            }
        }
        return count
    }
}

class BestJobFinder {
    private var field: Field
    private var humans: [Human]
    private var pets: [Pet]
    private var bestCommands: [Command]
    private var bestScore: Double = 0
    private var stepCount: Int = 0
    private let allCommands = [.none] + Command.blocks
    
    init(field: Field, humans: [Human], pets: [Pet]) {
        self.field = field
        self.humans = humans
        self.pets = pets
        self.bestCommands = [Command](repeating: .none, count: humans.count)
    }
    
    func find() -> [Command] {
        var ptr = [Int](repeating: 0, count: humans.count)
        var cands = [[Command]](repeating: [Command](), count: humans.count)
        for i in 0 ..< humans.count {
            for command in allCommands {
                if field.isValidCommand(player: humans[i], command: command)
                    && field.checkBlock(at: humans[i].pos + command.delta) == false {
                    cands[i].append(command)
                }
            }
        }
        
        while ptr[humans.count - 1] < cands[humans.count - 1].count {
            let testField = Field(players: humans + pets, blocks: field.blocks)
            for i in 0 ..< humans.count {
                if testField.isValidCommand(player: humans[i], command: cands[i][ptr[i]]) {
                    testField.applyCommand(player: humans[i], command: cands[i][ptr[i]])
                }
            }

            let score: Double = testField.calcScore(humans: humans)
            if score > bestScore {
                var commands = [Command](repeating: .none, count: humans.count)
                for i in 0 ..< humans.count {
                    commands[i] = cands[i][ptr[i]]
                }
                IO.log(bestScore, score, commands)
                bestCommands = commands
                bestScore = score
            }
            
            for i in 0 ..< humans.count {
                ptr[i] += 1
                if ptr[i] < cands[i].count { break }
                if i < humans.count - 1 {
                    ptr[i] = 0
                }
            }
        }
        return bestCommands
    }
    
    func find2() -> [Command] {
        var cands = [[Command]](repeating: [Command](), count: humans.count)
        var commands = [Command](repeating: .none, count: humans.count)
        let players = humans + pets
        for i in 0 ..< humans.count {
            cands[i] = allCommands.filter { field.isValidCommand(player: humans[i], command: $0) }
        }
        while Date() < runLimitDate {
            let testField = Field(players: players, blocks: field.blocks)
            for i in 0 ..< humans.count {
                commands[i] = cands[i].randomElement()!
                testField.applyCommand(player: humans[i], command: commands[i])
            }

            let score: Double = testField.calcScore(humans: humans)
            if score > bestScore {
                IO.log(bestScore, score)
                bestCommands = commands
                bestScore = score
            }
        }
        return bestCommands
    }
}
