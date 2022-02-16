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
            let xs = [0, 20, 10, 0, 20], ys = [1, 1, 10, 20, 20]
            for (i, human) in humans.enumerated() {
                let x = xs[i], y = ys[i]
                let job = JobUtil.createLineBlockJob(points: [
                    Position(x: x, y: y),
                    Position(x: x, y: y + 8),
                    Position(x: x + 8, y: y + 8),
                    Position(x: x + 8, y: y),
                    Position(x: x + 2, y: y),
                ])
                let job2 = Schedule.Job(units: [
                    .init(kind: .move, pos: Position(x: x + 1, y: y + 1)),
                    .init(kind: .block, pos: Position(x: x + 1, y: y))
                ])
                human.assign(job: job)
                human.assign(job: job2)
            }
        }
    }
}
