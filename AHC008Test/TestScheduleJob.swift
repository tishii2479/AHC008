//
//  TestScheduleJob.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/15.
//

import XCTest

class TestScheduleJob: XCTestCase {

    func testSimpleJob() throws {
        let job = Schedule.Job(units: [
            .init(kind: .move, pos: Position(x: 2, y: 3)),
            .init(kind: .move, pos: Position(x: 3, y: 3)),
            .init(kind: .move, pos: Position(x: 4, y: 3)),
            .init(kind: .move, pos: Position(x: 5, y: 3)),
        ])
        XCTAssertEqual(job.cost, 3)
        
        let job2 = Schedule.Job(units: [
            .init(kind: .move, pos: Position(x: 10, y: 10)),
            .init(kind: .move, pos: Position(x: 11, y: 11)),
            .init(kind: .move, pos: Position(x: 12, y: 12)),
            .init(kind: .move, pos: Position(x: 13, y: 13)),
        ])
        XCTAssertEqual(job2.cost, 6)
        
        let schedule = Schedule(jobs: [job, job2])
        
        XCTAssertEqual(schedule.cost, 3 + 12 + 6)
    }
    
    func testJobConsume() throws {
        let job = Schedule.Job(units: [
            .init(kind: .move, pos: Position(x: 2, y: 3)),
            .init(kind: .move, pos: Position(x: 3, y: 3)),
            .init(kind: .move, pos: Position(x: 4, y: 3)),
            .init(kind: .move, pos: Position(x: 5, y: 3)),
        ])
        
        let job2 = Schedule.Job(units: [
            .init(kind: .move, pos: Position(x: 10, y: 10)),
            .init(kind: .move, pos: Position(x: 11, y: 11)),
            .init(kind: .move, pos: Position(x: 12, y: 12)),
            .init(kind: .move, pos: Position(x: 13, y: 13)),
        ])
        
        var schedule = Schedule(jobs: [job, job2])

        XCTAssertEqual(
            schedule.nextUnit, Schedule.Job.Unit(kind: .move, pos: Position(x: 2, y: 3))
        )
        XCTAssertEqual(
            schedule.consume(), Schedule.Job.Unit(kind: .move, pos: Position(x: 2, y: 3))
        )
        XCTAssertEqual(schedule.cost, 21 - 1)
        XCTAssertEqual(
            schedule.nextUnit, Schedule.Job.Unit(kind: .move, pos: Position(x: 3, y: 3))
        )
        schedule.consume()
        schedule.consume()
        XCTAssertEqual(schedule.cost, 20 - 2)
        schedule.consume()
        XCTAssertEqual(schedule.cost, 6)
        schedule.consume()
        schedule.consume()
        schedule.consume()
        schedule.consume()
        XCTAssertEqual(schedule.cost, 0)
        XCTAssertNil(schedule.consume())
    }
    
}
