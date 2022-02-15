//
//  TestScheduleJob.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/15.
//

import XCTest

class TestScheduleJob: XCTestCase {

    func testSimpleJob() throws {
        let job = Schedule.Job(blocks: [
            Position(x: 2, y: 3),
            Position(x: 3, y: 3),
            Position(x: 4, y: 3),
            Position(x: 5, y: 3),
        ])
        XCTAssertEqual(job.cost, 3 + 3)
        
        let job2 = Schedule.Job(blocks: [
            Position(x: 10, y: 10),
            Position(x: 11, y: 11),
            Position(x: 12, y: 12),
            Position(x: 13, y: 13),
        ])
        XCTAssertEqual(job2.cost, 6 + 3)
        
        let schedule = Schedule(jobs: [job, job2])
        
        XCTAssertEqual(schedule.cost, 6 + 12 + 9)
    }
    
}
