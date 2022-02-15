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
        let human = Human(pos: startPosition, id: 0, logic: Logic())
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
        let human = Human(pos: startPosition, id: 0, logic: Logic())
        
        field.addPlayer(player: human)
        let job = Schedule.Job(units: [
            .init(kind: .block, pos: Position(x: 2, y: 2)),
            .init(kind: .move, pos: Position(x: 5, y: 2)),
            .init(kind: .block, pos: Position(x: 4, y: 4)),
            .init(kind: .block, pos: Position(x: 5, y: 5)),
        ])
        human.assign(job: job)
        
        for _ in 0 ..< 20 {
            let command = human.step(field: field)
            human.applyCommand(command: command)
            if command.isBlock { field.addBlock(position: human.pos + command.delta) }
            field.updateField(players: [human])
        }

        XCTAssertTrue(field.checkBlock(x: 2, y: 2))
        XCTAssertTrue(field.checkBlock(x: 4, y: 4))
        XCTAssertTrue(field.checkBlock(x: 5, y: 5))
    }
    
    func testPerformBlockLine() throws {
        let field = Field()
        let startPosition = Position(x: 3, y: 3)
        let human = Human(pos: startPosition, id: 0, logic: Logic())
        
        field.addPlayer(player: human)
        var units = [Schedule.Job.Unit]()
        for y in 0 ..< fieldSize {
            units.append(.init(kind: .block, pos: Position(x: human.x, y: y)))
        }
        let job = Schedule.Job(units: units)
        human.assign(job: job)
        
        for _ in 0 ..< 80 {
            let command = human.step(field: field)
            human.applyCommand(command: command)
            if command.isBlock { field.addBlock(position: human.pos + command.delta) }
            field.updateField(players: [human])
            IO.log(human.schedule.nextUnit, command)
        }
        
        field.dumpBlock()
        for y in 0 ..< fieldSize {
            XCTAssertTrue(field.checkBlock(x: 3, y: y))
        }
    }
    
}

