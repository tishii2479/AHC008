class Manager {
    private var pets: [Pet]
    private var humans: [Human]
    private var field: Field
    private var director: JobDirector
    
    private var petCount: Int { pets.count }
    private var humanCount: Int { humans.count }
    
    init(field: Field, humans: [Human], pets: [Pet], director: JobDirector) {
        self.field = field
        self.humans = humans
        self.pets = pets
        self.director = director
    }
    
    func start() {
        for turn in 0 ..< turnLimit {
            director.directJobs(turn: turn)
            outputHumanCommand(turn: turn)
            inputPetCommand()
        }
        
        field.dump()
    }
    
    private func inputPetCommand() {
        let petCommands = IO.readStringArray()
        guard petCommands.count == petCount else {
            fatalError("Input format error")
        }
        for i in 0 ..< petCount {
            for e in petCommands[i] {
                pets[i].applyCommand(command: Command.toEnum(e))
            }
        }
    }
    
    private func outputHumanCommand(turn: Int) {
        let commands: [Command] = decideAndPerformCommand(turn: turn)
        IO.output(String(commands.map { $0.rawValue }))
    }
    
    private func decideHumanCommand(turn: Int) -> [Command] {
        if turn == turnLimit - 1 {
            return BestJobFinder(field: field, humans: humans, pets: pets).find()
        }
        var commands = [Command](repeating: .none, count: humanCount)
        for (i, human) in humans.enumerated() {
            if let command = human.commands(field: field).first {
                commands[i] = command
            }
        }
        return commands
    }
    
    func decideAndPerformCommand(turn: Int) -> [Command] {
        field.updateField(players: humans + pets)
        
        // 0. Decide command
        var commands = decideHumanCommand(turn: turn)

        // 1. Apply block
        for (i, human) in humans.enumerated() {
            if !commands[i].isBlock { continue }
            human.applyCommand(command: commands[i])
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
            human.applyCommand(command: commands[i])
        }
        
        return commands
    }

    private func calcBestCommandForFinalTurn() -> [Command] {
        // Clear all jobs
        for human in humans {
            human.clearJobs()
        }
        
        return BestJobFinder(field: field, humans: humans, pets: pets).find()
    }
}

private class BestJobFinder {
    private var field: Field
    private var humans: [Human]
    private var pets: [Pet]
    private var bestCommands: [Command]
    private var bestScore: Double = 0
    private var stepCount: Int = 0
    private var commands = [Command]()
    private let allCommands = [.none] + Command.blocks
    
    init(field: Field, humans: [Human], pets: [Pet]) {
        self.field = field
        self.humans = humans
        self.pets = pets
        self.bestCommands = [Command](repeating: .none, count: humans.count)
    }
    
    func find() -> [Command] {
        var ptr = [Int](repeating: 0, count: humans.count)
        var cands = [[Command]](repeating: [Command](), count: humans.count)
        for i in 0 ..< humans.count {
            for command in allCommands {
                if field.isValidCommand(player: humans[i], command: command)
                    && field.checkBlock(at: humans[i].pos + command.delta) == false {
                    cands[i].append(command)
                }
            }
        }
        
        while ptr[humans.count - 1] < cands[humans.count - 1].count {
            let testField = Field(players: humans + pets, blocks: field.blocks)
            for i in 0 ..< humans.count {
                if testField.isValidCommand(player: humans[i], command: cands[i][ptr[i]]) {
                    testField.applyCommand(player: humans[i], command: cands[i][ptr[i]])
                }
            }

            let score: Double = FieldUtil.calcScoreFromField(field: testField, humans: humans)
            if score > bestScore {
                IO.log(bestScore, score, commands)
                bestCommands = commands
                bestScore = score
            }
            
            for i in 0 ..< humans.count {
                ptr[i] += 1
                if ptr[i] < cands[i].count { break }
                ptr[i] = 0
            }
        }
        return bestCommands
    }
}
