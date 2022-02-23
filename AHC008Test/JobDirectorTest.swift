//
//  JobDirectorTest.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/17.
//

import XCTest

class JobDirectorTest: XCTestCase {
    private var director: SquareGridJobDirector!
    private var manager: Manager!
    private var field: Field!
    private var humans: [Human]!
    private var pets: [Pet]!
    private let gridManager: GridManager = SquareGridManager()
    
    override func setUp() {
        field = Field()
        humans = [Human]()
        for i in 0 ..< 5 {
            humans.append(
                Human(pos: Position(x: 15, y: 15),
                      id: i, brain: BasicHumanBrain()))
        }
        pets = []
        director = SquareGridJobDirector(
            field: field,
            humans: humans,
            pets: pets,
            gridManager: gridManager
        )
        manager = Manager(
            field: field,
            humans: humans,
            pets: pets,
            director: director,
            ioController: MockIOController()
        )
        field.addPlayers(players: humans + pets)
    }
    
    func testBlockJobPerformance() throws {
        let expected: Int = 252
        for turn in 0 ..< 300 {
            manager.processTurn(turn: turn)
            
            if turn == 0 {
                for human in humans {
                    IO.log(human.jobCost)
                }
            }
            
            var count: Int = 0
            for y in 0 ..< fieldSize {
                for x in 0 ..< fieldSize {
                    if field.checkBlock(x: x, y: y) { count += 1 }
                }
            }
            
            if director.didCaptureDog && count >= expected {
                XCTAssertTrue(true)
                field.dump()
                IO.log("Finished in turn: \(turn)")
                return
            }
        }
            
        field.dump()
        XCTFail("Should be finished in atleast 300 turns")
    }
}
