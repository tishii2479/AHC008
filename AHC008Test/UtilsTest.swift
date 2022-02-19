//
//  UtilsTest.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/16.
//

import XCTest

class UtilsTest: XCTestCase {
    func testCreateLineBlockJob() throws {
        let field = Field()
        let human = Human(pos: Position(x: 4, y: 0), id: 0, brain: HumanBrain())
        let job = JobUtil.createLineBlockJob(
            from: Position(x: 3, y: 0),
            to: Position(x: 3, y: 29)
        )
        XCTAssertEqual(job.units.count, 59)
        XCTAssertEqual(job.cost, 30 + 29)
        
        human.assign(job: job)
        for _ in 0 ..< 80 {
            if let command = human.commands(field: field).first {
                human.applyCommand(command: command)
                field.applyCommand(player: human, command: command)
            }
            field.updateField(players: [human])
        }
        
        for y in 0 ..< fieldSize {
            for x in 0 ..< fieldSize {
                if (x == 3) && (0 <= y && y <= 29) {
                    XCTAssertTrue(field.checkBlock(x: x, y: y))
                }
                else {
                    XCTAssertFalse(field.checkBlock(x: x, y: y))
                }
            }
        }
    }
    
    func testCreateBlockJobWithMove() throws {
        let field = Field()
        let human = Human(pos: Position(x: 4, y: 15), id: 0, brain: HumanBrain())
        let job = JobUtil.createBlockJobWithMove(
            from: Position(x: 5, y: 15),
            to: Position(x: 15, y: 15),
            checkDirections: [.up, .down]
        )
        XCTAssertEqual(job.units.count, 33)
        XCTAssertEqual(job.cost, 33)

        human.assign(job: job)
        for _ in 0 ..< 100 {
            if let command = human.commands(field: field).first {
                human.applyCommand(command: command)
                field.applyCommand(player: human, command: command)
            }
            field.updateField(players: [human])
        }
        
        for y in 0 ..< fieldSize {
            for x in 0 ..< fieldSize {
                if (5 <= x && x <= 15) && (y == 16 || y == 14) {
                    XCTAssertTrue(field.checkBlock(x: x, y: y))
                }
                else {
                    XCTAssertFalse(field.checkBlock(x: x, y: y))
                }
            }
        }
    }

    func testGetCandidateMove() throws {
        let field = Field()
        // s..
        // ..t
        // ...
        let start = Position(x: 0, y: 0)
        let to = Position(x: 2, y: 1)
        let moves = CommandUtil.getCandidateMove(from: start, to: to, field: field)
        XCTAssertTrue(moves.count == 2 && moves.contains(.moveDown) && moves.contains(.moveRight))
        // s#.
        // .#t
        // ...
        field.addBlocks(positions: [
            Position(x: 1, y: 0),
            Position(x: 1, y: 1),
        ])
        let moves2 = CommandUtil.getCandidateMove(from: start, to: to, field: field)
        XCTAssertEqual(moves2, [.moveDown])
        
        // t#.
        // .#s
        // ...
        let start3 = Position(x: 2, y: 1)
        let to3 = Position(x: 0, y: 0)
        let moves3 = CommandUtil.getCandidateMove(from: start3, to: to3, field: field)
        XCTAssertEqual(moves3, [.moveDown])
    }

    func testPerformanceGetCandidateMoveBfs() throws {
        let field = Field()
        let from = Position(x: 0, y: 0)
        let to = Position(x: fieldSize - 1, y: fieldSize - 1)
        self.measure {
            for _ in 0 ..< 10 {
                let _ = CommandUtil.getCandidateMove(from: from, to: to, field: field)
            }
        }
    }
    
    func testQueue() throws {
        let queue = Queue<Int>()
        queue.push(3)
        queue.push(5)
        XCTAssertEqual(queue.front, 3)
        XCTAssertEqual(queue.tail, 5)
        queue.pop()
        XCTAssertEqual(queue.front, 5)
        XCTAssertEqual(queue.tail, 5)
        queue.pushFront(7)
        XCTAssertEqual(queue.front, 7)
        XCTAssertEqual(queue.tail, 5)
    }

}
