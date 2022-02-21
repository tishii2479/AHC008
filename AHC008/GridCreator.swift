protocol GridManager {
    var dogCaptureBlocks: [Position] { get }
    var dogCapturePositions: [Position] { get }
    var dogCaptureZone: [Position] { get }
    var skipBlocks: [Position] { get }
    func createGrid() -> [Grid]
    func createCatGrids() -> [Grid]
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

class SquareGridManagerWithCatCapture: GridManager {
    let dogCaptureBlocks = [
        Position(x: 6, y: 15),
        Position(x: 23, y: 15),
    ]
    let dogCapturePositions = [
        Position(x: 5, y: 15),
        Position(x: 24, y: 15),
    ]
    let dogCaptureZone: [Position] = {
        var positions = [Position]()
        for x in 7 ... 22 {
            positions.append(Position(x: x, y: 15))
        }
        return positions
    }()
    
    lazy var skipBlocks: [Position] = {
        var arr = [Position]()
        for grid in createGrid() + createCatGrids() {
            for gate in grid.gates {
                arr.append(gate)
            }
        }
        let intersections = [
            Position(x: 5, y: 3),
            Position(x: 11, y: 3),
            Position(x: 18, y: 3),
            Position(x: 24, y: 3),
            Position(x: 3, y: 4),
            Position(x: 26, y: 4),
            Position(x: 5, y: 5),
            Position(x: 11, y: 5),
            Position(x: 18, y: 5),
            Position(x: 24, y: 5),
            Position(x: 5, y: 10),
            Position(x: 11, y: 10),
            Position(x: 18, y: 10),
            Position(x: 24, y: 10),
            Position(x: 3, y: 11),
            Position(x: 5, y: 11),
            Position(x: 24, y: 11),
            Position(x: 26, y: 11),
            Position(x: 5, y: 13),
            Position(x: 24, y: 13),
            Position(x: 5, y: 15),
            Position(x: 24, y: 15),
            Position(x: 5, y: 17),
            Position(x: 24, y: 17),
            Position(x: 3, y: 18),
            Position(x: 26, y: 18),
            Position(x: 5, y: 19),
            Position(x: 24, y: 19),
            Position(x: 5, y: 20),
            Position(x: 11, y: 20),
            Position(x: 18, y: 20),
            Position(x: 24, y: 20),
            Position(x: 5, y: 24),
            Position(x: 11, y: 24),
            Position(x: 18, y: 24),
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
    
    func createGrid() -> [Grid] {
        var grids = [Grid]()
        // Corners
        do {
            let width = 5
            let height = 4
            grids.append(Grid(top: 0, left: 0, width: width, height: height, gates: [Position(x: 3, y: 4)]))
            grids.append(Grid(top: 0, left: 25, width: width, height: height, gates: [Position(x: 26, y: 4)]))
            grids.append(Grid(top: 26, left: 0, width: width, height: height, gates: [Position(x: 3, y: 25)]))
            grids.append(Grid(top: 26, left: 25, width: width, height: height, gates: [Position(x: 26, y: 25)]))
        }
        
        // Sides
        for y in [5, 12, 19] {
            let width = 3
            let height = 6
            grids.append(Grid(top: y, left: 0, width: width, height: height, gates: [Position(x: 3, y: y + 2)]))
            grids.append(Grid(top: y, left: 27, width: width, height: height, gates: [Position(x: 26, y: y + 2)]))
        }
        
        // Top and bottom
        for x in [6, 12, 19] {
            let width = x == 12 ? 6 : 5
            let height = 3
            grids.append(Grid(top: 0, left: x, width: width, height: height, gates: [Position(x: x + 2, y: 3)]))
            grids.append(Grid(top: 27, left: x, width: width, height: height, gates: [Position(x: x + 2, y: 26)]))
        }

        // Center
        for x in [6, 12, 19] {
            for y in [6, 21] {
                let height = y == 6 ? 4 : 3
                let width = x == 12 ? 6 : 5
                let gateX: Int = {
                    if x == 6 { return 5 }
                    if x == 12 { return 14 }
                    else { return 24 }
                }()
                let gateY: Int = {
                    if x == 12 {
                        return y == 6 ? 5 : 24
                    }
                    return y + height / 2
                }()
                grids.append(
                    Grid(
                        top: y,
                        left: x,
                        width: width,
                        height: height,
                        gates: [Position(x: gateX, y: gateY)]
                    )
                )
            }
        }
        return grids
    }
    
    func createCatGrids() -> [Grid] {
        var grids = [Grid]()
        for y in [11, 13, 17, 19] {
            grids.append(
                Grid(
                    top: y,
                    left: 6,
                    width: 18,
                    height: 1,
                    gates: [
                        Position(x: 5, y: y),
                        Position(x: 24, y: y),
                    ]
                )
            )
        }
        return grids
    }
    
    func createGridJobs() -> [Schedule.Job] {
        var jobs = [Schedule.Job]()
        
        var leftSideJob = Schedule.Job(units: [])
        var rightSideJob = Schedule.Job(units: [])
        let ys = [4, 11, 18, 25]
        for i in 0 ..< ys.count {
            leftSideJob +=
                JobUtil.createLineBlockJob(from: Position(x: 0, y: ys[i]), to: Position(x: 2, y: ys[i]), skipBlocks: skipBlocks)
            rightSideJob +=
                JobUtil.createLineBlockJob(from: Position(x: 29, y: ys[i]), to: Position(x: 27, y: ys[i]), skipBlocks: skipBlocks)
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
        let xs = [5, 11, 18, 24]
        for i in 0 ..< xs.count {
            topJob +=
                JobUtil.createLineBlockJob(from: Position(x: xs[i], y: 0), to: Position(x: xs[i], y: 2), skipBlocks: skipBlocks)
            bottomJob +=
                JobUtil.createLineBlockJob(from: Position(x: xs[i], y: 29), to: Position(x: xs[i], y: 27), skipBlocks: skipBlocks)
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
        
        // Center horizontal
        for y in [11, 15, 19] {
            jobs.append(
                JobUtil.createBlockJobWithMove(
                    from: Position(x: 6, y: y),
                    to: Position(x: 23, y: y),
                    checkDirections: [.up, .down],
                    skipBlocks: skipBlocks
                )
            )
        }
        
        // Center vertical
        for y in [6, 20] {
            for x in [11, 18] {
                let height = y == 6 ? 4 : 3
                jobs.append(
                    JobUtil.createLineBlockJob(
                        from: Position(x: x, y: y),
                        to: Position(x: x, y: y + height),
                        skipBlocks: skipBlocks
                    )
                )
            }
        }
        
        return jobs
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
    let dogCaptureZone: [Position] = {
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
        positions.append(Position(x: 9, y: 14))
        positions.append(Position(x: 15, y: 9))
        positions.append(Position(x: 14, y: 20))
        positions.append(Position(x: 20, y: 15))

        return positions
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
            Position(x: 5, y: 5),
            Position(x: 5, y: 24),
            Position(x: 24, y: 5),
            Position(x: 24, y: 24),
            Position(x: 5, y: 3),
            Position(x: 11, y: 3),
            Position(x: 18, y: 3),
            Position(x: 24, y: 3),
            Position(x: 9, y: 5),
            Position(x: 13, y: 5),
            Position(x: 15, y: 5),
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
            Position(x: 14, y: 24),
            Position(x: 16, y: 24),
            Position(x: 20, y: 24),
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

    func createGridJobs() -> [Schedule.Job] {
        var jobs = [Schedule.Job]()
        
        var leftSideJob = Schedule.Job(units: [])
        var rightSideJob = Schedule.Job(units: [])
        let ys = [4, 11, 18, 25]
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
        let xs = [5, 11, 18, 24]
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
        
        // Center
        do {
            // Horizontal
            jobs.append(
                JobUtil.createLineBlockJob(from: Position(x: 6, y: 20), to: Position(x: 13, y: 20), skipBlocks: skipBlocks, addMove: false)
            )
            
            jobs.append(
                JobUtil.createLineBlockJob(from: Position(x: 16, y: 9), to: Position(x: 23, y: 9), skipBlocks: skipBlocks, addMove: false)
            )

            // Vertical
            jobs.append(
                JobUtil.createLineBlockJob(from: Position(x: 9, y: 6), to: Position(x: 9, y: 13), skipBlocks: skipBlocks, addMove: false)
            )
            jobs.append(
                JobUtil.createLineBlockJob(from: Position(x: 20, y: 16), to: Position(x: 20, y: 23), skipBlocks: skipBlocks, addMove: false)
            )
            
            // These should be the last job!
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
        }
        
        return jobs
    }
    
    func createGrid() -> [Grid] {
        var grids = [Grid]()
        // Corners
        do {
            let width = 5
            let height = 4
            grids.append(Grid(top: 0, left: 0, width: width, height: height, gates: [Position(x: 3, y: 4)]))
            grids.append(Grid(top: 0, left: 25, width: width, height: height, gates: [Position(x: 26, y: 4)]))
            grids.append(Grid(top: 26, left: 0, width: width, height: height, gates: [Position(x: 3, y: 25)]))
            grids.append(Grid(top: 26, left: 25, width: width, height: height, gates: [Position(x: 26, y: 25)]))
        }
        
        // Sides
        for y in [5, 12, 19] {
            let width = 3
            let height = 6
            grids.append(Grid(top: y, left: 0, width: width, height: height, gates: [Position(x: 3, y: y + 2)]))
            grids.append(Grid(top: y, left: 27, width: width, height: height, gates: [Position(x: 26, y: y + 2)]))
        }
        
        // Top and bottom
        for x in [6, 12, 19] {
            let width = x == 12 ? 6 : 5
            let height = 3
            grids.append(Grid(top: 0, left: x, width: width, height: height, gates: [Position(x: x + 2, y: 3)]))
            grids.append(Grid(top: 27, left: x, width: width, height: height, gates: [Position(x: x + 2, y: 26)]))
        }
        
        // Center vertical
        do {
            let width = 3
            let height = 8
            grids.append(Grid(top: 6, left: 6, width: width, height: height, gates: [Position(x: 7, y: 5)]))
            grids.append(Grid(top: 6, left: 10, width: width, height: height, gates: [Position(x: 11, y: 5)]))
            
            grids.append(Grid(top: 16, left: 17, width: width, height: height, gates: [Position(x: 18, y: 24)]))
            grids.append(Grid(top: 16, left: 21, width: width, height: height, gates: [Position(x: 22, y: 24)]))
        }
        
        // Center horizontal
        do {
            let width = 8
            let height = 3
            grids.append(Grid(top: 17, left: 6, width: width, height: height, gates: [Position(x: 5, y: 18)]))
            grids.append(Grid(top: 21, left: 6, width: width, height: height, gates: [Position(x: 5, y: 22)]))
            
            grids.append(Grid(top: 6, left: 16, width: width, height: height, gates: [Position(x: 24, y: 7)]))
            grids.append(Grid(top: 10, left: 16, width: width, height: height, gates: [Position(x: 24, y: 11)]))
        }

        return grids
    }
    
    func createCatGrids() -> [Grid] {
        return []
    }
}
