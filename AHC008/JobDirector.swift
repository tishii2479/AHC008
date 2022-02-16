protocol JobDirector {
    func assignJobs(
        field: inout Field,
        humans: inout [Human],
        pets: inout [Pet],
        turn: Int
    )
}

struct Director: JobDirector {
    func assignJobs(
        field: inout Field,
        humans: inout [Human],
        pets: inout [Pet],
        turn: Int
    ) {
        if turn == 0 {
            let ys = [3, 7, 11, 15, 19, 23, 27]
            let xs = [8, 10, 19, 21]
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
            
            for job in jobs {
                if let assignee = findAssignee(job: job, humans: &humans) {
                    assignee.assign(job: job)
                }
            }
        }
    }
    
    private func findAssignee(job: Schedule.Job, humans: inout [Human]) -> Human? {
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
