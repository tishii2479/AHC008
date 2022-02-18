protocol JobDirector {
    // How to assign human to jobs
    // Return the assignee
    typealias Compare = (_ testHuman: Human, _ currentAssignee: Human, _ job: Schedule.Job) -> Human
    func directJobs(turn: Int)
}

extension JobDirector {
    func assignJobs(jobs: [Schedule.Job], humans: inout [Human]) {
        let compare: Compare = { (testHuman, currentAssignee, job) in
            if testHuman.assignedCost(job: job) < currentAssignee.assignedCost(job: job) {
                return testHuman
            }
            return currentAssignee
        }

        for job in jobs {
            findAssignee(job: job, humans: &humans, compare: compare)?.assign(job: job)
        }
    }
    
    func findAssignee(job: Schedule.Job, humans: inout [Human], compare: Compare) -> Human? {
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
    private var gridManager: GridManager = SquareGridManager()
    private var grids = [Grid]()
    private var didCaputureWolf: Bool = false
    private var costLimit: Int {
        // TODO: Consider better value
        50
    }
    private var field: Field
    private var humans: [Human]
    private var pets: [Pet]
    private var wolfCount: Int = 0
    private let wolfBlocks = [
        Position(x: 7, y: 15),
        Position(x: 15, y: 22),
        Position(x: 22, y: 14),
        Position(x: 14, y: 7),
    ]
    private let wolfPositions = [
        Position(x: 6, y: 15),
        Position(x: 15, y: 23),
        Position(x: 23, y: 14),
        Position(x: 14, y: 6),
    ]
    private var corners: [Schedule.Job.Unit] = [
        Schedule.Job.Unit(kind: .move, pos: Position(x: 4, y: 25)),
        Schedule.Job.Unit(kind: .move, pos: Position(x: 25, y: 25)),
        Schedule.Job.Unit(kind: .move, pos: Position(x: 25, y: 4)),
        Schedule.Job.Unit(kind: .move, pos: Position(x: 4, y: 4)),
    ]
    
    init(field: inout Field, humans: inout [Human], pets: inout [Pet]) {
        self.field = field
        self.humans = humans
        self.pets = pets
        pets.forEach { if $0.kind == .dog { wolfCount += 1 } }
    }
    
    func directJobs(turn: Int) {
        if turn == 0 {
            assignGridJob()
            assignPrepareForCaptureWolfJob()
        }
        // TODO: Find best timing
        if 100 <= turn && turn <= 299 {
            if isPreparedToCaptureWolf(turn: turn) {
                didCaputureWolf = true
                assignCaptureWolfJob()
                assignCloseGateJob()
            }
            else if didCaputureWolf {
                findGridAndAssignBlockJob()
            }
        }
    }
}

// MARK: SquareGridJobDirector.Helper

extension SquareGridJobDirector {
    private func isPreparedToCaptureWolf(turn: Int) -> Bool {
        guard !didCaputureWolf else { return false }
        if turn >= 220 { return true }  // TODO: consider timing
        if getCapturedWolfCount() < wolfCount { return false }
        for human in humans {
            if human.jobCost > 0 { return false }
        }
        for block in wolfBlocks {
            if !field.isValidBlock(target: block) { return false }
        }
        return true
    }
    
    private func getCapturedWolfCount() -> Int {
        var captureWolfCount: Int = 0
        for x in 8 ... 14 {
            captureWolfCount += getWolfCountAt(x: x, y: 15)
        }
        for x in 15 ... 21 {
            captureWolfCount += getWolfCountAt(x: x, y: 14)
        }
        for y in 8 ... 14 {
            captureWolfCount += getWolfCountAt(x: 14, y: y)
        }
        for y in 15 ... 21 {
            captureWolfCount += getWolfCountAt(x: 15, y: y)
        }
        return captureWolfCount
    }
    
    private func getWolfCountAt(x: Int, y: Int) -> Int {
        var wolfCount = 0
        for player in field.getPlayers(x: x, y: y) {
            if let pet = player as? Pet,
               pet.kind == .dog {
                wolfCount += 1
            }
        }
        return wolfCount
    }
}

// MARK: SquareGridJobDirector.Assign

extension SquareGridJobDirector {
    private func assignGridJob() {
        grids = gridManager.createGrid()
        let jobs = gridManager.createGridJobs()
        assignJobs(jobs: jobs, humans: &humans)
    }

    private func assignPrepareForCaptureWolfJob() {
        // Gather to center grid for capture wolves
        for (i, human) in humans.enumerated() {
            human.assign(job: .init(units: [
                .init(kind: .move, pos: wolfPositions[i % 4])
            ]))
        }
    }
    
    private func assignCaptureWolfJob() {
        for (i, human) in humans.enumerated() {
            human.assign(job: .init(units: [
                .init(kind: .block, pos: wolfBlocks[i % 4]),
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
    
    private func findGridAndAssignBlockJob() {
        let compare: Compare = { (testHuman, currentAssignee, job) in
            if testHuman.pos.dist(to: job.nextUnit?.pos) < testHuman.pos.dist(to: job.nextUnit?.pos) {
                return testHuman
            }
            return currentAssignee
        }

        for i in 0 ..< grids.count {
            if grids[i].assigned { continue }
            var petCount: Int = 0
            for x in grids[i].topLeft.x ... grids[i].bottomRight.x {
                for y in grids[i].topLeft.y ... grids[i].bottomRight.y {
                    petCount += field.getPetCount(x: x, y: y)
                }
            }
            if petCount > 0 {
                grids[i].assigned = true
                let job = Schedule.Job(units: [.init(kind: .block, pos: grids[i].gate)])
                findAssignee(job: job, humans: &humans, compare: compare)?.assign(job: job, isMajor: true)
            }
        }
    }
}

