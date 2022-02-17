class GridCreator {
    func createGrid() -> [Grid] {
        var grids = [Grid]()
        // Corners
        do {
            let width = 5
            let height = 4
            grids.append(Grid(top: 0, left: 0, width: width, height: height, gate: Position(x: 3, y: 4)))
            grids.append(Grid(top: 0, left: 25, width: width, height: height, gate: Position(x: 26, y: 4)))
            grids.append(Grid(top: 26, left: 0, width: width, height: height, gate: Position(x: 3, y: 25)))
            grids.append(Grid(top: 26, left: 25, width: width, height: height, gate: Position(x: 26, y: 25)))
        }
        
        // Sides
        for y in [5, 12, 19] {
            let width = 3
            let height = 6
            grids.append(Grid(top: y, left: 0, width: width, height: height, gate: Position(x: 3, y: y + 2)))
            grids.append(Grid(top: y, left: 27, width: width, height: height, gate: Position(x: 26, y: y + 2)))
        }
        
        // Top and bottom
        for x in [6, 12, 19] {
            let width = x == 12 ? 6 : 5
            let height = 3
            grids.append(Grid(top: 0, left: x, width: width, height: height, gate: Position(x: x + 2, y: 3)))
            grids.append(Grid(top: 27, left: x, width: width, height: height, gate: Position(x: x + 2, y: 26)))
        }
        
        // Center vertical
        do {
            let width = 3
            let height = 8
            grids.append(Grid(top: 6, left: 6, width: width, height: height, gate: Position(x: 7, y: 5)))
            grids.append(Grid(top: 6, left: 10, width: width, height: height, gate: Position(x: 11, y: 5)))
            
            grids.append(Grid(top: 16, left: 17, width: width, height: height, gate: Position(x: 18, y: 24)))
            grids.append(Grid(top: 16, left: 21, width: width, height: height, gate: Position(x: 22, y: 24)))
        }
        
        // Center horizontal
        do {
            let width = 8
            let height = 3
            grids.append(Grid(top: 17, left: 6, width: width, height: height, gate: Position(x: 5, y: 18)))
            grids.append(Grid(top: 21, left: 6, width: width, height: height, gate: Position(x: 5, y: 22)))
            
            grids.append(Grid(top: 6, left: 16, width: width, height: height, gate: Position(x: 24, y: 7)))
            grids.append(Grid(top: 10, left: 16, width: width, height: height, gate: Position(x: 24, y: 11)))
        }
        
//        dumpGrids(grids: grids)
        return grids
    }
    
    // For Debug
    private func dumpGrids(grids: [Grid]) {
        var f = [[String]](repeating: [String](repeating: ".", count: fieldSize), count: fieldSize)
        for grid in grids {
            for x in grid.topLeft.x ... grid.bottomRight.x {
                for y in grid.topLeft.y ... grid.bottomRight.y {
                    f[y][x] = "Q"
                }
            }
            f[grid.gate.y][grid.gate.x] = "!"
        }
        var str = "\n"
        for y in 0 ..< fieldSize {
            for x in 0 ..< fieldSize {
                str += f[y][x]
            }
            str += "\n"
        }
        IO.log(str)
    }
}
