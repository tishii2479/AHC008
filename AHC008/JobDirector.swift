protocol JobDirector {
    // How to assign human to jobs
    // Return the assignee
    typealias Compare = (_ testHuman: Human, _ currentAssignee: Human, _ job: Schedule.Job) -> Human
    typealias Eval = (_ human: Human, _ job: Schedule.Job) -> Int
    func directJobs(
        field: inout Field,
        humans: inout [Human],
        pets: inout [Pet],
        turn: Int
    )
}

extension JobDirector {
    func assignJobs(jobs: [Schedule.Job], humans: inout [Human]) {
        let eval: Eval = { human, job in
            human.assignedCost(job: job)
        }
        
        let compare: Compare = { (testHuman, currentAssignee, job) in
            if eval(testHuman, job) < eval(currentAssignee, job) {
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
    private var costLimit: Int {
        50
    }
    
    func directJobs(field: inout Field, humans: inout [Human], pets: inout [Pet], turn: Int) {
        if turn == 0 {
            assignGridJob(field: &field, humans: &humans, pets: &pets)
            assignPrepareForCaptureWolfJob(field: &field, humans: &humans, pets: &pets)
        }
        else if turn == 200 {
            assignCaptureWolfJob(field: &field, humans: &humans, pets: &pets)
            assignCloseGateJob(field: &field, humans: &humans, pets: &pets)
        }
        else if turn == 300 {
            // TODO: Do best move, search all
        }
    }
}

// SquareGridJobDirector.Assign

extension SquareGridJobDirector {
    private func assignGridJob(field: inout Field, humans: inout [Human], pets: inout [Pet]) {
        grids = gridManager.createGrid()
        let jobs = gridManager.createGridJobs()
        assignJobs(jobs: jobs, humans: &humans)
    }

    private func assignPrepareForCaptureWolfJob(field: inout Field, humans: inout [Human], pets: inout [Pet]) {
        // Gather to center grid for capture wolves
        let positions = [
            Position(x: 6, y: 15),
            Position(x: 15, y: 23),
            Position(x: 23, y: 14),
            Position(x: 14, y: 6),
        ]
        for (i, human) in humans.enumerated() {
            human.assign(job: .init(units: [
                .init(kind: .move, pos: positions[i % 4])
            ]))
        }
    }
    
    private func assignCaptureWolfJob(field: inout Field, humans: inout [Human], pets: inout [Pet]) {
        let blocks = [
            Position(x: 7, y: 15),
            Position(x: 15, y: 22),
            Position(x: 22, y: 14),
            Position(x: 14, y: 7),
        ]
        let start = [
            Position(x: 4, y: 15),
            Position(x: 14, y: 4),
            Position(x: 15, y: 25),
            Position(x: 25, y: 14),
        ]
        for (i, human) in humans.enumerated() {
            human.assign(job: .init(units: [
                .init(kind: .block, pos: blocks[i % 4]),
                .init(kind: .move, pos: start[i % 4])
            ]))
        }
    }
    
    private func assignCloseGateJob(field: inout Field, humans: inout [Human], pets: inout [Pet]) {
        // Start working around and close gates
        var corners: [Schedule.Job.Unit] = [
            Schedule.Job.Unit(kind: .move, pos: Position(x: 4, y: 4)),
            Schedule.Job.Unit(kind: .move, pos: Position(x: 4, y: 25)),
            Schedule.Job.Unit(kind: .move, pos: Position(x: 25, y: 25)),
            Schedule.Job.Unit(kind: .move, pos: Position(x: 25, y: 4)),
        ]
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
}
