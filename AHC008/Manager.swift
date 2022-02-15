class Manager {
    private var petCount: Int { pets.count }
    private var humanCount: Int { humans.count }
    private var pets = [Pet]()
    private var humans = [Human]()
    private var field = Field()
    
    func start() {
        initialize()
        
        for human in humans {
            var units = [Schedule.Job.Unit]()
            for y in 0 ..< fieldSize {
                units.append(.init(kind: .block, pos: Position(x: human.x, y: y)))
            }
            let job = Schedule.Job(units: units)
            human.assign(job: job)
        }
        
        for _ in 0 ..< turnLimit {
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
        let commands: [Command] = Solver.solve(field: &field, humans: &humans, pets: &pets)
        IO.output(String(commands.map { $0.rawValue }))
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
