class Field {
    private var players = [[[Player]]](repeating: [[Player]](repeating: [Player](), count: fieldSize), count: fieldSize)
    private var walls = [[Bool]](repeating: [Bool](repeating: false, count: fieldSize), count: fieldSize)
    
    init(players: [Player] = [], walls: [Position] = []) {
        addPlayers(players: players)
        addWalls(walls: walls)
    }
    init(players: [Player] = [], walls: [[Bool]]) {
        addPlayers(players: players)
        guard walls.count == fieldSize,
              walls[0].count == fieldSize else { fatalError("Invalid walls array size: \(walls)") }
        self.walls = walls
    }
    
    func updateField(players updatedPlayers: [Player]) {
        players = [[[Player]]](repeating: [[Player]](repeating: [Player](), count: fieldSize), count: fieldSize)
        addPlayers(players: updatedPlayers)
    }
    
    // Return true if there is no wall at `nextPosition`, and the position is valid
    func isValidMove(player: Player, move: Move) -> Bool {
        let nextPosition = player.pos + move.delta
        if !nextPosition.isValid { return false }
        return !checkWall(at: nextPosition)
    }
    
    // Return true if it satisfies below conditions
    // 1. There is no player at `target`
    // 2. There is no *pet* around one block near `target`
    // 3. The target position is valid
    func isValidBlockMove(player: Player, blockMove: BlockMove) -> Bool {
        let target = player.pos
        if !target.isValid { return false }
        if getPlayers(at: target).count > 0 { return false }
        for x in -1 ... 1 {
            for y in -1 ... 1 {
                let check = Position(x: x, y: y) + target
                for player in getPlayers(at: check) {
                    if player is Pet { return false }
                }
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

    func checkWall(x: Int, y: Int) -> Bool {
        checkWall(at: Position(x: x, y: y))
    }
    
    func checkWall(at position: Position) -> Bool {
        walls[position.y][position.x]
    }

    func addPlayer(player: Player) {
        players[player.pos.y][player.pos.x].append(player)
    }
    
    func addPlayers(players: [Player]) {
        for player in players { addPlayer(player: player) }
    }
    
    func addWall(wall: Position) {
        walls[wall.y][wall.x] = true
    }
    
    func addWalls(walls: [Position]) {
        for wall in walls { addWall(wall: wall) }
    }
}
