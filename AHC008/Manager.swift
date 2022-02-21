class Manager {
    private var pets: [Pet]
    private var humans: [Human]
    private var field: Field
    private var director: JobDirector
    private var ioController: IOController

    init(
        field: Field,
        humans: [Human],
        pets: [Pet],
        director: JobDirector,
        ioController: IOController
    ) {
        self.field = field
        self.humans = humans
        self.pets = pets
        self.director = director
        self.ioController = ioController
    }
    
    func start() {
        for turn in 0 ..< turnLimit {
            processTurn(turn: turn)
        }
    }
    
    func processTurn(turn: Int) {
        field.updateField(players: humans + pets)
        director.directJobs(turn: turn)
        ioController.processOutput(humans: humans, commands: decideAndPerformCommand(turn: turn))
        let petCommands = ioController.processInput(petCount: pets.count)
        for i in 0 ..< pets.count {
            for command in petCommands[i] {
                pets[i].applyCommand(command: command, field: field)
            }
        }
    }
    
    private func decideHumanCommand(turn: Int) -> [Command] {
        if turn == turnLimit - 1 {
            // Final turn
            return calcBestCommandForFinalTurn()
        }
        var commands = [Command](repeating: .none, count: humans.count)
        for (i, human) in humans.enumerated() {
            if let command = human.commands(field: field).first {
                commands[i] = command
            }
        }
        return commands
    }
    
    private func decideAndPerformCommand(turn: Int) -> [Command] {
        // 0. Decide command
        var commands = decideHumanCommand(turn: turn)

        // 1. Apply block
        for (i, human) in humans.enumerated() {
            if !commands[i].isBlock { continue }
            human.applyCommand(command: commands[i], field: field)
            field.applyCommand(player: human, command: commands[i])
        }

        field.updateField(players: humans + pets)
        
        // 2. Apply move
        for (i, human) in humans.enumerated() {
            if commands[i].isBlock { continue }
            // Check the destination is not blocked in this turn
            if !field.isValidCommand(player: human, command: commands[i]) {
                commands[i] = Command.moves
                    .filter { field.isValidCommand(player: human, command: $0) }.randomElement() ?? .none
            }
            human.applyCommand(command: commands[i], field: field)
        }
        
        return commands
    }

    private func calcBestCommandForFinalTurn() -> [Command] {
        // Clear all jobs
        for human in humans {
            human.clearAllJobs()
        }
        
        return BestJobFinder(field: field, humans: humans, pets: pets).find2()
    }
}
