class Field {
    private var players = [[[Player]]](repeating: [[Player]](repeating: [Player](), count: fieldSize), count: fieldSize)
    private var blocks = [[Bool]](repeating: [Bool](repeating: false, count: fieldSize), count: fieldSize)
    
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
        let nextPosition = player.pos + delta
        if !nextPosition.isValid { return false }
        return !checkBlock(at: nextPosition)
    }
    
    // Return true if it satisfies below conditions
    // 1. There is no player at `target`
    // 2. There is no *pet* around one block near `target`
    // 3. The target position is valid
    private func isValidBlock(player: Player, delta: Position) -> Bool {
        let target = player.pos + delta
        if !target.isValid { return false }
        if getPlayers(at: target).count > 0 { return false }
        
        // oxo
        // xTx
        // oxo
        for check in Position.around(pos: target) {
            for player in getPlayers(at: check) {
                if player is Pet { return false }
            }
        }
        return true
    }
}

// Field.Utilties

extension Field {
    func getPlayers(x: Int, y: Int) -> [Player] {
        getPlayers(at: Position(x: x, y: y))
    }
    
    func getPlayers(at position: Position) -> [Player] {
        players[position.y][position.x]
    }

    func checkBlock(x: Int, y: Int) -> Bool {
        checkBlock(at: Position(x: x, y: y))
    }
    
    func checkBlock(at position: Position) -> Bool {
        blocks[position.y][position.x]
    }

    func addPlayer(player: Player) {
        players[player.pos.y][player.pos.x].append(player)
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
