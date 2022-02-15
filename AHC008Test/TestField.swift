//
//  TestField.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/15.
//

import XCTest

class FieldTest: XCTestCase {
    // ...H.
    // WH.P.
    // P....
    // .....
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
        
        XCTAssertFalse(field.isValidMove(player: human, delta: .left))
        XCTAssertTrue(field.isValidMove(player: human, delta: .up))
        XCTAssertTrue(field.isValidMove(player: human, delta: .right))
        XCTAssertTrue(field.isValidMove(player: human, delta: .down))
        
        XCTAssertFalse(field.isValidMove(player: pet, delta: .up))
        XCTAssertFalse(field.isValidMove(player: pet, delta: .left))
        XCTAssertTrue(field.isValidMove(player: pet, delta: .down))
        XCTAssertTrue(field.isValidMove(player: pet, delta: .right))
        
        XCTAssertTrue(field.isValidMove(player: human2, delta: .left))
        XCTAssertFalse(field.isValidMove(player: human2, delta: .up))
        XCTAssertTrue(field.isValidMove(player: human2, delta: .right))
        XCTAssertTrue(field.isValidMove(player: human2, delta: .down))
    }
    
    // .H.
    // HP.
    // P..
    // ...
    func testBlockMove() throws {
        let field = Field()
        let human = Human(pos: Position(x: 0, y: 1), id: 0)
        let human2 = Human(pos: Position(x: 1, y: 0), id: 0)
        let pet = Pet(kind: .cat, pos: Position(x: 1, y: 1), id: 1)
        let pet2 = Pet(kind: .cat, pos: Position(x: 0, y: 2), id: 2)
        field.addPlayers(players: [human, human2, pet, pet2])
        
        XCTAssertTrue(field.isValidBlockMove(player: human, delta: .up))
        XCTAssertFalse(field.isValidBlockMove(player: human, delta: .down))
        XCTAssertFalse(field.isValidBlockMove(player: human, delta: .right))
        XCTAssertFalse(field.isValidBlockMove(player: human, delta: .left))
        
        pet.applyMove(move: .moveRight)
        field.updateField(players: [human, human2, pet, pet2])
        XCTAssertFalse(field.isValidBlockMove(player: human, delta: .right))
        pet.applyMove(move: .moveRight)
        field.updateField(players: [human, human2, pet, pet2])
        XCTAssertTrue(field.isValidBlockMove(player: human, delta: .right))
        human2.applyMove(move: .moveDown)
        field.updateField(players: [human, human2, pet, pet2])
        XCTAssertFalse(field.isValidBlockMove(player: human, delta: .right))
        
        human.applyMove(move: .moveDown)
        field.updateField(players: [human, human2, pet, pet2])
        
        XCTAssertFalse(field.isValidBlockMove(player: human, delta: .up))
        XCTAssertFalse(field.isValidBlockMove(player: human, delta: .down))
        XCTAssertFalse(field.isValidBlockMove(player: human, delta: .right))
        XCTAssertFalse(field.isValidBlockMove(player: human, delta: .left))
    }
    
    func testMovePlayer() throws {
        let field = Field()
        let human = Human(pos: Position(x: 1, y: 1), id: 0)
        field.addPlayer(player: human)
        XCTAssertEqual(field.getPlayers(x: 1, y: 1).count, 1)
        human.applyMove(move: .moveUp)
        field.updateField(players: [human])
        XCTAssertEqual(field.getPlayers(x: 1, y: 0).count, 1)
        XCTAssertEqual(field.getPlayers(x: 1, y: 0).count, 1)
    }

}
