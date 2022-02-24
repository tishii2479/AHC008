class ColumnGridManager: GridManager {
    let dogCaptureBlocks: [Position] = [
        Position(x: 2, y: 15),
        Position(x: 13, y: 15),
        Position(x: 15, y: 15),
        Position(x: 27, y: 15),
    ]
    let dogCapturePositions: [Position] = [
        Position(x: 1, y: 15),
        Position(x: 14, y: 15),
        Position(x: 14, y: 15),
        Position(x: 28, y: 15),
    ]
    let corners: [[Position]] = [
        [Position(x: 0, y: 13), Position(x: 0, y: 17), Position(x: 29, y: 17), Position(x: 29, y: 13)]
    ]
    let dogCaptureGrid: Grid = {
        let positions =
            Util.createSquare(top: 15, left: 3, width: 10, height: 1) +
            Util.createSquare(top: 15, left: 16, width: 11, height: 1)
        let gates: [Position] = [
            Position(x: 2, y: 15),
            Position(x: 13, y: 15),
            Position(x: 15, y: 15),
            Position(x: 27, y: 15),
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
        let intersections: [Position] = [
            Position(x: 1, y: 3),
            Position(x: 4, y: 3),
            Position(x: 8, y: 3),
            Position(x: 11, y: 3),
            Position(x: 15, y: 3),
            Position(x: 18, y: 3),
            Position(x: 22, y: 3),
            Position(x: 25, y: 3),
            Position(x: 1, y: 12),
            Position(x: 4, y: 12),
            Position(x: 6, y: 12),
            Position(x: 8, y: 12),
            Position(x: 11, y: 12),
            Position(x: 13, y: 12),
            Position(x: 15, y: 12),
            Position(x: 18, y: 12),
            Position(x: 20, y: 12),
            Position(x: 22, y: 12),
            Position(x: 25, y: 12),
            Position(x: 27, y: 12),
            Position(x: 1, y: 18),
            Position(x: 4, y: 18),
            Position(x: 6, y: 18),
            Position(x: 8, y: 18),
            Position(x: 11, y: 18),
            Position(x: 13, y: 18),
            Position(x: 15, y: 18),
            Position(x: 18, y: 18),
            Position(x: 20, y: 18),
            Position(x: 22, y: 18),
            Position(x: 25, y: 18),
            Position(x: 27, y: 18),
            Position(x: 1, y: 26),
            Position(x: 4, y: 26),
            Position(x: 8, y: 26),
            Position(x: 11, y: 26),
            Position(x: 15, y: 26),
            Position(x: 18, y: 26),
            Position(x: 22, y: 26),
            Position(x: 25, y: 26),
            
            Position(x: 14, y: 14),
            Position(x: 14, y: 16),
        ]
        return arr + intersections
    }()

    func createGridJobs(humanCount: Int) -> [Schedule.Job] {
        var jobs = [Schedule.Job]()
        for x in [1, 8, 15, 22] {
            var job = Schedule.Job(units: [])
            // Top
            job +=
                JobUtil.createLineBlockJob(
                    from: Position(x: x, y: 11),
                    to: Position(x: x, y: 4),
                    skipBlocks: skipBlocks
                )
            job +=
                JobUtil.createLineBlockJob(
                    from: Position(x: x + 1, y: 3),
                    to: Position(x: x + 2, y: 3),
                    skipBlocks: skipBlocks
                )
            job +=
                JobUtil.createLineBlockJob(
                    from: Position(x: x + 2, y: 2),
                    to: Position(x: x + 2, y: 1),
                    skipBlocks: skipBlocks
                )
            job +=
                Schedule.Job(units: [
                    .init(kind: .move, pos: Position(x: x + 3, y: 0)),
                    .init(kind: .block, pos: Position(x: x + 2, y: 0)),
                ])
            job +=
                JobUtil.createLineBlockJob(
                    from: Position(x: x + 5, y: 0),
                    to: Position(x: x + 5, y: 3),
                    skipBlocks: skipBlocks
                )
            job +=
                JobUtil.createBlockJobWithMove(
                    from: Position(x: x + 4, y: 4),
                    to: Position(x: x + 4, y: 11),
                    checkDirections: [.left, .right],
                    skipBlocks: skipBlocks
                )
            job += Schedule.Job(units: [
                .init(kind: .block, pos: Position(x: x + 2, y: 12))
            ])
            
            // Bottom
            job +=
                JobUtil.createLineBlockJob(
                    from: Position(x: x, y: 19),
                    to: Position(x: x, y: 25),
                    skipBlocks: skipBlocks
                )
            job +=
                JobUtil.createLineBlockJob(
                    from: Position(x: x + 1, y: 26),
                    to: Position(x: x + 2, y: 26),
                    skipBlocks: skipBlocks
                )
            job +=
                JobUtil.createLineBlockJob(
                    from: Position(x: x + 2, y: 27),
                    to: Position(x: x + 2, y: 28),
                    skipBlocks: skipBlocks
                )
            job +=
                Schedule.Job(units: [
                    .init(kind: .move, pos: Position(x: x + 3, y: 29)),
                    .init(kind: .block, pos: Position(x: x + 2, y: 29)),
                ])
            job +=
                JobUtil.createLineBlockJob(
                    from: Position(x: x + 5, y: 29),
                    to: Position(x: x + 5, y: 26),
                    skipBlocks: skipBlocks
                )
            job +=
                JobUtil.createBlockJobWithMove(
                    from: Position(x: x + 4, y: 25),
                    to: Position(x: x + 4, y: 19),
                    checkDirections: [.left, .right],
                    skipBlocks: skipBlocks
                )
            job += Schedule.Job(units: [
                .init(kind: .block, pos: Position(x: x + 2, y: 18))
            ])
            jobs.append(job)
        }
        
        // Center
        jobs.append(
            JobUtil.createBlockJobWithMove(
                from: Position(x: 1, y: 15),
                to: Position(x: 28, y: 15),
                checkDirections: [.up, .down],
                skipBlocks: skipBlocks
            )
            + Schedule.Job(units: [
                .init(kind: .block, pos: Position(x: 29, y: 12)),
                .init(kind: .block, pos: Position(x: 29, y: 18)),
            ])
            + Schedule.Job(units: [
                .init(kind: .move, pos: Position(x: 0, y: 13)),
                .init(kind: .move, pos: Position(x: 29, y: 13)),
                .init(kind: .move, pos: Position(x: 0, y: 13)),
            ])
        )
        
        // Move around
        for _ in 5 ..< humanCount {
            jobs.append(
                Schedule.Job(units: [
                    .init(kind: .move, pos: Position(x: 0, y: 13)),
                    .init(kind: .move, pos: Position(x: 29, y: 13)),
                    .init(kind: .move, pos: Position(x: 0, y: 13)),
                ])
            )
        }
        return jobs
    }
    
    func createGrid() -> [Grid] {
        var grids = [Grid]()
        
        for x in [1, 8, 15, 22] {
            grids.append(
                Grid(
                    zone:
                        Util.createSquare(
                            top: 4,
                            left: x + 1,
                            width: 2,
                            height: 8
                        ),
                    gates: [Position(x: x + 1, y: 12)]
                )
            )
            grids.append(
                Grid(
                    zone:
                        Util.createSquare(
                            top: 0,
                            left: x - 1,
                            width: 3,
                            height: 3
                        ) + Util.createSquare(
                            top: 3,
                            left: x - 1,
                            width: 2,
                            height: 1
                        ) + Util.createSquare(
                            top: 4,
                            left: x - 1,
                            width: 1,
                            height: 8
                        ),
                    gates: [Position(x: x - 1, y: 12)]
                )
            )
            grids.append(
                Grid(
                    zone:
                        Util.createSquare(
                            top: 0,
                            left: x + 3,
                            width: 2,
                            height: 4
                        ) +
                        Util.createSquare(
                            top: 4,
                            left: x + 4,
                            width: 1,
                            height: 8
                        ),
                    gates: [Position(x: x + 4, y: 12)]
                )
            )
            grids.append(
                Grid(
                    zone:
                        Util.createSquare(
                            top: 19,
                            left: x + 1,
                            width: 2,
                            height: 7
                        ),
                    gates: [Position(x: x + 1, y: 18)]
                )
            )
            grids.append(
                Grid(
                    zone:
                        Util.createSquare(
                            top: 27,
                            left: x - 1,
                            width: 3,
                            height: 3
                        ) + Util.createSquare(
                            top: 26,
                            left: x - 1,
                            width: 2,
                            height: 1
                        ) + Util.createSquare(
                            top: 19,
                            left: x - 1,
                            width: 1,
                            height: 8
                        ),
                    gates: [Position(x: x - 1, y: 18)]
                )
            )
            grids.append(
                Grid(
                    zone:
                        Util.createSquare(
                            top: 26,
                            left: x + 3,
                            width: 2,
                            height: 4
                        ) +
                        Util.createSquare(
                            top: 19,
                            left: x + 4,
                            width: 1,
                            height: 8
                        ),
                    gates: [Position(x: x + 4, y: 18)]
                )
            )
        }
        grids.append(
            Grid(
                zone:
                    Util.createSquare(
                        top: 0,
                        left: 28,
                        width: 2,
                        height: 12
                    ),
                gates: [Position(x: 28, y: 12)]
            )
        )
        grids.append(
            Grid(
                zone:
                    Util.createSquare(
                        top: 19,
                        left: 28,
                        width: 2,
                        height: 11
                    ),
                gates: [Position(x: 28, y: 18)]
            )
        )
        
        return grids
    }
}
