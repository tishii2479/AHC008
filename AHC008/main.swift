func main() {
    var pets = [Pet]()
    var humans = [Human]()
    var field = Field()

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
                brain: HumanBrain()
            )
        )
    }
    
    let director = SquareGridJobDirector(field: &field, humans: &humans, pets: &pets)
    let manager = Manager(field: field, humans: humans, pets: pets, director: director)
    manager.start()
}

main()
