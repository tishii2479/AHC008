//
//  TestScheduleJob.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/15.
//

import XCTest

class TestScheduleJob: XCTestCase {

    func testJobManagement() throws {
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
        
        var schedule = Schedule(jobs: [job])
        var expectedCost: Int = 3
        XCTAssertEqual(schedule.cost, expectedCost)
        schedule.assign(job: job2)
        // dist(job.tail -> job2.front) + job2.cost
        expectedCost += 12 + 6
        XCTAssertEqual(schedule.cost, expectedCost)
        
        schedule.consume()
        expectedCost -= 1
        XCTAssertEqual(schedule.cost, expectedCost)
        
        let blockJob = Schedule.Job(units: [
            .init(kind: .block, pos: Position(x: 0, y: 0)),
            .init(kind: .block, pos: Position(x: 0, y: 1)),
            .init(kind: .block, pos: Position(x: 0, y: 2)),
        ])
        
        schedule.assign(job: blockJob)
        // dist(job2.tail -> blockJob.front) + blockJob.cost
        expectedCost += 26 + 5
        XCTAssertEqual(schedule.cost, expectedCost)
    }
    
    func testJobConsume() throws {
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
        
        var schedule = Schedule(jobs: [job, job2])
        // job.cost + dist(job.tail -> job2.front) + job2.cost
        var expectedCost: Int = 3 + 12 + 6

        XCTAssertEqual(
            schedule.nextUnit, Schedule.Job.Unit(kind: .move, pos: Position(x: 2, y: 3))
        )
        XCTAssertEqual(
            schedule.consume(), Schedule.Job.Unit(kind: .move, pos: Position(x: 2, y: 3))
        )
        expectedCost -= 1
        XCTAssertEqual(schedule.cost, expectedCost)
        XCTAssertEqual(
            schedule.nextUnit, Schedule.Job.Unit(kind: .move, pos: Position(x: 3, y: 3))
        )
        schedule.consume()
        schedule.consume()
        expectedCost -= 2
        XCTAssertEqual(schedule.cost, expectedCost)
        schedule.consume()
        // dist(job.tail -> job2.front)
        expectedCost -= 12
        XCTAssertEqual(schedule.cost, expectedCost)
        
        // Start job2
        XCTAssertEqual(
            schedule.nextUnit, Schedule.Job.Unit(kind: .move, pos: Position(x: 10, y: 10))
        )
        schedule.consume()
        expectedCost -= 2
        XCTAssertEqual(schedule.cost, expectedCost)
        schedule.consume()
        schedule.consume()
        schedule.consume()
        expectedCost -= 4
        XCTAssertEqual(schedule.cost, expectedCost)
        
        // Schedule is empty
        XCTAssertNil(schedule.consume())
    }
    
    func testJobBlock() throws {
        let blockJob = Schedule.Job(units: [
            .init(kind: .block, pos: Position(x: 0, y: 0)),
            .init(kind: .block, pos: Position(x: 0, y: 1)),
            .init(kind: .block, pos: Position(x: 0, y: 2)),
        ])
        
        XCTAssertEqual(blockJob.cost, 2 + 3)
        
        let blockJob2 = Schedule.Job(units: [
            .init(kind: .block, pos: Position(x: 3, y: 3)),
            .init(kind: .block, pos: Position(x: 4, y: 4)),
            .init(kind: .block, pos: Position(x: 5, y: 5)),
        ])
        
        XCTAssertEqual(blockJob2.cost, 4 + 3)

        var schedule = Schedule(jobs: [blockJob, blockJob2])
        // blockJob.cost + dist(blockJob.tail -> blockJob2.front) + blockJob2.cost
        var expectedCost: Int = 5 + 4 + 7
        XCTAssertEqual(schedule.cost, expectedCost)
        
        XCTAssertEqual(
            schedule.nextUnit, .init(kind: .block, pos: Position(x: 0, y: 0))
        )
        XCTAssertEqual(
            schedule.consume(), .init(kind: .block, pos: Position(x: 0, y: 0))
        )
        // dist + block.cost
        expectedCost -= 2
        XCTAssertEqual(schedule.cost, expectedCost)
        schedule.consume()
        expectedCost -= 2
        XCTAssertEqual(schedule.cost, expectedCost)
        schedule.consume()
        // block.cost + dist(jobBlock.tail -> jobBlock2.front)
        expectedCost -= 1 + 4
        // Start blockJob2
        XCTAssertEqual(schedule.cost, expectedCost)
        XCTAssertEqual(
            schedule.nextUnit, .init(kind: .block, pos: Position(x: 3, y: 3))
        )
        XCTAssertEqual(
            schedule.consume(), .init(kind: .block, pos: Position(x: 3, y: 3))
        )
        schedule.consume()
        schedule.consume()
        // dist + block.cost
        expectedCost -= 4 + 3
        XCTAssertEqual(schedule.cost, expectedCost)

        // Schedule is empty
        XCTAssertNil(schedule.consume())
    }
    
}
