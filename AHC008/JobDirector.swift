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
        guard humans.count > 0 else { return nil }
        var assignee = humans[0]
        for human in humans {
            assignee = compare(human, assignee, job)
        }
        return assignee
    }
}

class SquareGridJobDirector: JobDirector {
    private var grids = [Grid]()
    private var costLimit: Int {
        50
    }
    lazy var skipBlocks: [Position] = {
        var arr = [Position]()
        for grid in grids { arr.append(grid.gate) }
        // Where horizontal block and vertical block intersects
        let intersections = [
            Position(x: 5, y: 3),
            Position(x: 11, y: 3),
            Position(x: 18, y: 3),
            Position(x: 24, y: 3),
            Position(x: 3, y: 4),
            Position(x: 26, y: 4),
            Position(x: 5, y: 5),
            Position(x: 9, y: 5),
            Position(x: 13, y: 5),
            Position(x: 15, y: 5),
            Position(x: 24, y: 5),
            Position(x: 15, y: 9),
            Position(x: 24, y: 9),
            Position(x: 3, y: 11),
            Position(x: 26, y: 11),
            Position(x: 15, y: 13),
            Position(x: 24, y: 13),
            Position(x: 5, y: 14),
            Position(x: 9, y: 14),
            Position(x: 13, y: 14),
            Position(x: 16, y: 15),
            Position(x: 20, y: 15),
            Position(x: 24, y: 15),
            Position(x: 5, y: 16),
            Position(x: 14, y: 16),
            Position(x: 3, y: 18),
            Position(x: 26, y: 18),
            Position(x: 5, y: 20),
            Position(x: 14, y: 20),
            Position(x: 5, y: 24),
            Position(x: 14, y: 24),
            Position(x: 16, y: 24),
            Position(x: 20, y: 24),
            Position(x: 24, y: 24),
            Position(x: 3, y: 25),
            Position(x: 26, y: 25),
            Position(x: 5, y: 26),
            Position(x: 11, y: 26),
            Position(x: 18, y: 26),
            Position(x: 24, y: 26),
        ]
        return arr + intersections
    }()
    
    func directJobs(field: inout Field, humans: inout [Human], pets: inout [Pet], turn: Int) {
        if turn == 0 {
            createGrid()
            assignGridJobsHorizontal(field: &field, humans: &humans, pets: &pets)
            assignGridJobsVertical(field: &field, humans: &humans, pets: &pets)
            // Gather to center grid for capture wolves
            for human in humans {
                human.assign(job: .init(units: [
                    .init(kind: .move, pos: Position(x: 14, y: 8))
                ]))
            }
        }
        else if turn == 200 {
            // Start working around and close gates
            for human in humans {
                human.assign(job: .init(units: [
                    .init(kind: .move, pos: Position(x: 14, y: 24)),
                    .init(kind: .block, pos: Position(x: 14, y: 23))
                ]))
                human.brain = HumanBrainWithGridKnowledge(grids: grids)
                for _ in 0 ..< 10 {
                    human.assign(job: Schedule.Job(units: [
                        .init(kind: .patrol, pos: Position(x: 5, y: 5)),
                        .init(kind: .patrol, pos: Position(x: 5, y: 24)),
                        .init(kind: .patrol, pos: Position(x: 24, y: 24)),
                        .init(kind: .patrol, pos: Position(x: 24, y: 5)),
                    ].shuffled()))
                }
            }
        }
        else if turn >= 270 {
            // TODO: Do something
        }
    }
}

// MARK: SquareGridJobDirector.Assign

extension SquareGridJobDirector {
    private func assignGridJobsHorizontal(field: inout Field, humans: inout [Human], pets: inout [Pet]) {
        var jobs = [Schedule.Job]()
        var horizontalJobs = [Schedule.Job]()
        
        // Side horizontal
        for y in [5, 11, 18, 24] {
            horizontalJobs.append(
                createLineBlockJob(from: Position(x: 0, y: y), to: Position(x: 3, y: y))
            )
            
            horizontalJobs.append(
                createLineBlockJob(from: Position(x: 29, y: y), to: Position(x: 26, y: y))
            )
        }
        
        // Top and bottom horizontal
        for y in [5, 24] {
            horizontalJobs.append(
                createBlockJobWithMove(
                    from: Position(x: 6, y: y),
                    to: Position(x: 23, y: y),
                    checkDirections: [.down, .up],
                    skipBlocks: skipBlocks
                )
            )
        }
        
        // Center sides horizontal
        for y in [13, 15] {
            horizontalJobs.append(
                createLineBlockJob(from: Position(x: 7, y: y), to: Position(x: 11, y: y))
            )
            horizontalJobs.append(
                createLineBlockJob(from: Position(x: 18, y: y), to: Position(x: 22, y: y))
            )
        }
        
        var hJobs = [[Schedule.Job]](repeating: [Schedule.Job](), count: 3)
        for job in horizontalJobs {
            guard let y = job.nextUnit?.pos.y else {
                IO.log("Job start position does not exist for \(job)", type: .warn)
                continue
            }
            hJobs[y / 10].append(job)
        }
        for i in 0 ..< 3 {
            hJobs[i].sort(by: { jobA, jobB in
                guard let aStart = jobA.nextUnit?.pos, let bStart = jobB.nextUnit?.pos else {
                    IO.log("Job start position does not exist for \(jobA), \(jobB)", type: .warn)
                    return false
                }
                return aStart.x < bStart.x
            })
            
            var hJob = Schedule.Job(units: [])
            for job in hJobs[i] {
                hJob += job
                if hJob.cost > costLimit {
                    jobs.append(hJob)
                    hJob = Schedule.Job(units: [])
                }
            }
            jobs.append(hJob)
        }
        
        assignJobs(jobs: jobs, humans: &humans)
    }

    private func assignGridJobsVertical(field: inout Field, humans: inout [Human], pets: inout [Pet]) {
        var jobs = [Schedule.Job]()
        var verticalJobs = [Schedule.Job]()
        
        // Side vertical
        for x in [5, 24] {
            verticalJobs.append(
                createBlockJobWithMove(
                    from: Position(x: x, y: 6),
                    to: Position(x: x, y: 23),
                    checkDirections: [.left, .right],
                    skipBlocks: skipBlocks
                )
            )
        }
        
        // Top and bottom vertical
        for x in [5, 11, 18, 24] {
            verticalJobs.append(
                createLineBlockJob(from: Position(x: x, y: 0), to: Position(x: x, y: 3))
            )
            
            verticalJobs.append(
                createLineBlockJob(from: Position(x: x, y: 29), to: Position(x: x, y: 26))
            )
        }
        
        // Center vertical
        for x in [12, 17] {
            verticalJobs.append(
                createLineBlockJob(
                    from: Position(x: x, y: 6),
                    to: Position(x: x, y: 23),
                    skipBlocks: skipBlocks
                )
            )
        }

        var vJobs = [[Schedule.Job]](repeating: [Schedule.Job](), count: 3)
        for job in verticalJobs {
            guard let x = job.nextUnit?.pos.x else {
                IO.log("Job start position does not exist for \(job)", type: .warn)
                continue
            }
            vJobs[x / 10].append(job)
        }
        
        for i in 0 ..< 3 {
            vJobs[i].sort(by: { jobA, jobB in
                guard let aStart = jobA.nextUnit?.pos, let bStart = jobB.nextUnit?.pos else {
                    IO.log("Job start position does not exist for \(jobA), \(jobB)", type: .warn)
                    return false
                }
                return aStart.y < bStart.y
            })
            
            var vJob = Schedule.Job(units: [])
            for job in vJobs[i] {
                vJob += job
                if vJob.cost > costLimit {
                    jobs.append(vJob)
                    vJob = Schedule.Job(units: [])
                }
            }
            jobs.append(vJob)
        }

        assignJobs(jobs: jobs, humans: &humans)
    }
}

// MARK: SquareGridJobDirector.Grid

extension SquareGridJobDirector {
    private func createGrid() {
        // Corners
        do {
            let width = 5
            let height = 4
            grids.append(Grid(top: 0, left: 0, width: width, height: height, gate: Position(x: 4, y: 3)))
            grids.append(Grid(top: 0, left: 25, width: width, height: height, gate: Position(x: 25, y: 3)))
            grids.append(Grid(top: 26, left: 0, width: width, height: height, gate: Position(x: 4, y: 26)))
            grids.append(Grid(top: 26, left: 25, width: width, height: height, gate: Position(x: 25, y: 26)))
        }
        
        // Sides
        for y in [5, 12, 19] {
            let width = 3
            let height = 6
            grids.append(Grid(top: y, left: 0, width: width, height: height, gate: Position(x: 3, y: y + 2)))
            grids.append(Grid(top: y, left: 27, width: width, height: height, gate: Position(x: 26, y: y + 2)))
        }
        
        // Top and bottom
        for x in [6, 12, 19] {
            let width = x == 12 ? 6 : 5
            let height = 3
            grids.append(Grid(top: 0, left: x, width: width, height: height, gate: Position(x: x + 2, y: 3)))
            grids.append(Grid(top: 27, left: x, width: width, height: height, gate: Position(x: x + 2, y: 26)))
        }
        
        // Center vertical
        do {
            let width = 3
            let height = 8
            grids.append(Grid(top: 6, left: 6, width: width, height: height, gate: Position(x: 7, y: 5)))
            grids.append(Grid(top: 6, left: 10, width: width, height: height, gate: Position(x: 11, y: 5)))
            
            grids.append(Grid(top: 16, left: 17, width: width, height: height, gate: Position(x: 18, y: 24)))
            grids.append(Grid(top: 16, left: 21, width: width, height: height, gate: Position(x: 22, y: 24)))
        }
        
        // Center horizontal
        do {
            let width = 8
            let height = 3
            grids.append(Grid(top: 17, left: 6, width: width, height: height, gate: Position(x: 5, y: 18)))
            grids.append(Grid(top: 21, left: 6, width: width, height: height, gate: Position(x: 5, y: 22)))
            
            grids.append(Grid(top: 6, left: 16, width: width, height: height, gate: Position(x: 24, y: 7)))
            grids.append(Grid(top: 10, left: 16, width: width, height: height, gate: Position(x: 24, y: 11)))
        }
        
        dumpGrids(grids: grids)
    }
    
    // For Debug
    private func dumpGrids(grids: [Grid]) {
        var f = [[String]](repeating: [String](repeating: ".", count: fieldSize), count: fieldSize)
        for grid in grids {
            for x in grid.topLeft.x ... grid.bottomRight.x {
                for y in grid.topLeft.y ... grid.bottomRight.y {
                    f[y][x] = "Q"
                }
            }
            f[grid.gate.y][grid.gate.x] = "!"
        }
        var str = "\n"
        for y in 0 ..< fieldSize {
            for x in 0 ..< fieldSize {
                str += f[y][x]
            }
            str += "\n"
        }
        IO.log(str)
    }
}

// MARK: SquareGridJobDirector.Helper

extension SquareGridJobDirector {
    private func createLineBlockJob(
        from: Position,
        to: Position,
        skipBlocks: [Position] = []
    ) -> Schedule.Job {
        var units = [Schedule.Job.Unit]()
        let direction = CommandUtil.deltaToMoveCommand(delta: to - from).first?.delta ?? .zero
        if direction == .zero {
            IO.log("Direction is zero from \(from) to \(to)", type: .warn)
        }
        var current = from
        // Go to [from, to + direction)
        while current != to + direction {
            let movePosition = current + direction
            if movePosition.isValid {
                units.append(.init(kind: .move, pos: movePosition))
            }
            else {
                IO.log("Move position is invalid \(movePosition)", type: .warn)
            }
            if !skipBlocks.contains(current) {
                units.append(.init(kind: .block, pos: current))
            }
            current = movePosition
        }

        return Schedule.Job(units: units)
    }
    
    private func createBlockJobWithMove(
        from: Position,
        to: Position,
        checkDirections: [Position],
        skipBlocks: [Position] = []
    ) -> Schedule.Job {
        var units = [Schedule.Job.Unit]()
        let direction = CommandUtil.deltaToMoveCommand(delta: to - from).first?.delta ?? .zero
        if direction == .zero {
            IO.log("Direction is zero from \(from) to \(to)", type: .warn)
        }
        var current = from
        units.append(.init(kind: .move, pos: from))
        // Go to [from, to + direction)
        while current != to + direction {
            for direction in checkDirections {
                let target = current + direction
                if skipBlocks.contains(target) { continue }
                units.append(.init(kind: .block, pos: target))
            }
            let movePosition = current + direction
            if movePosition.isValid {
                units.append(.init(kind: .move, pos: movePosition))
            }
            else {
                IO.log("Move position is invalid \(movePosition)", type: .warn)
            }
            current = movePosition
        }
        
        return Schedule.Job(units: units)
    }

}
