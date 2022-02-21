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
    private var catGrids = [Grid]()
    private var didCaputureDog: Bool = false
    private lazy var dogCount: Int = {
        return PetUtil.getPetCount(pets: pets, for: .dog)
    }()
    
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
    }
    
    func directJobs(turn: Int) {
        if turn == 0 {
            assignGridJob()
            assignPrepareForCaptureDogJob()
            for human in humans {
                human.brain = HumanBrainWithGridKnowledge(grids: grids)
            }
        }
        if 100 <= turn && turn <= 299 {
            if isPreparedToCaptureDog(turn: turn) {
                IO.log("Captured dog at turn: \(turn)")
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
    private var capturedDogCount: Int {
        var count: Int = 0
        for pos in gridManager.dogCaptureZone {
            count += field.getPetCount(x: pos.x, y: pos.y, kind: .dog)
        }
        return count
    }

    private func isPreparedToCaptureDog(turn: Int) -> Bool {
        guard !didCaputureDog else { return false }
        if turn >= 299 { return true } 
        if capturedDogCount < dogCount { return false }
        for human in humans {
            if !gridManager.dogCapturePositions.contains(human.pos) { return false }
            if human.jobCost > 0 { return false }
        }
        for block in gridManager.dogCaptureBlocks {
            if !field.isValidBlock(target: block) { return false }
        }
        return true
    }
}

// MARK: SquareGridJobDirector.Assign

extension SquareGridJobDirector {
    private func assignGridJob() {
        grids = gridManager.createGrid()
        catGrids = gridManager.createCatGrids()
        let jobs = gridManager.createGridJobs()
        assignJobs(jobs: jobs, humans: humans)
    }
    
    // TODO: Assign better positions
    private func assignPrepareForCaptureDogJob() {
        // Gather to center grid for capture dogs
        for (i, human) in humans.enumerated() {
            human.assign(job: .init(units: [
                .init(kind: .move, pos: gridManager.dogCapturePositions[i % 2])
            ]))
        }
    }
    
    private func assignCaptureDogJob() {
        for (i, human) in humans.enumerated() {
            human.assign(job: .init(units: [
                .init(kind: .block, pos: gridManager.dogCaptureBlocks[i % 2]),
            ]))
        }
    }
    
    private func assignCloseGateJob() {
        var corners: [Position] = [
            Position(x: 4, y: 25),
            Position(x: 25, y: 25),
            Position(x: 25, y: 4),
            Position(x: 4, y: 4),
        ]
        // Start working around and close gates
        for (i, human) in humans.enumerated() {
            for _ in 0 ..< 10 {
                human.assign(
                    job: Schedule.Job(
                        units: [
                            .init(kind: .move, pos: corners[i % 4]),
                            .init(kind: .move, pos: corners[(i + 1) % 4]),
                            .init(kind: .move, pos: corners[(i + 2) % 4]),
                            .init(kind: .move, pos: corners[(i + 3) % 4]),
                        ]
                    )
                )
            }
            if i % 4 == 2 {
                corners.reverse()
            }
        }
    }
    
    private func assignCloseForMultiGateGrid(grid: Grid) {
        guard !grid.isClosed(field: field) else { return }
        for gate in grid.gates {
            if field.checkBlock(at: gate) { continue }
            for human in humans {
                if human.pos.dist(to: gate) > 2 { return }
            }
        }
        
        for gate in grid.gates {
            if field.checkBlock(at: gate) { continue }
            for human in humans {
                let job = Schedule.Job(units: [
                    .init(kind: .close, pos: gate)
                ])
                if human.pos.dist(to: gate) <= 2 {
                    human.assign(job: job, isMajor: true)
                    break
                }
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
            if grids[i].isClosed(field: field) { continue }
            let petCount: Int = grids[i].petCountInGrid(field: field)
            if petCount == 0 {
                grids[i].assignee = nil
                continue
            }
            if grids[i].assignee != nil { continue }

            if petCount > 0 {
                var units = [Schedule.Job.Unit]()
                for gate in grids[i].gates {
                    if !field.checkBlock(at: gate) {
                        units.append(.init(kind: .close, pos: gate))
                    }
                }
                let job = Schedule.Job(units: units)
                if let assignee = findAssignee(job: job, humans: humans, compare: compare) {
                    grids[i].assignee = assignee
                    IO.log(units, assignee.pos)
                    assignee.assign(job: job, isMajor: true)
                }
                else {
                    IO.log("Assignee not found for grid: \(grids[i])", type: .warn)
                }
            }
        }
    }
}
