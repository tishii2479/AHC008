//
//  JobAssignTest.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/16.
//

import XCTest

class JobAssignTest: XCTestCase {
    func testLineBlock() throws {
        let field = Field()
        let startPosition = Position(x: 4, y: 0)
        let human = Human(pos: startPosition, id: 0, logic: Logic())
        let job = JobUtil.createLineBlockJob(points: [
            Position(x: 3, y: 0),
            Position(x: 3, y: fieldSize - 1),
        ])
        human.assign(job: job)
        for _ in 0 ..< fieldSize * 2 - 1 {
            if let command = human.commands(field: field).first {
                human.applyCommand(command: command)
                field.applyCommand(player: human, command: command)
            }
            field.updateField(players: [human])
        }
        
        for y in 0 ..< fieldSize {
            XCTAssertTrue(field.checkBlock(x: 3, y: y))
        }
    }

}
