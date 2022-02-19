protocol IOController {
    func processOutput(humans: [Human], commands: [Command])
    func processInput(petCount: Int) -> [[Command]]
}

struct RealIOController: IOController {
    func processInput(petCount: Int) -> [[Command]] {
        let petCommandStrArray = IO.readStringArray()
        guard petCommandStrArray.count == petCount else {
            fatalError("Input format error")
        }
        var petCommands = [[Command]](repeating: [], count: petCount)
        for i in 0 ..< petCount {
            for e in petCommandStrArray[i] {
                petCommands[i].append(Command.toEnum(e))
            }
        }
        return petCommands
    }
    
    func processOutput(humans: [Human], commands: [Command]) {
        IO.output(String(commands.map { $0.rawValue }))
    }
}

struct MockIOController: IOController {
    func processInput(petCount: Int) -> [[Command]] {
        // Do nothing
        [[Command]](repeating: [.none], count: petCount)
    }
    
    func processOutput(humans: [Human], commands: [Command]) {
        // Do nothing
    }
}
