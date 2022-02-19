protocol IOController {
    func processOutput(humans: inout [Human], commands: [Command])
    func processInput(pets: inout [Pet])
}

struct RealIOController: IOController {
    func processInput(pets: inout [Pet]) {
        let petCommands = IO.readStringArray()
        guard petCommands.count == pets.count else {
            fatalError("Input format error")
        }
        for i in 0 ..< pets.count {
            for e in petCommands[i] {
                pets[i].applyCommand(command: Command.toEnum(e))
            }
        }
    }
    
    func processOutput(humans: inout [Human], commands: [Command]) {
        IO.output(String(commands.map { $0.rawValue }))
    }
}

struct MockIOController: IOController {
    func processInput(pets: inout [Pet]) {
        // Do nothing
    }
    
    func processOutput(humans: inout [Human], commands: [Command]) {
        // Do nothing
    }
}
