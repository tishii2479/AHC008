class SquareGridManagerV2: GridManager {
    let dogCaptureBlocks = [
        Position(x: 7, y: 15),
        Position(x: 15, y: 22),
        Position(x: 22, y: 14),
        Position(x: 14, y: 7),
    ]
    let dogCapturePositions = [
        Position(x: 6, y: 15),
        Position(x: 15, y: 23),
        Position(x: 23, y: 14),
        Position(x: 14, y: 6),
    ]
    let corners: [[Position]] = [
        [Position(x: 4, y: 25), Position(x: 25, y: 25), Position(x: 25, y: 4), Position(x: 4, y: 4),],
        [Position(x: 25, y: 25), Position(x: 25, y: 4), Position(x: 4, y: 4), Position(x: 4, y: 25),],
        [Position(x: 25, y: 4), Position(x: 4, y: 4), Position(x: 4, y: 25), Position(x: 25, y: 25),],
        [Position(x: 4, y: 4), Position(x: 4, y: 25), Position(x: 25, y: 25), Position(x: 25, y: 4),],
    ]
    let dogCaptureGrid: Grid = {
        var positions = [Position]()
        for x in 8 ... 14 {
            positions.append(Position(x: x, y: 15))
        }
        for x in 15 ... 21 {
            positions.append(Position(x: x, y: 14))
        }
        for y in 8 ... 14 {
            positions.append(Position(x: 14, y: y))
        }
        for y in 15 ... 21 {
            positions.append(Position(x: 15, y: y))
        }
        positions.append(Position(x: 15, y: 13))
        positions.append(Position(x: 13, y: 14))
        positions.append(Position(x: 16, y: 15))
        positions.append(Position(x: 14, y: 16))
        positions.append(Position(x: 11, y: 16))
        positions.append(Position(x: 18, y: 13))
        positions.append(Position(x: 13, y: 11))
        positions.append(Position(x: 16, y: 18))
        
        let gates: [Position] = [
            Position(x: 7, y: 15),
            Position(x: 22, y: 14),
            Position(x: 14, y: 7),
            Position(x: 15, y: 22),
        ]
        return Grid(zone: positions, gates: gates)
    }()
    
    lazy var skipBlocks: [Position] = {
        var arr = [Position]()
        for grid in createGrid() {
            for gate in grid.gates {
                arr.append(gate)
            }
        }
        // Where horizontal block and vertical block intersects
        let intersections = [
            Position(x: 5, y: 3),
            Position(x: 9, y: 3),
            Position(x: 13, y: 3),
            Position(x: 17, y: 3),
            Position(x: 21, y: 3),
            Position(x: 24, y: 3),
            Position(x: 3, y: 4),
            Position(x: 26, y: 4),
            Position(x: 5, y: 5),
            Position(x: 9, y: 5),
            Position(x: 13, y: 5),
            Position(x: 14, y: 5),
            Position(x: 15, y: 5),
            Position(x: 18, y: 5),
            Position(x: 24, y: 5),
            Position(x: 3, y: 8),
            Position(x: 26, y: 8),
            Position(x: 18, y: 9),
            Position(x: 24, y: 9),
            Position(x: 5, y: 11),
            Position(x: 9, y: 11),
            Position(x: 13, y: 11),
            Position(x: 3, y: 12),
            Position(x: 26, y: 12),
            Position(x: 15, y: 13),
            Position(x: 18, y: 13),
            Position(x: 24, y: 13),
            Position(x: 5, y: 14),
            Position(x: 13, y: 14),
            Position(x: 24, y: 14),
            Position(x: 5, y: 15),
            Position(x: 16, y: 15),
            Position(x: 24, y: 15),
            Position(x: 5, y: 16),
            Position(x: 11, y: 16),
            Position(x: 14, y: 16),
            Position(x: 3, y: 17),
            Position(x: 26, y: 17),
            Position(x: 16, y: 18),
            Position(x: 20, y: 18),
            Position(x: 24, y: 19),
            Position(x: 5, y: 20),
            Position(x: 11, y: 20),
            Position(x: 3, y: 21),
            Position(x: 26, y: 21),
            Position(x: 5, y: 24),
            Position(x: 11, y: 24),
            Position(x: 14, y: 24),
            Position(x: 15, y: 24),
            Position(x: 16, y: 24),
            Position(x: 20, y: 24),
            Position(x: 24, y: 24),
            Position(x: 3, y: 25),
            Position(x: 26, y: 25),
            Position(x: 5, y: 26),
            Position(x: 9, y: 26),
            Position(x: 13, y: 26),
            Position(x: 17, y: 26),
            Position(x: 21, y: 26),
            Position(x: 24, y: 26),
        ]
        return arr + intersections
    }()

    func createGridJobs() -> [Schedule.Job] {
        var jobs = [Schedule.Job]()
        
        var leftSideJob = Schedule.Job(units: [])
        var rightSideJob = Schedule.Job(units: [])
        let ys = [4, 8, 12, 17, 21, 25]
        for i in 0 ..< ys.count {
            leftSideJob +=
                JobUtil.createLineBlockJob(from: Position(x: 0, y: ys[i]), to: Position(x: 2, y: ys[i]))
            rightSideJob +=
                JobUtil.createLineBlockJob(from: Position(x: 29, y: ys[i]), to: Position(x: 27, y: ys[i]))
            if i + 1 < ys.count {
                leftSideJob += JobUtil.createBlockJobWithMove(
                    from: Position(x: 4, y: max(ys[i], 5)),
                    to: Position(x: 4, y: min(ys[i + 1], 24)),
                    checkDirections: [.left, .right],
                    skipBlocks: skipBlocks
                )
                rightSideJob += JobUtil.createBlockJobWithMove(
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
        let xs = [5, 9, 13, 17, 21, 24]
        for i in 0 ..< xs.count {
            topJob +=
                JobUtil.createLineBlockJob(from: Position(x: xs[i], y: 0), to: Position(x: xs[i], y: 2))
            bottomJob +=
                JobUtil.createLineBlockJob(from: Position(x: xs[i], y: 29), to: Position(x: xs[i], y: 27))
            if i + 1 < xs.count {
                topJob += JobUtil.createBlockJobWithMove(
                    from: Position(x: max(xs[i], 5), y: 4),
                    to: Position(x: min(xs[i + 1], 24), y: 4),
                    checkDirections: [.up, .down],
                    skipBlocks: skipBlocks
                )
                bottomJob += JobUtil.createBlockJobWithMove(
                    from: Position(x: max(xs[i], 5), y: 25),
                    to: Position(x: min(xs[i + 1], 24), y: 25),
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
        
        // Horizontal
        jobs.append(
            JobUtil.createBlockJobWithMove(from: Position(x: 13, y: 15), to: Position(x: 6, y: 15), checkDirections: [.up, .down], skipBlocks: skipBlocks)
        )
        jobs.append(
            JobUtil.createBlockJobWithMove(from: Position(x: 16, y: 14), to: Position(x: 23, y: 14), checkDirections: [.up, .down], skipBlocks: skipBlocks)
        )
        // Vertical
        jobs.append(
            JobUtil.createBlockJobWithMove(from: Position(x: 14, y: 6), to: Position(x: 14, y: 13), checkDirections: [.left, .right], skipBlocks: skipBlocks)
        )
        jobs.append(
            JobUtil.createBlockJobWithMove(from: Position(x: 15, y: 16), to: Position(x: 15, y: 23), checkDirections: [.left, .right], skipBlocks: skipBlocks)
        )
        
        // Center
        do {
            // Horizontal
            jobs.append(
                JobUtil.createLineBlockJob(from: Position(x: 6, y: 20), to: Position(x: 10, y: 20), skipBlocks: skipBlocks)
            )
            jobs.append(
                JobUtil.createLineBlockJob(from: Position(x: 19, y: 9), to: Position(x: 23, y: 9), skipBlocks: skipBlocks)
            )
            jobs.append(
                JobUtil.createLineBlockJob(from: Position(x: 6, y: 11), to: Position(x: 12, y: 11), skipBlocks: skipBlocks)
            )
            jobs.append(
                JobUtil.createLineBlockJob(from: Position(x: 17, y: 18), to: Position(x: 23, y: 18), skipBlocks: skipBlocks)
            )

            // Vertical
            jobs.append(
                JobUtil.createLineBlockJob(from: Position(x: 9, y: 6), to: Position(x: 9, y: 10), skipBlocks: skipBlocks)
            )
            jobs.append(
                JobUtil.createLineBlockJob(from: Position(x: 20, y: 19), to: Position(x: 20, y: 23), skipBlocks: skipBlocks)
            )
            jobs.append(
                JobUtil.createLineBlockJob(from: Position(x: 11, y: 23), to: Position(x: 11, y: 17), skipBlocks: skipBlocks)
            )
            jobs.append(
                JobUtil.createLineBlockJob(from: Position(x: 18, y: 12), to: Position(x: 18, y: 6), skipBlocks: skipBlocks)
            )
        }
        
        return jobs
    }
    
    func createGrid() -> [Grid] {
        var grids = [Grid]()
        // Corners
        do {
            let width = 5
            let height = 4
            grids.append(
                Grid(
                    zone: Util.createSquare(top: 0, left: 0, width: width, height: height, exclude: [Position(x: 4, y: 3)]),
                    gates: [Position(x: 3, y: 4)]
                )
            )
            grids.append(
                Grid(
                    zone: Util.createSquare(top: 0, left: 25, width: width, height: height, exclude: [Position(x: 25, y: 3)]),
                    gates: [Position(x: 26, y: 4)]
                )
            )
            grids.append(
                Grid(
                    zone: Util.createSquare(top: 26, left: 0, width: width, height: height, exclude: [Position(x: 4, y: 26)]),
                    gates: [Position(x: 3, y: 25)]
                )
            )
            grids.append(
                Grid(
                    zone: Util.createSquare(top: 26, left: 25, width: width, height: height, exclude: [Position(x: 25, y: 26)]),
                    gates: [Position(x: 26, y: 25)]
                )
            )
        }
        
        // Sides
        for y in [5, 9, 13, 18, 22] {
            let width = 3
            let height = y == 13 ? 4 : 3
            grids.append(Grid(top: y, left: 0, width: width, height: height, gates: [Position(x: 3, y: y )]))
            grids.append(Grid(top: y, left: 27, width: width, height: height, gates: [Position(x: 26, y: y)]))
        }
        
        // Top and bottom
        for x in [6, 10, 14, 18, 22] {
            let width = x == 22 ? 2 : 3
            let height = 3
            grids.append(Grid(top: 0, left: x, width: width, height: height, gates: [Position(x: x, y: 3)]))
            grids.append(Grid(top: 27, left: x, width: width, height: height, gates: [Position(x: x, y: 26)]))
        }
        
        // Center vertical
        do {
            let width = 3
            let height = 5
            grids.append(Grid(top: 6, left: 6, width: width, height: height, gates: [Position(x: 7, y: 5)]))
            grids.append(Grid(top: 6, left: 10, width: width, height: height, gates: [Position(x: 11, y: 5)]))
            
            grids.append(Grid(top: 19, left: 17, width: width, height: height, gates: [Position(x: 18, y: 24)]))
            grids.append(Grid(top: 19, left: 21, width: width, height: height, gates: [Position(x: 22, y: 24)]))
        }
        
        // Center thin vertical
        do {
            let width = 2
            let height = 7
            grids.append(
                Grid(zone: Util.createSquare(top: 6, left: 16, width: width, height: height) + [Position(x: 18, y: 9)], gates: [Position(x: 17, y: 5)])
            )
            grids.append(
                Grid(zone: Util.createSquare(top: 17, left: 12, width: width, height: height) + [Position(x: 11, y: 20)], gates: [Position(x: 12, y: 24)])
            )
        }
        
        // Center horizontal
        do {
            let width = 5
            let height = 3
            grids.append(Grid(top: 17, left: 6, width: width, height: height, gates: [Position(x: 5, y: 18)]))
            grids.append(Grid(top: 21, left: 6, width: width, height: height, gates: [Position(x: 5, y: 22)]))
            
            grids.append(Grid(top: 6, left: 19, width: width, height: height, gates: [Position(x: 24, y: 7)]))
            grids.append(Grid(top: 10, left: 19, width: width, height: height, gates: [Position(x: 24, y: 11)]))
        }
        
        // Center thin horizontal
        do {
            let width = 7
            let height = 2
            grids.append(
                Grid(zone: Util.createSquare(top: 12, left: 6, width: width, height: height) + [Position(x: 9, y: 11)], gates: [Position(x: 5, y: 12)])
            )
            grids.append(
                Grid(zone: Util.createSquare(top: 16, left: 17, width: width, height: height) + [Position(x: 20, y: 18)], gates: [Position(x: 24, y: 17)])
            )
        }
        return grids
    }
}