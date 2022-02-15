//
//  TestField.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/15.
//

import XCTest

class FieldTest: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    // ...H
    // WH..
    // P...
    // ....
    func testAddPlayer() throws {
        let field = Field()
        XCTAssertEqual(field.getPlayers(x: 1, y: 1).count, 0)
        let human = Human(pos: Position(x: 1, y: 1), id: 0)
        field.addPlayer(player: human)
        XCTAssertEqual(field.getPlayers(x: 1, y: 1).count, 1)
        let human2 = Human(pos: Position(x: 3, y: 0), id: 1)
        field.addPlayer(player: human2)
        XCTAssertEqual(field.getPlayers(x: 3, y: 0).count, 1)
        
        let block = Position(x: 0, y: 1)
        field.addBlock(block: block)
        XCTAssertTrue(field.checkBlock(x: 0, y: 1))
        
        XCTAssertEqual(field.getPlayers(x: 0, y: 2).count, 0)
        let pet = Pet(kind: .cat, pos: Position(x: 0, y: 2), id: 2)
        field.addPlayer(player: pet)
        XCTAssertEqual(field.getPlayers(x: 0, y: 2).count, 1)
        
        XCTAssertFalse(field.isValidMove(player: human, move: .left))
        XCTAssertTrue(field.isValidMove(player: human, move: .up))
        XCTAssertTrue(field.isValidMove(player: human, move: .right))
        XCTAssertTrue(field.isValidMove(player: human, move: .down))
        
        XCTAssertFalse(field.isValidMove(player: pet, move: .up))
        XCTAssertFalse(field.isValidMove(player: pet, move: .left))
        XCTAssertTrue(field.isValidMove(player: pet, move: .down))
        XCTAssertTrue(field.isValidMove(player: pet, move: .right))
        
        XCTAssertTrue(field.isValidMove(player: human2, move: .left))
        XCTAssertFalse(field.isValidMove(player: human2, move: .up))
        XCTAssertTrue(field.isValidMove(player: human2, move: .right))
        XCTAssertTrue(field.isValidMove(player: human2, move: .down))
    }

}