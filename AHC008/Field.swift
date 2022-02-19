import Foundation

class Field {
    private var players = [[[Player]]](repeating: [[Player]](repeating: [Player](), count: fieldSize), count: fieldSize)
    private var pets = [[Int]](repeating: [Int](repeating: 0, count: fieldSize), count: fieldSize)
    private(set) var blocks = [[Bool]](repeating: [Bool](repeating: false, count: fieldSize), count: fieldSize)
    
    init(players: [Player] = [], blocks: [Position] = []) {
        addPlayers(players: players)
        addBlocks(positions: blocks)
    }
    init(players: [Player] = [], blocks: [[Bool]]) {
        addPlayers(players: players)
        guard blocks.count == fieldSize,
              blocks[0].count == fieldSize else { fatalError("Invalid blocks array size: \(blocks)") }
        self.blocks = blocks
    }
    
    func updateField(players updatedPlayers: [Player]) {
        players = [[[Player]]](repeating: [[Player]](repeating: [Player](), count: fieldSize), count: fieldSize)
        pets = [[Int]](repeating: [Int](repeating: 0, count: fieldSize), count: fieldSize)
        addPlayers(players: updatedPlayers)
    }
    
    func isValidCommand(player: Player, command: Command) -> Bool {
        if command.isMove {
            return isValidMove(player: player, delta: command.delta)
        }
        else if command.isBlock {
            return isValidBlock(player: player, delta: command.delta)
        }
        
        // command is .none
        return true
    }
    
    // Return true if there is no block at `nextPosition`, and the position is valid
    private func isValidMove(player: Player, delta: Position) -> Bool {
        isValidMove(position: player.pos + delta)
    }
    
    func isValidMove(position: Position) -> Bool {
        if !position.isValid { return false }
        return !checkBlock(at: position)
    }

    private func isValidBlock(player: Player, delta: Position) -> Bool {
        isValidBlock(target: player.pos + delta)
    }

    // Return true if it satisfies below conditions
    // 1. There is no player at `target`
    // 2. There is no *pet* around one block near `target`
    // 3. The target position is valid
    func isValidBlock(target: Position) -> Bool {
        guard target.isValid,
              getPlayers(at: target).count == 0 else { return false }
        // oxo
        // xTx
        // oxo
        for check in Position.around(pos: target) {
            if getPetCount(at: check) > 0 { return false }
        }
        return true
    }
}

// MARK: Field.Utilties

extension Field {
    func getPlayers(x: Int, y: Int) -> [Player] {
        getPlayers(at: Position(x: x, y: y))
    }
    
    func getPlayers(at position: Position) -> [Player] {
        players[position.y][position.x]
    }
    
    func getPetCount(x: Int, y: Int) -> Int {
        getPetCount(at: Position(x: x, y: y))
    }
    
    func getPetCount(at position: Position) -> Int {
        pets[position.y][position.x]
    }
    
    func getHumanCount(x: Int, y: Int) -> Int {
        getHumanCount(at: Position(x: x, y: y))
    }
    
    func getHumanCount(at position: Position) -> Int {
        getPlayers(x: position.x, y: position.y).count - pets[position.y][position.x]
    }

    func checkBlock(x: Int, y: Int) -> Bool {
        checkBlock(at: Position(x: x, y: y))
    }
    
    func checkBlock(at position: Position) -> Bool {
        blocks[position.y][position.x]
    }

    func addPlayer(player: Player) {
        players[player.y][player.x].append(player)
        if player is Pet {
            pets[player.y][player.x] += 1
        }
    }
    
    func addPlayers(players: [Player]) {
        for player in players { addPlayer(player: player) }
    }
    
    func applyCommand(player: Player, command: Command) {
        if command.isBlock {
            addBlock(position: player.pos + command.delta)
        }
    }
    
    func addBlock(position: Position) {
        blocks[position.y][position.x] = true
    }
    
    func addBlocks(positions: [Position]) {
        for pos in positions { addBlock(position: pos) }
    }
    
    func calcScore(humans: [Human]) -> Double {
        var totalScore: Double = 0
        var seen = [[Bool]](repeating: [Bool](repeating: false, count: fieldSize), count: fieldSize)
        for human in humans {
            if seen[human.y][human.x] { continue }
            var humanCount: Int = 0
            var petCount: Int = 0
            var realmSize: Int = 0
            let queue = Queue<Position>()
            seen[human.y][human.x] = true
            queue.push(human.pos)
            while !queue.isEmpty {
                guard let pos = queue.pop() else { break }
                realmSize += 1
                petCount += getPetCount(at: pos)
                humanCount += getHumanCount(at: pos)
                
                for dir in Position.directions {
                    let nxt = pos + dir
                    guard nxt.isValid,
                          !checkBlock(at: nxt),
                          !seen[nxt.y][nxt.x] else { continue }
                    seen[nxt.y][nxt.x] = true
                    queue.push(nxt)
                }
            }
            
            totalScore += Double(humanCount) * Double(realmSize) / 900.0 / pow(2.0, Double(petCount))
        }
        return totalScore * 100_000_000 / Double(humans.count)
    }
    
    func dump() {
        var str = "\n"
        for y in 0 ..< fieldSize {
            for x in 0 ..< fieldSize {
                if blocks[y][x] { str += "#" }
                else if players[y][x].count > 0 {
                    if players[y][x][0] is Pet { str += "P" }
                    else { str += "H" }
                }
                else { str += "." }
            }
            str += "\n"
        }
        IO.log(str)
    }
}
