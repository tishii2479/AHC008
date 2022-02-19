protocol GridManager {
    func createGrid() -> [Grid]
    func createGridJobs() -> [Schedule.Job]
}

extension GridManager {
    // For Debug
    func dumpGrids(grids: [Grid]) {
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

class SquareGridManager: GridManager {
    private lazy var skipBlocks: [Position] = {
        var arr = [Position]()
        for grid in createGrid() { arr.append(grid.gate) }
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
            grids.append(Grid(top: 0, left: 0, width: width, height: height, gate: Position(x: 3, y: 4)))
            grids.append(Grid(top: 0, left: 25, width: width, height: height, gate: Position(x: 26, y: 4)))
            grids.append(Grid(top: 26, left: 0, width: width, height: height, gate: Position(x: 3, y: 25)))
            grids.append(Grid(top: 26, left: 25, width: width, height: height, gate: Position(x: 26, y: 25)))
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
        
//        dumpGrids(grids: grids)
        return grids
    }
}
