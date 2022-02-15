class GameManager {
    private var petCount: Int { pets.count }
    private var humanCount: Int { humans.count }
    private var pets = [Pet]()
    private var humans = [Human]()
    
    func startGame() {
        initGame()
        
        for turn in 0 ..< turnLimit {
//            IO.log("Turn: " + String(turn))
            outputHumanMove()
            inputPetMove()
        }
    }
    
    private func inputPetMove() {
        let petMoves = IO.readStringArray()
        guard petMoves.count == petCount else {
            fatalError("Input format error")
        }
    }
    
    private func outputHumanMove() {
        IO.output(String(repeating: ".", count: humanCount))
    }
    
    private func initGame() {
        let N = IO.readInt()
        for _ in 0 ..< N {
            let arr = IO.readIntArray()
            guard arr.count == 3,
                  let kind = Pet.Kind(rawValue: arr[2] - 1) else { fatalError("Input format error") }
            pets.append(
                Pet(
                    kind: kind,
                    pos: Position(x: arr[0] - 1, y: arr[1] - 1)
                )
            )
        }
        let M = IO.readInt()
        for _ in 0 ..< M {
            let arr = IO.readIntArray()
            guard arr.count == 2 else { fatalError("Input format error") }
            humans.append(
                Human(
                    pos: Position(x: arr[0] - 1, y: arr[1] - 1)
                )
            )
        }
    }
}
