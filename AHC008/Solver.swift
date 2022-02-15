struct Solver {
    static func solve(
        field: inout Field,
        humans: inout [Human],
        pets: inout [Pet]
    ) -> [Command] {
        var commands = [Command](repeating: .none, count: humans.count)

        field.updateField(players: humans + pets)
        
        // 0. Decide command
        for (i, human) in humans.enumerated() {
            for command in human.command(field: field) {
                if field.isValidCommand(player: human, command: command) {
                    commands[i] = command
                    break
                }
            }
        }

        // 1. Apply block
        for (i, human) in humans.enumerated() {
            if !commands[i].isBlock { continue }
            human.applyCommand(command: commands[i])
            field.addBlock(position: human.pos + commands[i].delta)
        }

        field.updateField(players: humans + pets)
        
        // 2. Apply move
        for (i, human) in humans.enumerated() {
            if !commands[i].isMove { continue }
            if field.isValidCommand(player: human, command: commands[i]) {
                human.applyCommand(command: commands[i])
            }
            else {
                commands[i] = .none
            }
        }
        
        return commands
    }
}
