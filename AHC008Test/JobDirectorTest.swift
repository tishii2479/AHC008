//
//  JobDirectorTest.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/17.
//

import XCTest

class JobDirectorTest: XCTestCase {
    private var director: JobDirector!
    private var manager: Manager!
    private var field: Field!
    private var humans: [Human]!
    private var pets: [Pet]!
    
    override func setUp() {
        field = Field()
        humans = [Human]()
        for i in 0 ..< 5 {
            humans.append(
                Human(pos: Position(x: Int.random(in: 0 ..< fieldSize), y: Int.random(in: 0 ..< fieldSize)),
                      id: i, brain: BasicHumanBrain()))
        }
        pets = []
        director = SquareGridJobDirector(
            field: field,
            humans: humans,
            pets: pets,
            gridManager: SquareGridManager()
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
        let expected: Int = 244
        for turn in 0 ..< 300 {
            director.directJobs(turn: turn)
            manager.processTurn(turn: turn)
            
            var count: Int = 0
            for y in 0 ..< fieldSize {
                for x in 0 ..< fieldSize {
                    if field.checkBlock(x: x, y: y) { count += 1 }
                }
            }
            
            if count == expected {
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
