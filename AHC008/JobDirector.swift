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

private struct Grid {
    var topLeft: Position
    var bottomRight: Position
    var gate: Position
    var assigned: Bool = false
    
    init(top: Int, left: Int, width: Int, height: Int, gate: Position) {
        self.topLeft = Position(x: left, y: top)
        self.bottomRight = Position(x: left + width - 1, y: top + height - 1)
        self.gate = gate
    }
}

class SquareGridJobDirector: JobDirector {
    private var grids = [Grid]()
    private var costLimit: Int {
        50
    }
    // Where horizontal block and vertical block intersects
    private let intersections = [
        Position(x: 11, y: 4),
        Position(x: 18, y: 4),
        Position(x: 6, y: 6),
        Position(x: 12, y: 6),
        Position(x: 17, y: 6),
        Position(x: 23, y: 6),
        Position(x: 6, y: 23),
        Position(x: 12, y: 23),
        Position(x: 17, y: 23),
        Position(x: 23, y: 23),
        Position(x: 11, y: 25),
        Position(x: 18, y: 25),
        Position(x: 4, y: 11),
        Position(x: 4, y: 18),
        Position(x: 25, y: 11),
        Position(x: 25, y: 18),
        Position(x: 6, y: 12),
        Position(x: 6, y: 17),
        Position(x: 12, y: 12),
        Position(x: 17, y: 17),
        Position(x: 12, y: 17),
        Position(x: 17, y: 12),
        Position(x: 12, y: 14),
        Position(x: 17, y: 14),
    ]
    
    func directJobs(field: inout Field, humans: inout [Human], pets: inout [Pet], turn: Int) {
        if turn == 0 {
            createGrid()
            assignGridJobsHorizontal(field: &field, humans: &humans, pets: &pets)
        }
        if turn == 75 {
            assignGridJobsVertical(field: &field, humans: &humans, pets: &pets)
        }
        else if turn >= 150 {
            findGridAndAssign(field: &field, humans: &humans, pets: &pets)
        }
    }
    
    private func findGridAndAssign(field: inout Field, humans: inout [Human], pets: inout [Pet]) {
        // Find a grid where pet is in, and the gate is not closed.
        for i in 0 ..< grids.count {
            if grids[i].assigned { continue }
            var petCount: Int = 0
            var playerCount: Int = 0
            for x in grids[i].topLeft.x ... grids[i].bottomRight.x {
                for y in grids[i].topLeft.y ... grids[i].bottomRight.y {
                    petCount += field.getPetCount(x: x, y: y)
                    playerCount += field.getPetCount(x: x, y: y)
                }
            }
            if petCount > 0 && petCount == playerCount {
                grids[i].assigned = true
                let job = Schedule.Job(units: [.init(kind: .block, pos: grids[i].gate)])
                assignJobs(jobs: [job], humans: &humans)
            }
        }
    }
}

// MARK: SquareGridJobDirector.Assign

extension SquareGridJobDirector {
    private func assignGridJobsVertical(field: inout Field, humans: inout [Human], pets: inout [Pet]) {
        var jobs = [Schedule.Job]()
        let gates: [Position] = {
            var arr = [Position]()
            for grid in grids { arr.append(grid.gate) }
            return arr
        }()
        var verticalJobs = [Schedule.Job]()
        
        // Side vertical
        for x in [5, 24] {
            verticalJobs.append(
                createBlockJobWithMove(
                    from: Position(x: x, y: 6),
                    to: Position(x: x, y: 23),
                    checkDirections: [.left, .right],
                    skipBlocks: gates + intersections
                )
            )
        }
        
        // Top and bottom vertical
        for x in [5, 11, 18, 24] {
            verticalJobs.append(
                createLineBlockJob(from: Position(x: x, y: 0), to: Position(x: x, y: 4))
            )
            
            verticalJobs.append(
                createLineBlockJob(from: Position(x: x, y: 29), to: Position(x: x, y: 25))
            )
        }
        
        // Center vertical
        for x in [12, 17] {
            verticalJobs.append(
                createLineBlockJob(
                    from: Position(x: x, y: 6),
                    to: Position(x: x, y: 23),
                    skipBlocks: gates + intersections
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
    
    private func assignGridJobsHorizontal(field: inout Field, humans: inout [Human], pets: inout [Pet]) {
        var jobs = [Schedule.Job]()
        let gates: [Position] = {
            var arr = [Position]()
            for grid in grids { arr.append(grid.gate) }
            return arr
        }()
        
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
                    skipBlocks: gates + intersections
                )
            )
        }
        
        // Center sides horizontal
        for y in [12, 17] {
            horizontalJobs.append(
                createLineBlockJob(from: Position(x: 7, y: y), to: Position(x: 11, y: y))
            )
            horizontalJobs.append(
                createLineBlockJob(from: Position(x: 18, y: y), to: Position(x: 22, y: y))
            )
        }
        
        // Center center horizontal
        horizontalJobs.append(
            createLineBlockJob(from: Position(x: 13, y: 14), to: Position(x: 16, y: 14))
        )
        
        
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
}

// MARK: SquareGridJobDirector.Grid

extension SquareGridJobDirector {
    private func createGrid() {
        // Corners
        do {
            let size = 5
            grids.append(Grid(top: 0, left: 0, width: size, height: size, gate: Position(x: 4, y: 5)))
            grids.append(Grid(top: 0, left: 25, width: size, height: size, gate: Position(x: 25, y: 5)))
            grids.append(Grid(top: 25, left: 0, width: size, height: size, gate: Position(x: 4, y: 24)))
            grids.append(Grid(top: 25, left: 25, width: size, height: size, gate: Position(x: 25, y: 24)))
        }
        
        // Sides
        for y in [6, 12, 19] {
            let width = 4
            let height = y == 12 ? 6 : 5
            grids.append(Grid(top: y, left: 0, width: width, height: height, gate: Position(x: 4, y: y + 2)))
            grids.append(Grid(top: y, left: 26, width: width, height: height, gate: Position(x: 25, y: y + 2)))
        }
        
        // Top and bottom
        for x in [6, 12, 19] {
            let width = x == 12 ? 6 : 5
            let height = 4
            grids.append(Grid(top: 0, left: x, width: width, height: height, gate: Position(x: x + 2, y: 4)))
            grids.append(Grid(top: 26, left: x, width: width, height: height, gate: Position(x: x + 2, y: 25)))
        }
        
        // Center sides
        for x in [7, 18] {
            for y in [7, 13, 18] {
                let width = 5
                let height = y == 13 ? 4 : 5
                let gateX = x == 7 ? 6 : 23
                grids.append(Grid(top: y, left: x, width: width, height: height, gate: Position(x: gateX, y: y + 1)))
            }
        }
        
        // Center
        do {
            let width = 4
            grids.append(Grid(top: 7, left: 13, width: width, height: 7, gate: Position(x: 14, y: 6)))
            grids.append(Grid(top: 15, left: 13, width: width, height: 8, gate: Position(x: 14, y: 23)))
        }
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
        let direction = CommandUtil.deltaToCommand(delta: to - from).first?.delta ?? .zero
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
        let direction = CommandUtil.deltaToCommand(delta: to - from).first?.delta ?? .zero
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
    
    private func dumpGrids(grids: [Grid]) {
        for grid in grids {
            var f = [[String]](repeating: [String](repeating: ".", count: fieldSize), count: fieldSize)
            for x in grid.topLeft.x ... grid.bottomRight.x {
                for y in grid.topLeft.y ... grid.bottomRight.y {
                    f[y][x] = "0"
                }
            }
            f[grid.gate.y][grid.gate.x] = "!"
            var str = "\n"
            for y in 0 ..< fieldSize {
                for x in 0 ..< fieldSize {
                    str += f[y][x]
                }
                str += "\n"
            }
            IO.log(grid, str)
        }
    }

}
