class Player {
    var pos: Position
    init(pos: Position) {
        self.pos = pos
    }
}

struct Position {
    var x: Int
    var y: Int
}

class Human: Player {
}

class Pet: Player {
    enum Kind: Int {
        case Cow
        case Pig
        case Rabbit
        case Dog
        case Cat
    }
    
    var kind: Kind
    
    init(kind: Kind, pos: Position) {
        self.kind = kind
        super.init(pos: pos)
    }
}
