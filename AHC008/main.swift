func main() {
    var pets = [Pet]()
    var humans = [Human]()

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
                id: i + N,
                brain: BasicHumanBrain()
            )
        )
    }
    
    let field = Field()
    field.addPlayers(players: humans + pets)
    let gridManager: GridManager = {
//        if (Double(N) / Double(M)) > 2.0
//            || PetUtil.getPetCount(pets: pets, for: .dog) >= 5
//            || PetUtil.getPetCount(pets: pets, for: .cat) >= 5 {
//            return ColumnGridManager()
//        }
        return SquareGridManager()
    }()
    let director = SquareGridJobDirector(
        field: field,
        humans: humans,
        pets: pets,
        gridManager: gridManager
    )
    let manager = Manager(
        field: field,
        humans: humans,
        pets: pets,
        director: director,
        ioController: RealIOController()
    )
    manager.start()
}

main()
