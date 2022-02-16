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
        for human in humans {
            let x = Int.random(in: 2 ..< 22), y = Int.random(in: 2 ..< 22)
            let job = JobUtil.createLineBlockJob(points: [
                Position(x: x - 1, y: y),
                Position(x: x - 1, y: y + 5),
                Position(x: x + 4, y: y + 5),
                Position(x: x + 4, y: y),
                Position(x: x + 1, y: y),
            ])
            let job2 = Schedule.Job(units: [
                .init(kind: .move, pos: Position(x: x, y: y + 1)),
                .init(kind: .block, pos: Position(x: x, y: y)),
            ])
            human.assign(job: job)
            human.assign(job: job2)
        }
    }
}
