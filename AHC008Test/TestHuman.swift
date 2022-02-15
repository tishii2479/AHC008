//
//  TestHuman.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/15.
//

import XCTest

class TestHuman: XCTestCase {

    func testAssignJob() throws {
        let startPosition = Position(x: 3, y: 3)
        let human = Human(pos: startPosition, id: 0)
        let job = Schedule.Job(units: [
            .init(kind: .move, pos: Position(x: 5, y: 7)),
        ])
        human.assign(job: job)
        var expectedCost: Int = job.cost + startPosition.dist(to: job.nextUnit?.pos)
        XCTAssertEqual(human.jobCost, expectedCost)
        let job2 = Schedule.Job(units: [
            .init(kind: .block, pos: Position(x: 3, y: 3)),
        ])
        human.assign(job: job2)
        expectedCost += job2.cost + (job.units.tail?.pos.dist(to: job2.nextUnit?.pos) ?? 0)
        XCTAssertEqual(expectedCost, 6 + 1 + 6)
        XCTAssertEqual(human.jobCost, expectedCost)
    }
    
    func testPerformJob() throws {
        let field = Field()
        let startPosition = Position(x: 3, y: 3)
        let human = Human(pos: startPosition, id: 0)
        
        field.addPlayer(player: human)
        let job = Schedule.Job(units: [
            .init(kind: .block, pos: Position(x: 2, y: 2)),
            .init(kind: .move, pos: Position(x: 5, y: 2)),
            .init(kind: .block, pos: Position(x: 4, y: 4)),
            .init(kind: .block, pos: Position(x: 5, y: 5)),
        ])
        human.assign(job: job)
        
    }
    
}

