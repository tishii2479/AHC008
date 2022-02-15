struct Solver {
    static func solve(
        field: inout Field,
        humans: inout [Human],
        pets: inout [Pet]
    ) -> String {
        var moves = [Character](repeating: ".", count: humans.count)

        // 1. Perform move
        field.updateField(players: humans + pets)
        for (i, human) in humans.enumerated() {
            if field.isValidMove(player: human, delta: .up) {
                human.applyMove(move: .moveUp)
                moves[i] = Move.moveUp.rawValue
            }
        }

        // 2. Perform block if possible
        field.updateField(players: humans + pets)
        for (i, human) in humans.enumerated() {
            if moves[i] != "." { continue }
            if field.isValidBlockMove(player: human, delta: .right) {
                field.addBlock(position: human.pos + .right)
                moves[i] = Move.blockRight.rawValue
            }
        }
        
        return String(moves)
    }
}
