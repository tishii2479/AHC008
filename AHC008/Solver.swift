struct Solver {
    static func solve(
        field: inout Field,
        humans: inout [Human],
        pets: inout [Pet]
    ) -> [Command] {
        var commands = [Command](repeating: .none, count: humans.count)

        // 1. Perform move
        field.updateField(players: humans + pets)
        for (i, human) in humans.enumerated() {
            if field.isValidCommand(player: human, command: .moveUp) {
                human.applyCommand(command: .moveUp)
                commands[i] = Command.moveUp
            }
        }

        // 2. Perform block if possible
        field.updateField(players: humans + pets)
        for (i, human) in humans.enumerated() {
            if commands[i] != .none { continue }
            if field.isValidCommand(player: human, command: .blockRight) {
                field.addBlock(position: human.pos + .right)
                commands[i] = Command.blockRight
            }
        }
        
        return commands
    }
}
