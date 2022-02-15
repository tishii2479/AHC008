struct Solver {
    static func solve(
        field: inout Field,
        humans: inout [Human],
        pets: inout [Pet]
    ) -> [Move] {
        var moves = [Move](repeating: .none, count: humans.count)

        // 1. Perform move
        field.updateField(players: humans + pets)
        for (i, human) in humans.enumerated() {
            if field.isValidMove(player: human, delta: .up) {
                human.applyMove(move: .moveUp)
                moves[i] = Move.moveUp
            }
        }

        // 2. Perform block if possible
        field.updateField(players: humans + pets)
        for (i, human) in humans.enumerated() {
            if moves[i] != .none { continue }
            if field.isValidBlockMove(player: human, delta: .right) {
                field.addBlock(position: human.pos + .right)
                moves[i] = Move.blockRight
            }
        }
        
        return moves
    }
}
