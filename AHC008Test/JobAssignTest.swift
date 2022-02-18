//
//  JobAssignTest.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/16.
//

import XCTest

class JobAssignTest: XCTestCase {
    func testLikeBlockJobWithSkip() throws {
        let field = Field()
        let startPosition = Position(x: 0, y: 0)
        let human = Human(pos: startPosition, id: 0, brain: HumanBrain())
        let job = JobUtil.createLineBlockJob(
            from: Position(x: 0, y: 0),
            to: Position(x: 0, y: 10),
            skipBlocks: [
                Position(x: 0, y: 4),
                Position(x: 0, y: 8),
            ]
        )
        human.assign(job: job)
        for _ in 0 ..< 30 {
            if let command = human.commands(field: field).first {
                human.applyCommand(command: command)
                field.applyCommand(player: human, command: command)
            }
            field.updateField(players: [human])
        }
        for y in 0 ... 10 {
            if y == 4 || y == 8 {
                XCTAssertFalse(field.checkBlock(x: 0, y: y))
            }
            else {
                XCTAssertTrue(field.checkBlock(x: 0, y: y))
            }
        }
    }

}
