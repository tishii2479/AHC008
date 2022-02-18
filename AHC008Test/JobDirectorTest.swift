//
//  JobDirectorTest.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/17.
//

import XCTest

class JobDirectorTest: XCTestCase {
    func testBlockJobPerformance() throws {
        var field = Field()
        var humans = [Human]()
        for i in 0 ..< 5 {
            humans.append(
                Human(pos: Position(x: Int.random(in: 0 ..< fieldSize), y: Int.random(in: 0 ..< fieldSize)),
                      id: i, brain: HumanBrain()))
        }
        var pets: [Pet] = []
        let director = SquareGridJobDirector(field: &field, humans: &humans, pets: &pets)
        field.addPlayers(players: humans + pets)
        
        let expected: Int = 244
        for turn in 0 ..< 300 {
            director.directJobs(turn: turn)
            perform(field: &field, humans: &humans, pets: &pets)
            
            var count: Int = 0
            for y in 0 ..< fieldSize {
                for x in 0 ..< fieldSize {
                    if field.checkBlock(x: x, y: y) { count += 1 }
                }
            }
            
            if count == expected {
                field.dump()
                XCTAssertTrue(true)
                IO.log("Finished in turn: \(turn)")
                return
            }
        }
            
        field.dump()
        XCTFail("Should be finished in atleast 300 turns")
    }
    
    // Copied from Manager.swift
    private func perform(
        field: inout Field,
        humans: inout [Human],
        pets: inout [Pet]
    ) {
        var commands = [Command](repeating: .none, count: humans.count)
        field.updateField(players: humans + pets)
        
        // 0. Decide command
        for (i, human) in humans.enumerated() {
            if let command = human.commands(field: field).first {
                commands[i] = command
            }
        }

        // 1. Apply block
        for (i, human) in humans.enumerated() {
            if !commands[i].isBlock { continue }
            human.applyCommand(command: commands[i])
            field.applyCommand(player: human, command: commands[i])
        }

        field.updateField(players: humans + pets)
        
        // 2. Apply move
        for (i, human) in humans.enumerated() {
            if commands[i].isBlock { continue }
            // Check the destination is not blocked in this turn
            if !field.isValidCommand(player: human, command: commands[i]) {
                commands[i] = Command.moves
                    .filter { field.isValidCommand(player: human, command: $0) }.randomElement() ?? .none
            }
            human.applyCommand(command: commands[i])
        }
    }

}
