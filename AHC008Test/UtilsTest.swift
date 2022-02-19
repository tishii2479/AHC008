//
//  UtilsTest.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/16.
//

import XCTest

class UtilsTest: XCTestCase {
    func testCreateLineBlockJob() throws {
        let job = JobUtil.createLineBlockJob(
            from: Position(x: 3, y: 0),
            to: Position(x: 3, y: 29)
        )
        XCTAssertEqual(job.units.count, 59)
        XCTAssertEqual(job.cost, 30 + 29)
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
