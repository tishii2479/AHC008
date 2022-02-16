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
            for (i, human) in humans.enumerated() {
                let x = i * fieldSize / humans.count
                IO.log(x)
                let pre = Schedule.Job(units: [
                    .init(kind: .move, pos: Position(x: x + 1, y: 0))
                ])
                human.assign(job: pre)
            }
        }
        if turn == 30 {
            for (i, human) in humans.enumerated() {
                let x = i * fieldSize / humans.count
                let job = JobUtil.createLineBlockJob(points: [
                    Position(x: x, y: 0),
                    Position(x: x, y: fieldSize - 1)
                ])
                human.assign(job: job)
            }
        }
    }
}
