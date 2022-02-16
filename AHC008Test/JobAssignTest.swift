//
//  JobAssignTest.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/16.
//

import XCTest

class JobAssignTest: XCTestCase {
    func testCreateLineBlockJob() throws {
        let job = JobUtil.createLineBlockJob(points: [
            Position(x: 3, y: 0),
            Position(x: 3, y: 29),
        ])
        XCTAssertEqual(job.units.count, 30)
        
        let job2 = JobUtil.createLineBlockJob(points: [
            Position(x: 3, y: 0),
            Position(x: 3, y: 29),
            Position(x: 29, y: 29),
        ])
        XCTAssertEqual(job2.units.count, 30 + 26)
    }
    
    func testRunLineBlockJob() throws {
        let field = Field()
        let startPosition = Position(x: 15, y: 15)
        let human = Human(pos: startPosition, id: 0, brain: HumanBrain())
        let job = JobUtil.createLineBlockJob(points: [
            Position(x: 0, y: 0),
            Position(x: 0, y: 29),
            Position(x: 29, y: 29),
            Position(x: 29, y: 0),
            Position(x: 1, y: 0),
        ])
        human.assign(job: job)
        for _ in 0 ..< 300 {
            if let command = human.commands(field: field).first {
                human.applyCommand(command: command)
                field.applyCommand(player: human, command: command)
            }
            field.updateField(players: [human])
        }
        
        field.dump()
        
        for y in 0 ... 29 {
            XCTAssertTrue(field.checkBlock(x: 0, y: y))
        }
        for x in 0 ... 29 {
            XCTAssertTrue(field.checkBlock(x: x, y: 29))
        }
        for y in 0 ... 29 {
            XCTAssertTrue(field.checkBlock(x: 29, y: y))
        }
        for x in 1 ... 29 {
            XCTAssertTrue(field.checkBlock(x: x, y: 0))
        }
    }

}
