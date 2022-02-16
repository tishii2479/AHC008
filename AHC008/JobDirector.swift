protocol JobDirector {
    mutating func directJobs(
        field: inout Field,
        humans: inout [Human],
        pets: inout [Pet],
        turn: Int
    )
}

extension JobDirector {
    func assignJobs(jobs: [Schedule.Job], humans: inout [Human]) {
        for job in jobs {
            findAssignee(job: job, humans: &humans)?.assign(job: job)
        }
    }
    
    func findAssignee(job: Schedule.Job, humans: inout [Human]) -> Human? {
        guard humans.count > 0 else { return nil }
        var assignee = humans[0]
        for human in humans {
            if human.assignedCost(job: job) < assignee.assignedCost(job: job) {
                assignee = human
            }
        }
        return assignee
    }
}

struct GridJobDirector: JobDirector {
    private struct Grid {
        var topLeft: Position
        var bottomRight: Position
        var gates: [Position]
        var assigned: Bool = false
    }
    private var grids = [Grid]()
    private let ys = [3, 7, 11, 15, 19, 23, 27]
    private let xs = [8, 10, 19, 21]
    
    init() {
        for y in ys {
            grids.append(
                Grid(
                    topLeft: Position(x: 0, y: y - 3),
                    bottomRight: Position(x: xs[0] - 1, y: y - 1),
                    gates: [Position(x: xs[0], y: y - 2)]
                )
            )
            grids.append(
                Grid(
                    topLeft: Position(x: xs[1] + 1, y: y - 3),
                    bottomRight: Position(x: xs[2] - 1, y: y - 1),
                    gates: [
                        Position(x: xs[1], y: y - 2),
                        Position(x: xs[2], y: y - 2),
                    ]
                )
            )
            grids.append(
                Grid(
                    topLeft: Position(x: xs[3] + 1, y: y - 3),
                    bottomRight: Position(x: fieldSize - 1, y: y - 1),
                    gates: [Position(x: xs[3], y: y - 2)]
                )
            )
        }
        grids.append(
            Grid(
                topLeft: Position(x: 0, y: 28),
                bottomRight: Position(x: xs[0] - 1, y: 29),
                gates: [Position(x: xs[0], y: 29)]
            )
        )
        grids.append(
            Grid(
                topLeft: Position(x: xs[1] + 1, y: 28),
                bottomRight: Position(x: xs[2] - 1, y: 29),
                gates: [
                    Position(x: xs[1], y: 29),
                    Position(x: xs[2], y: 29),
                ]
            )
        )
        grids.append(
            Grid(
                topLeft: Position(x: xs[3] + 1, y: 28),
                bottomRight: Position(x: fieldSize - 1, y: 29),
                gates: [Position(x: xs[3], y: 29)]
            )
        )
    }
    
    mutating func directJobs(
        field: inout Field,
        humans: inout [Human],
        pets: inout [Pet],
        turn: Int
    ) {
        if turn == 0 {
            createGrid(field: &field, humans: &humans, pets: &pets)
            for human in humans {
                human.assign(job: Schedule.Job(units: [
                    .init(kind: .move, pos: Position(x: Bool.random() ? xs[0] + 1 : xs[2] + 1, y: 15))
                ]))
            }
        }
        else if turn >= 200 {
            // Find a grid where pet is in, and the gate is not closed.
            for i in 0 ..< grids.count {
                if grids[i].assigned { continue }
                var petCount: Int = 0
                for x in grids[i].topLeft.x ... grids[i].bottomRight.x {
                    for y in grids[i].topLeft.y ... grids[i].bottomRight.y {
                        petCount += field.getPetCount(x: x, y: y)
                    }
                }
                if petCount > 0 {
                    grids[i].assigned = true
                    var jobs = [Schedule.Job]()
                    for gate in grids[i].gates {
                        jobs.append(
                            Schedule.Job(units: [
                                .init(kind: .block, pos: gate)
                            ])
                        )
                    }
                    assignJobs(jobs: jobs, humans: &humans)
                }
            }
        }
    }
    
    // TODO: Raise efficency
    private func createGrid(
        field: inout Field,
        humans: inout [Human],
        pets: inout [Pet]
    ) {
        var jobs = [Schedule.Job]()
        for y in ys {
            jobs.append(contentsOf: [
                JobUtil.createLineBlockJob(points: [
                    Position(x: 0, y: y),
                    Position(x: xs[0] - 1, y: y),
                ]),
                JobUtil.createLineBlockJob(points: [
                    Position(x: xs[1] + 1, y: y),
                    Position(x: xs[2] - 1, y: y),
                ]),
                JobUtil.createLineBlockJob(points: [
                    Position(x: xs[3] + 1, y: y),
                    Position(x: fieldSize - 1, y: y),
                ])
            ])
        }
        
        for x in xs {
            jobs.append(
                JobUtil.createLineBlockJob(points: [
                    Position(x: x, y: 0)
                ])
            )
            for y in ys {
                jobs.append(
                    JobUtil.createLineBlockJob(points: [
                        Position(x: x, y: y - 1),
                        Position(x: x, y: y + 1),
                    ])
                )
            }
        }
        
        assignJobs(jobs: jobs, humans: &humans)
    }
}
