protocol GridManager {
    var dogCaptureBlocks: [Position] { get }
    var dogCapturePositions: [Position] { get }
    var dogCaptureGrid: Grid { get }
    var skipBlocks: [Position] { get }
    var corners: [[Position]] { get }
    func createGrid() -> [Grid]
    func createGridJobs() -> [Schedule.Job]
}

extension GridManager {
    // For Debug
    func dumpGrids(grids: [Grid]) {
        var f = [[String]](repeating: [String](repeating: ".", count: fieldSize), count: fieldSize)
        for grid in grids {
            for pos in grid.zone {
                f[pos.y][pos.x] = "Q"
            }
            for gate in grid.gates {
                f[gate.y][gate.x] = "!"
            }
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

class SquareGridManagerV2: GridManager {
    let dogCaptureBlocks = [
        Position(x: 7, y: 9),
        Position(x: 22, y: 20),
    ]
    let dogCapturePositions = [
        Position(x: 6, y: 9),
        Position(x: 23, y: 20),
    ]
    let corners: [[Position]] = [
        [Position(x: 4, y: 25), Position(x: 25, y: 25), Position(x: 25, y: 4), Position(x: 4, y: 4),],
        [Position(x: 25, y: 25), Position(x: 25, y: 4), Position(x: 4, y: 4), Position(x: 4, y: 25),],
        [Position(x: 25, y: 4), Position(x: 4, y: 4), Position(x: 4, y: 25), Position(x: 25, y: 25),],
        [Position(x: 4, y: 4), Position(x: 4, y: 25), Position(x: 25, y: 25), Position(x: 25, y: 4),],
    ]
    let dogCaptureGrid: Grid = {
        var positions = [Position]()
        for x in 8 ... 13 {
            positions.append(Position(x: x, y: 9))
        }
        for y in 9 ... 15 {
            positions.append(Position(x: 14, y: y))
        }
        for y in 14 ... 20 {
            positions.append(Position(x: 15, y: y))
        }
        for x in 16 ... 21 {
            positions.append(Position(x: x, y: 20))
        }
        positions.append(Position(x: 13, y: 10))
        positions.append(Position(x: 13, y: 13))
        positions.append(Position(x: 16, y: 16))
        positions.append(Position(x: 16, y: 19))
        
        let gates: [Position] = [
            Position(x: 7, y: 9),
            Position(x: 22, y: 20),
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
            Position(x: 1, y: 3),
            Position(x: 7, y: 3),
            Position(x: 12, y: 3),
            Position(x: 17, y: 3),
            Position(x: 22, y: 3),
            Position(x: 28, y: 3),
            Position(x: 3, y: 5),
            Position(x: 5, y: 5),
            Position(x: 15, y: 5),
            Position(x: 18, y: 5),
            Position(x: 21, y: 5),
            Position(x: 24, y: 5),
            Position(x: 26, y: 5),
            Position(x: 5, y: 8),
            Position(x: 15, y: 8),
            Position(x: 3, y: 9),
            Position(x: 26, y: 9),
            Position(x: 5, y: 10),
            Position(x: 13, y: 10),
            Position(x: 5, y: 13),
            Position(x: 13, y: 13),
            Position(x: 16, y: 13),
            Position(x: 18, y: 13),
            Position(x: 21, y: 13),
            Position(x: 24, y: 13),
            Position(x: 3, y: 14),
            Position(x: 26, y: 14),
            Position(x: 5, y: 16),
            Position(x: 8, y: 16),
            Position(x: 11, y: 16),
            Position(x: 13, y: 16),
            Position(x: 16, y: 16),
            Position(x: 24, y: 16),
            Position(x: 3, y: 19),
            Position(x: 16, y: 19),
            Position(x: 24, y: 19),
            Position(x: 26, y: 19),
            Position(x: 14, y: 21),
            Position(x: 24, y: 21),
            Position(x: 3, y: 24),
            Position(x: 5, y: 24),
            Position(x: 8, y: 24),
            Position(x: 11, y: 24),
            Position(x: 14, y: 24),
            Position(x: 24, y: 24),
            Position(x: 26, y: 24),
            Position(x: 1, y: 26),
            Position(x: 7, y: 26),
            Position(x: 12, y: 26),
            Position(x: 17, y: 26),
            Position(x: 22, y: 26),
            Position(x: 28, y: 26),
            
            // Dog
            Position(x: 5, y: 9),
            Position(x: 24, y: 20)
        ]
        return arr + intersections + dogCaptureGrid.zone
    }()

    func createGridJobs() -> [Schedule.Job] {
        var jobs = [Schedule.Job]()
        
        var leftSideJob = Schedule.Job(units: [])
        var rightSideJob = Schedule.Job(units: [])
        let ys = [5, 9, 14, 19, 24]
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
        
        var topJob = Schedule.Job(units: [])
        var bottomJob = Schedule.Job(units: [])
        topJob +=
            JobUtil.createLineBlockJob(from: Position(x: 1, y: 1), to: Position(x: 1, y: 2), skipBlocks: skipBlocks)
        topJob +=
            JobUtil.createLineBlockJob(from: Position(x: 2, y: 3), to: Position(x: 6, y: 3), skipBlocks: skipBlocks)
        topJob += JobUtil.createBlockJobWithMove(
            from: Position(x: 6, y: 4),
            to: Position(x: 6, y: 4),
            checkDirections: [.up, .down],
            skipBlocks: skipBlocks
        )
        bottomJob +=
            JobUtil.createLineBlockJob(from: Position(x: 1, y: 28), to: Position(x: 1, y: 27), skipBlocks: skipBlocks)
        bottomJob +=
            JobUtil.createLineBlockJob(from: Position(x: 2, y: 26), to: Position(x: 6, y: 26), skipBlocks: skipBlocks)
        bottomJob += JobUtil.createBlockJobWithMove(
            from: Position(x: 6, y: 25),
            to: Position(x: 6, y: 25),
            checkDirections: [.up, .down],
            skipBlocks: skipBlocks
        )
        let xs = [7, 12, 17, 22]
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
        topJob +=
            JobUtil.createLineBlockJob(from: Position(x: 23, y: 3), to: Position(x: 27, y: 3), skipBlocks: skipBlocks)
        topJob +=
            JobUtil.createLineBlockJob(from: Position(x: 28, y: 1), to: Position(x: 28, y: 2), skipBlocks: skipBlocks)
        topJob += JobUtil.createBlockJobWithMove(
            from: Position(x: 23, y: 4),
            to: Position(x: 23, y: 4),
            checkDirections: [.up, .down],
            skipBlocks: skipBlocks
        )
        bottomJob +=
            JobUtil.createLineBlockJob(from: Position(x: 23, y: 26), to: Position(x: 27, y: 26), skipBlocks: skipBlocks)
        bottomJob +=
            JobUtil.createLineBlockJob(from: Position(x: 28, y: 27), to: Position(x: 28, y: 26), skipBlocks: skipBlocks)
        bottomJob += JobUtil.createBlockJobWithMove(
            from: Position(x: 23, y: 25),
            to: Position(x: 23, y: 25),
            checkDirections: [.up, .down],
            skipBlocks: skipBlocks
        )
        jobs.append(topJob)
        jobs.append(bottomJob)
        
        // Horizontal
        jobs.append(
            JobUtil.createBlockJobWithMove(from: Position(x: 6, y: 9), to: Position(x: 14, y: 9), checkDirections: [.up, .down], skipBlocks: skipBlocks)
        )
        jobs.append(
            JobUtil.createBlockJobWithMove(from: Position(x: 15, y: 20), to: Position(x: 23, y: 20), checkDirections: [.up, .down], skipBlocks: skipBlocks)
        )
        
        // Center
        do {
            // Horizontal
            var job = Schedule.Job(units: [])
            for y in [13, 16] {
                job +=
                    JobUtil.createLineBlockJob(
                        from: Position(x: y == 13 ? 6 : 14, y: y),
                        to: Position(x: y == 13 ? 14 : 6, y: y),
                        skipBlocks: skipBlocks
                    )
            }
            jobs.append(job)
            job = Schedule.Job(units: [])
            for y in [13, 16] {
                job +=
                    JobUtil.createLineBlockJob(
                        from: Position(x: y == 16 ? 23 : 15, y: y),
                        to: Position(x: y == 16 ? 15 : 23, y: y),
                        skipBlocks: skipBlocks
                    )
            }
            
            jobs.append(job)
            job = Schedule.Job(units: [])
            // Vertical
            for x in [8, 11, 14] {
                job +=
                    JobUtil.createLineBlockJob(
                        from: Position(x: x, y: x % 2 == 0 ? 23 : 17),
                        to: Position(x: x, y: x % 2 == 0 ? 17 : 23),
                        skipBlocks: skipBlocks
                    )
            }
            jobs.append(job)
            job = Schedule.Job(units: [])
            for x in [15, 18, 21] {
                job +=
                    JobUtil.createLineBlockJob(
                        from: Position(x: x, y: x % 2 == 0 ? 12 : 6),
                        to: Position(x: x, y: x % 2 == 0 ? 6 : 12),
                        skipBlocks: skipBlocks
                    )
            }
            jobs.append(job)
            
            jobs.append(
                JobUtil.createLineBlockJob(
                    from: Position(x: 13, y: 15),
                    to: Position(x: 13, y: 11),
                    skipBlocks: skipBlocks
                )
            )
            jobs.append(
                JobUtil.createLineBlockJob(
                    from: Position(x: 16, y: 14),
                    to: Position(x: 16, y: 18),
                    skipBlocks: skipBlocks
                )
            )
        }
        
        return jobs
    }
    
    func createGrid() -> [Grid] {
        var grids = [Grid]()
        // Corners
        do {
            let width = 7
            let height = 3
            grids.append(
                Grid(
                    zone: Util.createSquare(top: 0, left: 0, width: width, height: height) + Util.createSquare(top: 3, left: 0, width: 3, height: 2),
                    gates: [Position(x: 3, y: 4)]
                )
            )
            grids.append(
                Grid(
                    zone: Util.createSquare(top: 0, left: 23, width: width, height: height) + Util.createSquare(top: 3, left: 27, width: 3, height: 2),
                    gates: [Position(x: 26, y: 4)]
                )
            )
            grids.append(
                Grid(
                    zone: Util.createSquare(top: 27, left: 0, width: width, height: height) + Util.createSquare(top: 25, left: 0, width: 3, height: 2),
                    gates: [Position(x: 3, y: 25)]
                )
            )
            grids.append(
                Grid(
                    zone: Util.createSquare(top: 27, left: 23, width: width, height: height) + Util.createSquare(top: 25, left: 27, width: 3, height: 2),
                    gates: [Position(x: 26, y: 25)]
                )
            )
        }
        
        // Sides
        for y in [6, 10, 15, 20] {
            let width = 3
            let height = y == 6 ? 3 : 4
            grids.append(Grid(top: y, left: 0, width: width, height: height, gates: [Position(x: 3, y: y + 1)]))
            grids.append(Grid(top: y, left: 27, width: width, height: height, gates: [Position(x: 26, y: y + 1)]))
        }
        
        // Top and bottom
        for x in [8, 13, 18] {
            let width = 4
            let height = 3
            grids.append(Grid(top: 0, left: x, width: width, height: height, gates: [Position(x: x + 1, y: 3)]))
            grids.append(Grid(top: 27, left: x, width: width, height: height, gates: [Position(x: x + 1, y: 26)]))
        }
        
        // Center thin vertical
        do {
            let width = 2
            let height = 7
            for x in [16, 19] {
                grids.append(
                    Grid(
                        zone:
                            Util.createSquare(
                                top: 6,
                                left: x,
                                width: width,
                                height: height
                            ) + (x == 16 ? [Position(x: 16, y: 13)] : []),
                        gates: [Position(x: x, y: 5)]
                    )
                )
            }
            grids.append(
                Grid(zone: Util.createSquare(top: 6, left: 22, width: width, height: height), gates: [Position(x: 24, y: 12)])
            )
            for x in [9, 12] {
                grids.append(
                    Grid(
                        zone:
                            Util.createSquare(
                                top: 17,
                                left: x,
                                width: width,
                                height: height
                            ) + (x == 12 ? [Position(x: 13, y: 16)] : []),
                        gates: [Position(x: x, y: 24)]
                    )
                )
            }
            grids.append(
                Grid(zone: Util.createSquare(top: 17, left: 6, width: width, height: height), gates: [Position(x: 5, y: 17)])
            )
        }
        
        // Center thin horizontal
        do {
            let height = 2
            grids.append(
                Grid(zone: Util.createSquare(top: 6, left: 6, width: 9, height: height), gates: [Position(x: 5, y: 6)])
            )
            for y in [11, 14] {
                grids.append(
                    Grid(
                        zone:
                            Util.createSquare(
                                top: y,
                                left: 6,
                                width: 7,
                                height: height
                            ) + (y == 14 ? [Position(x: 8, y: 16), Position(x: 11, y: 16)] : []),
                        gates: [Position(x: 5, y: y)]
                    )
                )
            }
            grids.append(
                Grid(zone: Util.createSquare(top: 22, left: 15, width: 9, height: height), gates: [Position(x: 24, y: 23)])
            )
            for y in [14, 17] {
                grids.append(
                    Grid(
                        zone:
                            Util.createSquare(
                                top: y,
                                left: 17,
                                width: 7,
                                height: height
                            ) + (y == 14 ? [Position(x: 18, y: 13), Position(x: 21, y: 13)] : []),
                        gates: [Position(x: 24, y: y)]
                    )
                )
            }
        }
        return grids
    }
}

class SquareGridManager: GridManager {
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
            Position(x: 10, y: 3),
            Position(x: 15, y: 3),
            Position(x: 20, y: 3),
            Position(x: 24, y: 3),
            Position(x: 3, y: 4),
            Position(x: 26, y: 4),
            Position(x: 5, y: 5),
            Position(x: 9, y: 5),
            Position(x: 13, y: 5),
            Position(x: 15, y: 5),
            Position(x: 18, y: 5),
            Position(x: 24, y: 5),
            Position(x: 3, y: 9),
            Position(x: 18, y: 9),
            Position(x: 24, y: 9),
            Position(x: 26, y: 9),
            Position(x: 5, y: 11),
            Position(x: 9, y: 11),
            Position(x: 13, y: 11),
            Position(x: 15, y: 13),
            Position(x: 18, y: 13),
            Position(x: 24, y: 13),
            Position(x: 3, y: 14),
            Position(x: 5, y: 14),
            Position(x: 13, y: 14),
            Position(x: 26, y: 14),
            Position(x: 16, y: 15),
            Position(x: 24, y: 15),
            Position(x: 5, y: 16),
            Position(x: 11, y: 16),
            Position(x: 14, y: 16),
            Position(x: 16, y: 18),
            Position(x: 20, y: 18),
            Position(x: 24, y: 18),
            Position(x: 3, y: 19),
            Position(x: 26, y: 19),
            Position(x: 5, y: 20),
            Position(x: 11, y: 20),
            Position(x: 5, y: 24),
            Position(x: 11, y: 24),
            Position(x: 14, y: 24),
            Position(x: 16, y: 24),
            Position(x: 20, y: 24),
            Position(x: 24, y: 24),
            Position(x: 3, y: 25),
            Position(x: 26, y: 25),
            Position(x: 5, y: 26),
            Position(x: 10, y: 26),
            Position(x: 15, y: 26),
            Position(x: 20, y: 26),
            Position(x: 24, y: 26),
            Position(x: 5, y: 15),
            Position(x: 24, y: 14),
            Position(x: 14, y: 5),
            Position(x: 15, y: 24),
        ]
        return arr + intersections
    }()

    func createGridJobs() -> [Schedule.Job] {
        var jobs = [Schedule.Job]()
        
        var leftSideJob = Schedule.Job(units: [])
        var rightSideJob = Schedule.Job(units: [])
        let ys = [4, 9, 14, 19, 25]
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
        let xs = [5, 10, 15, 20, 24]
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
        for y in [5, 10, 15, 20] {
            let width = 3
            let height = y == 20 ? 5 : 4
            grids.append(Grid(top: y, left: 0, width: width, height: height, gates: [Position(x: 3, y: y + 2)]))
            grids.append(Grid(top: y, left: 27, width: width, height: height, gates: [Position(x: 26, y: y + 2)]))
        }
        
        // Top and bottom
        for x in [6, 11, 16, 21] {
            let width = x == 21 ? 3 : 4
            let height = 3
            grids.append(Grid(top: 0, left: x, width: width, height: height, gates: [Position(x: x + 1, y: 3)]))
            grids.append(Grid(top: 27, left: x, width: width, height: height, gates: [Position(x: x + 1, y: 26)]))
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
