class GameManager {
    private var pets = [Pet]()
    private var humans = [Human]()
    
    func initGame() {
        let N = readInt()
        for _ in 0 ..< N {
            let arr = readIntArray()
            guard arr.count == 3,
                  let kind = Pet.Kind(rawValue: arr[2] - 1) else { fatalError("Input format error") }
            pets.append(
                Pet(
                    kind: kind,
                    pos: Position(x: arr[0] - 1, y: arr[1] - 1)
                )
            )
        }
        let M = readInt()
        for _ in 0 ..< M {
            let arr = readIntArray()
            guard arr.count == 2 else { fatalError("Input format error") }
            humans.append(
                Human(
                    pos: Position(x: arr[0] - 1, y: arr[1] - 1)
                )
            )
        }
    }
}
