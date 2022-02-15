class Field {
    // TODO: Stop indexes to access players and walls, to prevent accident of using x and y
    private(set) var players = [[[Player]]](repeating: [[Player]](repeating: [Player](), count: fieldSize), count: fieldSize)
    private(set) var walls = [[Bool]](repeating: [Bool](repeating: false, count: fieldSize), count: fieldSize)
    
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
        return !walls[nextPosition.y][nextPosition.x]
    }
    
    // Return true if it satisfies below conditions
    // 1. There is no player at `target`
    // 2. There is no *pet* around one block near `target`
    // 3. The target position is valid
    func isValidBlockMove(player: Player, blockMove: BlockMove) -> Bool {
        let target = player.pos
        if !target.isValid { return false }
        if players[target.y][target.x].count > 0 { return false }
        for x in -1 ... 1 {
            for y in -1 ... 1 {
                let check = Position(x: x, y: y) + target
                for player in players[check.y][check.x] {
                    if player is Pet { return false }
                }
            }
        }
        return true
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
