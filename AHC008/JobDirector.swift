protocol JobDirector {
    // How to assign human to jobs
    // Return the assignee
    typealias Compare = (_ testHuman: Human, _ currentAssignee: Human, _ job: Schedule.Job) -> Human
    func directJobs(turn: Int)
}

extension JobDirector {
    func assignJobs(jobs: [Schedule.Job], humans: [Human]) {
        let compare: Compare = { (testHuman, currentAssignee, job) in
            if testHuman.assignedCost(job: job) < currentAssignee.assignedCost(job: job) {
                return testHuman
            }
            return currentAssignee
        }

        for job in jobs {
            findAssignee(job: job, humans: humans, compare: compare)?.assign(job: job)
        }
    }
    
    func findAssignee(job: Schedule.Job, humans: [Human], compare: Compare) -> Human? {
        guard humans.count > 0 else {
            IO.log("Human count is zero.", type: .warn)
            return nil
        }
        var assignee = humans[0]
        for human in humans {
            assignee = compare(human, assignee, job)
        }
        return assignee
    }
}

class SquareGridJobDirector: JobDirector {
    private var field: Field
    private var humans: [Human]
    private var pets: [Pet]
    private var gridManager: GridManager

    private var grids = [Grid]()
    private var didCaputureDog: Bool = false
    private var costLimit: Int {
        // TODO: Consider better value
        30
    }
    private lazy var dogCount: Int = {
        var count: Int = 0
        pets.forEach {
            if $0.kind == .dog {
                count += 1
            }
        }
        return count
    }()
    private let dogBlocks = [
        Position(x: 7, y: 15),
        Position(x: 15, y: 22),
        Position(x: 22, y: 14),
        Position(x: 14, y: 7),
    ]
    private let dogPositions = [
        Position(x: 6, y: 15),
        Position(x: 15, y: 23),
        Position(x: 23, y: 14),
        Position(x: 14, y: 6),
    ]
    private var capturePosition: [Int]
    private var corners: [Schedule.Job.Unit] = [
        Schedule.Job.Unit(kind: .move, pos: Position(x: 4, y: 25)),
        Schedule.Job.Unit(kind: .move, pos: Position(x: 25, y: 25)),
        Schedule.Job.Unit(kind: .move, pos: Position(x: 25, y: 4)),
        Schedule.Job.Unit(kind: .move, pos: Position(x: 4, y: 4)),
    ]
    
    init(
        field: Field,
        humans: [Human],
        pets: [Pet],
        gridManager: GridManager
    ) {
        self.field = field
        self.humans = humans
        self.pets = pets
        self.gridManager = gridManager
        
        self.capturePosition = [Int](repeating: 0, count: humans.count)
    }
    
    func directJobs(turn: Int) {
        if turn == 0 {
            assignGridJob()
            assignPrepareForCaptureDogJob()
        }
        if 100 <= turn && turn <= 299 {
            if isPreparedToCaptureDog(turn: turn) {
                IO.log("Captured dog at turn: \(turn)")
                field.dump()
                didCaputureDog = true
                assignCaptureDogJob()
                assignCloseGateJob()
            }
            else if didCaputureDog {
                findGridAndAssignBlockJob(turn: turn)
            }
        }
    }
}

// MARK: SquareGridJobDirector.Helper

extension SquareGridJobDirector {
    private func isPreparedToCaptureDog(turn: Int) -> Bool {
        guard !didCaputureDog else { return false }
        if turn >= 299 { return true } 
        if getCapturedDogCount() < dogCount { return false }
        for human in humans {
            if human.jobCost > 0 { return false }
        }
        for block in dogBlocks {
            if !field.isValidBlock(target: block) { return false }
        }
        return true
    }
    
    private func getCapturedDogCount() -> Int {
        var captureDogCount: Int = 0
        for x in 8 ... 14 {
            captureDogCount += getDogCountAt(x: x, y: 15)
        }
        for x in 15 ... 21 {
            captureDogCount += getDogCountAt(x: x, y: 14)
        }
        for y in 8 ... 14 {
            captureDogCount += getDogCountAt(x: 14, y: y)
        }
        for y in 15 ... 21 {
            captureDogCount += getDogCountAt(x: 15, y: y)
        }
        captureDogCount += getDogCountAt(x: 15, y: 13)
        captureDogCount += getDogCountAt(x: 13, y: 14)
        captureDogCount += getDogCountAt(x: 16, y: 15)
        captureDogCount += getDogCountAt(x: 14, y: 16)
        captureDogCount += getDogCountAt(x: 9, y: 14)
        captureDogCount += getDogCountAt(x: 15, y: 9)
        captureDogCount += getDogCountAt(x: 14, y: 20)
        captureDogCount += getDogCountAt(x: 20, y: 15)
        return captureDogCount
    }
    
    private func getDogCountAt(x: Int, y: Int) -> Int {
        var dogCount = 0
        for player in field.getPlayers(x: x, y: y) {
            if let pet = player as? Pet,
               pet.kind == .dog {
                dogCount += 1
            }
        }
        return dogCount
    }
}

// MARK: SquareGridJobDirector.Assign

extension SquareGridJobDirector {
    private func assignGridJob() {
        grids = gridManager.createGrid()
        let jobs = gridManager.createGridJobs()
        assignJobs(jobs: jobs, humans: humans)
    }
    
    // TODO: Assign better positions
    private func assignPrepareForCaptureDogJob() {
        // Gather to center grid for capture wolves
        for (i, human) in humans.enumerated() {
            human.assign(job: .init(units: [
                .init(kind: .move, pos: dogPositions[i % 4])
            ]))
        }
    }
    
    private func assignCaptureDogJob() {
        for (i, human) in humans.enumerated() {
            human.assign(job: .init(units: [
                .init(kind: .block, pos: dogBlocks[i % 4]),
            ]))
        }
    }
    
    private func assignCloseGateJob() {
        // Start working around and close gates
        for (i, human) in humans.enumerated() {
            human.brain = HumanBrainWithGridKnowledge(grids: grids)
            for _ in 0 ..< 10 {
                human.assign(
                    job: Schedule.Job(
                        units: [
                            corners[i % 4],
                            corners[(i + 1) % 4],
                            corners[(i + 2) % 4],
                            corners[(i + 3) % 4],
                        ]
                    )
                )
            }
            if i % 4 == 3 {
                corners.reverse()
            }
        }
    }
    
    private func findGridAndAssignBlockJob(turn: Int) {
        let compare: Compare = { (testHuman, currentAssignee, job) in
            if testHuman.pos.dist(to: job.nextUnit?.pos) < currentAssignee.pos.dist(to: job.nextUnit?.pos) {
                return testHuman
            }
            return currentAssignee
        }

        for i in 0 ..< grids.count {
            if field.checkBlock(at: grids[i].gate) { continue }
            let petCount: Int = grids[i].petCountInGrid(field: field)
            if petCount == 0 {
                grids[i].assignee = nil
                continue
            }
            if grids[i].assignee != nil { continue }

            if petCount > 0 {
                let job = Schedule.Job(units: [.init(kind: .close, pos: grids[i].gate)])
                if let assignee = findAssignee(job: job, humans: humans, compare: compare) {
                    grids[i].assignee = assignee
                    assignee.assign(job: job, isMajor: true)
                }
                else {
                    IO.log("Assignee not found for grid: \(grids[i])", type: .warn)
                }
            }
        }
    }
}

