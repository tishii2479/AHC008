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
            var units = [Schedule.Job.Unit]()
            let x = Int.random(in: 0 ..< 30)
            for y in 0 ..< fieldSize {
                units.append(.init(kind: .block, pos: Position(x: x, y: y)))
            }
            let job = Schedule.Job(units: units)
            human.assign(job: job)
        }
    }
}
