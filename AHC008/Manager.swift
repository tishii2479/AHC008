class Manager {
    private var petCount: Int { pets.count }
    private var humanCount: Int { humans.count }
    private var pets = [Pet]()
    private var humans = [Human]()
    private var field = Field()
    private var director: JobDirector = Director()
    
    func start() {
        initialize()
        
        for turn in 0 ..< turnLimit {
            director.assignJobs(field: &field, humans: &humans, pets: &pets, turn: turn)
            outputHumanCommand()
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
    
    private func outputHumanCommand() {
        let commands: [Command] = decideAndPerformCommand()
        IO.output(String(commands.map { $0.rawValue }))
    }
    
    private func decideAndPerformCommand() -> [Command] {
        var commands = [Command](repeating: .none, count: humanCount)

        field.updateField(players: humans + pets)
        
        // 0. Decide command
        for (i, human) in humans.enumerated() {
            for command in human.commands(field: field) {
                if field.isValidCommand(player: human, command: command) {
                    commands[i] = command
                    break
                }
            }
        }

        // 1. Apply block
        for (i, human) in humans.enumerated() {
            if !commands[i].isBlock { continue }
            // TODO: Refactor (avoid miss calling field.addBlock)
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
    
    private func initialize() {
        let N = IO.readInt()
        for i in 0 ..< N {
            let arr = IO.readIntArray()
            guard arr.count == 3,
                  let kind = Pet.Kind(rawValue: arr[2] - 1) else { fatalError("Input format error") }
            pets.append(
                Pet(
                    kind: kind,
                    pos: Position(x: arr[1] - 1, y: arr[0] - 1),
                    id: i
                )
            )
        }
        let M = IO.readInt()
        for i in 0 ..< M {
            let arr = IO.readIntArray()
            guard arr.count == 2 else { fatalError("Input format error") }
            humans.append(
                Human(
                    pos: Position(x: arr[1] - 1, y: arr[0] - 1),
                    id: i + N,
                    logic: Logic()
                )
            )
        }
    }
}
