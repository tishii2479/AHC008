//
//  GridTest.swift
//  AHC008Test
//
//  Created by Tatsuya Ishii on 2022/02/19.
//

import XCTest

class GridTest: XCTestCase {
    // ..#
    // ..G
    // .PG
    // ..#
    func testGrid() throws {
        let field = Field()
        field.addBlocks(positions: [
            Position(x: 2, y: 0),
            Position(x: 2, y: 3)
        ])
        let grid = Grid(top: 0, left: 0, width: 2, height: 4, gates: [
            Position(x: 2, y: 1),
            Position(x: 2, y: 2),
        ])
        XCTAssertEqual(grid.petCountInGrid(field: field), 0)
        let pet = Pet(kind: .cat, pos: Position(x: 1, y: 2), id: 0)
        field.addPlayer(player: pet)
        XCTAssertEqual(grid.petCountInGrid(field: field), 1)
        let pet2 = Pet(kind: .cat, pos: Position(x: 2, y: 2), id: 0)
        field.addPlayer(player: pet2)
        XCTAssertEqual(grid.petCountInGrid(field: field), 1)
        XCTAssertFalse(grid.isClosed(field: field))
        field.addBlock(position: Position(x: 2, y: 1))
        XCTAssertFalse(grid.isClosed(field: field))
        field.addBlock(position: Position(x: 2, y: 2))
        XCTAssertTrue(grid.isClosed(field: field))
    }

}
