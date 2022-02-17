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
    
    func directJobs(field: inout Field, humans: inout [Human], pets: inout [Pet], turn: Int) {
        if turn == 0 {
            grids = GridCreator().createGrid()
            assignGridJobs(field: &field, humans: &humans, pets: &pets)
            // Gather to center grid for capture wolves
            let positions = [
                Position(x: 7, y: 15),
                Position(x: 14, y: 7),
                Position(x: 15, y: 22),
                Position(x: 22, y: 14),
            ]
            for (i, human) in humans.enumerated() {
                human.assign(job: .init(units: [
                    .init(kind: .move, pos: positions[i % 4])
                ]))
            }
        }
        else if turn == 200 {
            let moves = [
                Position(x: 5, y: 15),
                Position(x: 14, y: 5),
                Position(x: 15, y: 24),
                Position(x: 24, y: 14),
            ]
            let blocks = [
                Position(x: 6, y: 15),
                Position(x: 14, y: 6),
                Position(x: 15, y: 23),
                Position(x: 23, y: 14),
            ]
            // Start working around and close gates
            for (i, human) in humans.enumerated() {
                human.assign(job: .init(units: [
                    .init(kind: .move, pos: moves[i % 4]),
                    .init(kind: .block, pos: blocks[i % 4]),
                ]))
            }
            for human in humans {
                human.brain = HumanBrainWithGridKnowledge(grids: grids)
                for _ in 0 ..< 10 {
                    human.assign(job: Schedule.Job(units: [
                        .init(kind: .patrol, pos: Position(x: 4, y: 4)),
                        .init(kind: .patrol, pos: Position(x: 4, y: 25)),
                        .init(kind: .patrol, pos: Position(x: 25, y: 25)),
                        .init(kind: .patrol, pos: Position(x: 25, y: 4)),
                    ].shuffled()))
                }
            }
        }
        else if turn >= 270 {
            // TODO: Do something
        }
    }

    private lazy var skipBlocks: [Position] = {
        var arr = [Position]()
        for grid in grids { arr.append(grid.gate) }
        // Where horizontal block and vertical block intersects
        let intersections = [
            Position(x: 5, y: 3),
            Position(x: 11, y: 3),
            Position(x: 18, y: 3),
            Position(x: 24, y: 3),
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
            Position(x: 5, y: 26),
            Position(x: 11, y: 26),
            Position(x: 18, y: 26),
            Position(x: 24, y: 26),
            Position(x: 5, y: 15),
            Position(x: 14, y: 5),
            Position(x: 24, y: 14),
            Position(x: 15, y: 24),
        ]
        return arr + intersections
    }()
}

// MARK: SquareGridJobDirector.Assign

extension SquareGridJobDirector {
    private func assignGridJobs(field: inout Field, humans: inout [Human], pets: inout [Pet]) {
        var jobs = [Schedule.Job]()
        
        var leftSideJob = Schedule.Job(units: [])
        var rightSideJob = Schedule.Job(units: [])
        let ys = [4, 11, 18, 25]
        for i in 0 ..< ys.count {
            leftSideJob +=
                createLineBlockJob(from: Position(x: 0, y: ys[i]), to: Position(x: 2, y: ys[i]))
            rightSideJob +=
                createLineBlockJob(from: Position(x: 29, y: ys[i]), to: Position(x: 27, y: ys[i]))
            if i + 1 < ys.count {
                leftSideJob += createBlockJobWithMove(
                    from: Position(x: 4, y: max(ys[i], 5)),
                    to: Position(x: 4, y: min(ys[i + 1], 24)),
                    checkDirections: [.left, .right],
                    skipBlocks: skipBlocks
                )
                rightSideJob += createBlockJobWithMove(
                    from: Position(x: 25, y: max(ys[i], 5)),
                    to: Position(x: 25, y: min(ys[i + 1], 24)),
                    checkDirections: [.left, .right],
                    skipBlocks: skipBlocks
                )
            }
        }
        jobs.append(leftSideJob)
        jobs.append(rightSideJob)
        
        var topJob = Schedule.Job(units: [
            .init(kind: .block, pos: Position(x: 4, y: 3))
        ])
        var bottomJob = Schedule.Job(units: [
            .init(kind: .block, pos: Position(x: 4, y: 26))
        ])
        let xs = [5, 11, 18, 24]
        for i in 0 ..< xs.count {
            topJob +=
                createLineBlockJob(from: Position(x: xs[i], y: 0), to: Position(x: xs[i], y: 2))
            bottomJob +=
                createLineBlockJob(from: Position(x: xs[i], y: 29), to: Position(x: xs[i], y: 27))
            if i + 1 < xs.count {
                topJob += createBlockJobWithMove(
                    from: Position(x: max(xs[i], 6), y: 4),
                    to: Position(x: min(xs[i + 1], 23), y: 4),
                    checkDirections: [.up, .down],
                    skipBlocks: skipBlocks
                )
                bottomJob += createBlockJobWithMove(
                    from: Position(x: max(xs[i], 6), y: 25),
                    to: Position(x: min(xs[i + 1], 23), y: 25),
                    checkDirections: [.up, .down],
                    skipBlocks: skipBlocks
                )
            }
        }
        topJob += Schedule.Job(units: [
            .init(kind: .block, pos: Position(x: 25, y: 3))
        ])
        bottomJob += Schedule.Job(units: [
            .init(kind: .block, pos: Position(x: 25, y: 26))
        ])
        jobs.append(topJob)
        jobs.append(bottomJob)
        
        // Center
        do {
            // Horizontal
            jobs.append(
                createLineBlockJob(from: Position(x: 6, y: 14), to: Position(x: 13, y: 14), skipBlocks: skipBlocks)
            )
            jobs.append(
                createLineBlockJob(from: Position(x: 6, y: 16), to: Position(x: 13, y: 16), skipBlocks: skipBlocks)
            )
            jobs.append(
                createLineBlockJob(from: Position(x: 6, y: 20), to: Position(x: 13, y: 20), skipBlocks: skipBlocks)
            )
            
            jobs.append(
                createLineBlockJob(from: Position(x: 16, y: 9), to: Position(x: 23, y: 9), skipBlocks: skipBlocks)
            )
            jobs.append(
                createLineBlockJob(from: Position(x: 16, y: 13), to: Position(x: 23, y: 13), skipBlocks: skipBlocks)
            )
            jobs.append(
                createLineBlockJob(from: Position(x: 16, y: 15), to: Position(x: 23, y: 15), skipBlocks: skipBlocks)
            )

            // Vertical
            jobs.append(
                createLineBlockJob(from: Position(x: 9, y: 6), to: Position(x: 9, y: 13), skipBlocks: skipBlocks)
            )
            jobs.append(
                createLineBlockJob(from: Position(x: 13, y: 6), to: Position(x: 13, y: 13), skipBlocks: skipBlocks)
            )
            jobs.append(
                createLineBlockJob(from: Position(x: 15, y: 6), to: Position(x: 15, y: 12), skipBlocks: skipBlocks)
            )
            jobs.append(
                createLineBlockJob(from: Position(x: 14, y: 17), to: Position(x: 14, y: 23), skipBlocks: skipBlocks)
            )
            jobs.append(
                createLineBlockJob(from: Position(x: 20, y: 16), to: Position(x: 20, y: 23), skipBlocks: skipBlocks)
            )
            jobs.append(
                createLineBlockJob(from: Position(x: 16, y: 16), to: Position(x: 16, y: 23), skipBlocks: skipBlocks)
            )
        }
        
        assignJobs(jobs: jobs, humans: &humans)
    }
}

// MARK: SquareGridJobDirector.Helper

extension SquareGridJobDirector {
    private func createSquareBlockJob(
        points: [Position],
        skipBlocks: [Position] = []
    ) -> Schedule.Job {
        var job = Schedule.Job(units: [])
        guard points.count > 0 else {
            IO.log("Points.count is 0", type: .warn)
            return job
        }
        for i in 0 ..< points.count - 1 {
            job += createLineBlockJob(from: points[i], to: points[i + 1], skipBlocks: skipBlocks)
        }
        return job
    }
    
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
