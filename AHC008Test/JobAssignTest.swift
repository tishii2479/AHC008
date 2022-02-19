//
//  JobAssignTest.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/16.
//

import XCTest

class JobAssignTest: XCTestCase {
    func testMajorJobTest() throws {
        let field = Field()
        let human = Human(pos: Position(x: 5, y: 5), id: 0)
        
        let job = Schedule.Job(units: [
            .init(kind: .block, pos: Position(x: 10, y: 10)),
            .init(kind: .block, pos: Position(x: 10, y: 20)),
        ])
        human.assign(job: job)
        let majorJob = Schedule.Job(units: [
            .init(kind: .block, pos: Position(x: 10, y: 0))
        ])
        human.assign(job: majorJob, isMajor: true)
        
        for _ in 0 ..< 60 {
            if let command = human.commands(field: field).first {
                human.applyCommand(command: command)
                field.applyCommand(player: human, command: command)
            }
            field.updateField(players: [human])
        }
        
        XCTAssertTrue(field.checkBlock(x: 10, y: 0))
        XCTAssertTrue(field.checkBlock(x: 10, y: 10))
        XCTAssertTrue(field.checkBlock(x: 10, y: 20))
    }
}
