class Player: Equatable {
    var pos: Position
    var id: Int
    var x: Int { pos.x }
    var y: Int { pos.y }

    init(pos: Position, id: Int) {
        self.pos = pos
        self.id = id
    }

    func applyCommand(command: Command) {
        switch command {
        case .moveUp:
            pos.y -= 1
        case .moveDown:
            pos.y += 1
        case .moveLeft:
            pos.x -= 1
        case .moveRight:
            pos.x += 1
        default:
            break
        }
    }
    
    static func ==(lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
}

class Human: Player {
    var schedule: Schedule = Schedule()
    var jobCost: Int {
        schedule.cost + pos.dist(to: schedule.nextUnit?.pos)
    }
    var logic: HumanLogic

    init(pos: Position, id: Int, logic: HumanLogic) {
        self.logic = logic
        super.init(pos: pos, id: id)
    }
    
    // TODO: make this logic injectable from outside
    // Call to perform a command
    // Return performed command
    func command(field: Field) -> [Command] {
        return logic.command(field: field, pos: pos, jobUnit: schedule.nextUnit)
    }
    
    func assign(job: Schedule.Job) {
        schedule.assign(job: job)
    }
    
    override func applyCommand(command: Command) {
        super.applyCommand(command: command)
        
        // Check job completion
        guard let nextUnit = schedule.nextUnit else { return }
        
        switch nextUnit.kind {
        case .move:
            if pos == nextUnit.pos {
                schedule.consume()
            }
        case .block:
            if command.isBlock {
                schedule.consume()
            }
        }
    }
}

class Pet: Player {
    enum Kind: Int {
        case cow
        case pig
        case rabbit
        case dog
        case cat
    }
    
    var kind: Kind
    
    init(kind: Kind, pos: Position, id: Int) {
        self.kind = kind
        super.init(pos: pos, id: id)
    }
}
