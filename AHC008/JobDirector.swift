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
    func assignJobs(jobs: [Schedule.Job], humans: inout [Human], compare: Compare) {
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
    
    func directJobs(field: inout Field, humans: inout [Human], pets: inout [Pet], turn: Int) {
        if turn == 0 {
            createGrid()
            assignGridJobs(field: &field, humans: &humans, pets: &pets)
        }
    }
    
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
                let gateX = x == 7 ? 6 : 19
                grids.append(Grid(top: y, left: x, width: width, height: height, gate: Position(x: gateX, y: y + 1)))
            }
        }
        
        // Center
        do {
            let width = 4
            grids.append(Grid(top: 7, left: 13, width: width, height: 7, gate: Position(x: 14, y: 6)))
            grids.append(Grid(top: 15, left: 13, width: width, height: 8, gate: Position(x: 23, y: 6)))
        }
    }
    
    private func assignGridJobs(field: inout Field, humans: inout [Human], pets: inout [Pet]) {
        var jobs = [Schedule.Job]()
        let gates: [Position] = {
            var arr = [Position]()
            for grid in grids { arr.append(grid.gate) }
            return arr
        }()
        
        // Side horizontal
        for y in [5, 11, 18, 24] {
            for x in [0, 26] {
                jobs.append(JobUtil.createLineBlockJob(points: [
                    Position(x: x, y: y),
                    Position(x: x + 3, y: y),
                ], skipBlocks: gates))
            }
        }
        
        // Top and bottom horizontal
        for y in [4, 25] {
            jobs.append(JobUtil.createLineBlockJob(points: [
                Position(x: 6, y: y),
                Position(x: 10, y: y),
            ], skipBlocks: gates))
            
            jobs.append(JobUtil.createLineBlockJob(points: [
                Position(x: 12, y: y),
                Position(x: 17, y: y),
            ], skipBlocks: gates))
            
            jobs.append(JobUtil.createLineBlockJob(points: [
                Position(x: 19, y: y),
                Position(x: 23, y: y),
            ], skipBlocks: gates))
        }
        
        // Center sides horizontal
        for y in [6, 12, 17, 23] {
            jobs.append(JobUtil.createLineBlockJob(points: [
                Position(x: 7, y: y),
                Position(x: 11, y: y),
            ], skipBlocks: gates))
            
            jobs.append(JobUtil.createLineBlockJob(points: [
                Position(x: 18, y: y),
                Position(x: 22, y: y),
            ], skipBlocks: gates))
        }
        
        // Center center horizontal
        for y in [6, 14, 23] {
            jobs.append(JobUtil.createLineBlockJob(points: [
                Position(x: 13, y: y),
                Position(x: 16, y: y),
            ], skipBlocks: gates))
        }
        
        // Side vertical
        for x in [4, 25] {
            jobs.append(JobUtil.createLineBlockJob(points: [
                Position(x: x, y: 6),
                Position(x: x, y: 24),
            ], skipBlocks: gates))
        }
        
        // Top and bottom vertical
        for x in [5, 11, 18, 24] {
            jobs.append(JobUtil.createLineBlockJob(points: [
                Position(x: x, y: 0),
                Position(x: x, y: 4),
            ], skipBlocks: gates))
            
            jobs.append(JobUtil.createLineBlockJob(points: [
                Position(x: x, y: 25),
                Position(x: x, y: 29),
            ], skipBlocks: gates))
        }
        
        // Center vertical
        for x in [6, 12, 17, 23] {
            jobs.append(JobUtil.createLineBlockJob(points: [
                Position(x: x, y: 6),
                Position(x: x, y: 23)
            ], skipBlocks: gates))
        }
        
        let eval: Eval = { human, job in
            human.assignedCost(job: job)
        }
        
        let cmp: Compare = { (testHuman, currentAssignee, job) in
            if eval(testHuman, job) < eval(currentAssignee, job) {
                return testHuman
            }
            return currentAssignee
        }
        
        assignJobs(jobs: jobs, humans: &humans, compare: cmp)
    }
}
