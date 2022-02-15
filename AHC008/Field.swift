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
    
    // Return true if there is no block at `nextPosition`, and the position is valid
    func isValidMove(player: Player, move: Move) -> Bool {
        let nextPosition = player.pos + move.delta
        if !nextPosition.isValid { return false }
        return !checkBlock(at: nextPosition)
    }
    
    // Return true if it satisfies below conditions
    // 1. There is no player at `target`
    // 2. There is no *pet* around one block near `target`
    // 3. The target position is valid
    func isValidBlockMove(player: Player, blockMove: BlockMove) -> Bool {
        let target = player.pos + blockMove.delta
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
    
    func addBlock(position: Position) {
        blocks[position.y][position.x] = true
    }
    
    func addBlocks(positions: [Position]) {
        for pos in positions { addBlock(position: pos) }
    }
}
