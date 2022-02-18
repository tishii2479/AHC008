class Player: Equatable {
    private(set) var pos: Position
    private(set) var id: Int
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
    private(set) var schedule: Schedule = Schedule()
    var jobCost: Int {
        schedule.cost + pos.dist(to: schedule.nextUnit?.pos)
    }
    // The position the human will be after consuming all jobs
    var lastPosition: Position {
        schedule.jobs.tail?.endPosition ?? pos
    }
    var brain: Brain

    init(pos: Position, id: Int, brain: Brain) {
        self.brain = brain
        super.init(pos: pos, id: id)
    }
    
    // Call to get command candidate that is valid
    // Will be sorted by priority
    func commands(field: Field) -> [Command] {
        return brain.command(field: field, pos: pos, jobUnit: schedule.nextUnit).filter {
            field.isValidCommand(player: self, command: $0)
        }
    }
    
    // set isMajor to true to assign a major job, which means a job
    // that is needed to be performed immediately
    func assign(job: Schedule.Job, isMajor: Bool = false) {
        schedule.assign(job: job, isMajor: isMajor)
    }
    
    // The jobCost of this human if the job is assigned
    func assignedCost(job: Schedule.Job) -> Int {
        guard let lastJobPosition = schedule.jobs.tail?.units.tail?.pos else {
            return jobCost + job.cost
        }
        return jobCost + job.cost + lastJobPosition.dist(to: job.nextUnit?.pos)
    }
    
    func clearJobs() {
        while schedule.nextUnit != nil {
            schedule.consume()
        }
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
    
    private(set) var kind: Kind
    
    init(kind: Kind, pos: Position, id: Int) {
        self.kind = kind
        super.init(pos: pos, id: id)
    }
}
