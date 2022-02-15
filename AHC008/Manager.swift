class Manager {
    private var petCount: Int { pets.count }
    private var humanCount: Int { humans.count }
    private var pets = [Pet]()
    private var humans = [Human]()
    private var field = Field()
    
    func start() {
        initialize()
        
        for _ in 0 ..< turnLimit {
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
        let moves: [Move] = Solver.solve(field: &field, humans: &humans, pets: &pets)
        IO.output(String(moves.map { $0.rawValue }))
    }
    
    private func initialize() {
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
