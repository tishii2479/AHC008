class GameManager {
    private var petCount: Int { pets.count }
    private var humanCount: Int { humans.count }
    private var pets = [Pet]()
    private var humans = [Human]()
    private var field = Field()
    
    func startGame() {
        initGame()
        
        for turn in 0 ..< turnLimit {
            IO.log("Turn: " + String(turn))
            field = Field(players: pets + humans, walls: field.walls)
            outputHumanMove()
            inputPetMove()
        }
    }
    
    private func inputPetMove() {
        let petMoves = IO.readStringArray()
        guard petMoves.count == petCount else {
            fatalError("Input format error")
        }
        for i in 0 ..< petCount {
            for e in petMoves[i] {
                pets[i].applyMove(move: Move.toEnum(e))
            }
        }
    }
    
    private func outputHumanMove() {
        var moves = [String](repeating: ".", count: humanCount)
        
        // 1. Perform move
        
        // 2. Perform block if possible
        
        IO.output(moves.joined(separator: ""))
    }
    
    private func initGame() {
        let N = IO.readInt()
        for i in 0 ..< N {
            let arr = IO.readIntArray()
            guard arr.count == 3,
                  let kind = Pet.Kind(rawValue: arr[2] - 1) else { fatalError("Input format error") }
            pets.append(
                Pet(
                    kind: kind,
                    pos: Position(x: arr[1] - 1, y: arr[0] - 1),
                    id: i
                )
            )
        }
        let M = IO.readInt()
        for i in 0 ..< M {
            let arr = IO.readIntArray()
            guard arr.count == 2 else { fatalError("Input format error") }
            humans.append(
                Human(
                    pos: Position(x: arr[1] - 1, y: arr[0] - 1),
                    id: i + N
                )
            )
        }
    }
}
