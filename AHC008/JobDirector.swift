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
            let x = Int.random(in: 0 ..< fieldSize)
            let job = JobUtil.createLineBlockJob(points: [
                Position(x: x, y: 0),
                Position(x: x, y: fieldSize - 1),
            ])
            human.assign(job: job)
        }
    }
}
