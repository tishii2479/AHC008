protocol Player {
}

struct Position {
    var x: Int
    var y: Int
}

struct Human: Player {
    var pos: Position
    
    init(pos: Position) {
        self.pos = pos
    }
}

struct Pet: Player {
    enum Kind: Int {
        case Cow
        case Pig
        case Rabbit
        case Dog
        case Cat
    }
    
    var kind: Kind
    var pos: Position
    
    init(kind: Kind, pos: Position) {
        self.kind = kind
        self.pos = pos
    }
}
