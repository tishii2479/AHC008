//
//  FieldTest.swift
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
        let human = Human(pos: Position(x: 1, y: 1), id: 0, brain: HumanBrain())
        field.addPlayer(player: human)
        XCTAssertEqual(field.getPlayers(x: 1, y: 1).count, 1)
        let human2 = Human(pos: Position(x: 3, y: 0), id: 1, brain: HumanBrain())
        field.addPlayer(player: human2)
        XCTAssertEqual(field.getPlayers(x: 3, y: 0).count, 1)
        
        let block = Position(x: 0, y: 1)
        field.addBlock(position: block)
        XCTAssertTrue(field.checkBlock(x: 0, y: 1))
        
        XCTAssertEqual(field.getPlayers(x: 0, y: 2).count, 0)
        let pet = Pet(kind: .cat, pos: Position(x: 0, y: 2), id: 2)
        field.addPlayer(player: pet)
        XCTAssertEqual(field.getPlayers(x: 0, y: 2).count, 1)
        
        XCTAssertFalse(field.isValidCommand(player: human, command: .moveLeft))
        XCTAssertTrue(field.isValidCommand(player: human, command: .moveUp))
        XCTAssertTrue(field.isValidCommand(player: human, command: .moveRight))
        XCTAssertTrue(field.isValidCommand(player: human, command: .moveDown))
        
        XCTAssertFalse(field.isValidCommand(player: pet, command: .moveUp))
        XCTAssertFalse(field.isValidCommand(player: pet, command: .moveLeft))
        XCTAssertTrue(field.isValidCommand(player: pet, command: .moveDown))
        XCTAssertTrue(field.isValidCommand(player: pet, command: .moveRight))
        
        XCTAssertTrue(field.isValidCommand(player: human2, command: .moveLeft))
        XCTAssertFalse(field.isValidCommand(player: human2, command: .moveUp))
        XCTAssertTrue(field.isValidCommand(player: human2, command: .moveRight))
        XCTAssertTrue(field.isValidCommand(player: human2, command: .moveDown))
    }
    
    // .H.
    // HP.
    // P..
    // ...
    func testBlockCommand() throws {
        let field = Field()
        let human = Human(pos: Position(x: 0, y: 1), id: 0, brain: HumanBrain())
        let human2 = Human(pos: Position(x: 1, y: 0), id: 0, brain: HumanBrain())
        let pet = Pet(kind: .cat, pos: Position(x: 1, y: 1), id: 1)
        let pet2 = Pet(kind: .cat, pos: Position(x: 0, y: 2), id: 2)
        field.addPlayers(players: [human, human2, pet, pet2])
        
        XCTAssertTrue(field.isValidCommand(player: human, command: .blockUp))
        XCTAssertFalse(field.isValidCommand(player: human, command: .blockDown))
        XCTAssertFalse(field.isValidCommand(player: human, command: .blockRight))
        XCTAssertFalse(field.isValidCommand(player: human, command: .blockLeft))
        
        pet.applyCommand(command: .moveRight)
        field.updateField(players: [human, human2, pet, pet2])
        XCTAssertFalse(field.isValidCommand(player: human, command: .blockRight))
        pet.applyCommand(command: .moveRight)
        field.updateField(players: [human, human2, pet, pet2])
        XCTAssertTrue(field.isValidCommand(player: human, command: .blockRight))
        human2.applyCommand(command: .moveDown)
        field.updateField(players: [human, human2, pet, pet2])
        XCTAssertFalse(field.isValidCommand(player: human, command: .blockRight))
        
        human.applyCommand(command: .moveDown)
        field.updateField(players: [human, human2, pet, pet2])
        
        XCTAssertFalse(field.isValidCommand(player: human, command: .blockUp))
        XCTAssertFalse(field.isValidCommand(player: human, command: .blockDown))
        XCTAssertFalse(field.isValidCommand(player: human, command: .blockRight))
        XCTAssertFalse(field.isValidCommand(player: human, command: .blockLeft))
    }
    
    func testCommandPlayer() throws {
        let field = Field()
        let human = Human(pos: Position(x: 1, y: 1), id: 0, brain: HumanBrain())
        field.addPlayer(player: human)
        XCTAssertEqual(field.getPlayers(x: 1, y: 1).count, 1)
        human.applyCommand(command: .moveUp)
        field.updateField(players: [human])
        XCTAssertEqual(field.getPlayers(x: 1, y: 0).count, 1)
        XCTAssertEqual(field.getPlayers(x: 1, y: 0).count, 1)
    }
    
    // .P.
    // P.P
    // .P.
    func testIsValidBlock() throws {
        let field = Field()
        let pets = [
            Position(x: 1, y: 0),
            Position(x: 1, y: 2),
            Position(x: 0, y: 1),
            Position(x: 2, y: 1),
        ]
        for pet in pets {
            field.addPlayer(player: Pet(kind: .cat, pos: pet, id: 0))
        }
        for y in 0 ... 2 {
            for x in 0 ... 2 {
                XCTAssertFalse(field.isValidBlock(target: Position(x: x, y: y)))
            }
        }
    }

}
