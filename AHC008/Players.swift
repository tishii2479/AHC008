class Player: Equatable {
    private(set) var pos: Position
    private(set) var id: Int
    var x: Int { pos.x }
    var y: Int { pos.y }

    init(pos: Position, id: Int) {
        self.pos = pos
        self.id = id
    }

    func applyMoveCommand(command: Command) {
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
    var currentJobUnit: Schedule.Job.Unit? {
        schedule.nextUnit
    }
    var brain: HumanBrain

    init(pos: Position, id: Int, brain: HumanBrain? = nil) {
        self.brain = brain ?? BasicHumanBrain()
        super.init(pos: pos, id: id)
    }
    
    // Call to get command candidate that is valid
    // Will be sorted by priority
    func commands(field: Field) -> [Command] {
        return brain.command(field: field, pos: pos, jobUnit: currentJobUnit).filter {
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
        jobCost + job.cost + lastPosition.dist(to: job.nextUnit?.pos)
    }
    
    func clearCurrentJob() {
        schedule.consume()
    }
    
    func clearAllJobs() {
        while schedule.nextUnit != nil {
            clearCurrentJob()
        }
    }
    
    func applyCommand(command: Command, field: Field) {
        applyMoveCommand(command: command)
        
        // Check job completion
        guard let nextUnit = currentJobUnit else { return }
        switch nextUnit.kind {
        case .move:
            if pos == nextUnit.pos || field.checkBlock(at: nextUnit.pos) {
                clearCurrentJob()
            }
        case .block:
            if command.isBlock || field.checkBlock(at: nextUnit.pos) {
                clearCurrentJob()
            }
        case .close:
            if command.isBlock || pos.dist(to: nextUnit.pos) <= 1 {
                clearCurrentJob()
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
    var isCaptured: Bool = false
    var assignee: Human? = nil
    
    func applyCommand(command: Command, field: Field) {
        applyMoveCommand(command: command)
    }
    
    init(kind: Kind, pos: Position, id: Int) {
        self.kind = kind
        super.init(pos: pos, id: id)
    }
}
