protocol HumanLogic {
    func step(field: Field, pos: Position, jobUnit: Schedule.Job.Unit) -> Command
}

class Logic: HumanLogic {
    func step(field: Field, pos: Position, jobUnit: Schedule.Job.Unit) -> Command {
        switch jobUnit.kind {
        case .move:
            let cand = getCandidateMove(delta: jobUnit.pos - pos)
            if cand.count == 0 { return .none }
            return cand[Int.random(in: 0 ..< cand.count)]
        case .block:
            let dist: Int = pos.dist(to: jobUnit.pos)
            if dist == 0 {
                // if human is on the target, move some where random
                // (because human can't block where he is)
                return Command.moves[Int.random(in: 0 ..< Command.moves.count)]
            }
            else if dist == 1 {
                guard let block = getBlock(delta: jobUnit.pos - pos) else { return .none }
                return block
            }
            else {
                let cand = getCandidateMove(delta: jobUnit.pos - pos)
                if cand.count == 0 { return .none }
                return cand[Int.random(in: 0 ..< cand.count)]
            }
        }
    }
    
    // ISSUE: This does not consider the move is valid
    // (if there is block, it can't be proceeded)
    private func getCandidateMove(delta: Position) -> [Command] {
        var cand = [Command]()
        if delta.x > 0 { cand.append(.moveRight) }
        if delta.x < 0 { cand.append(.moveLeft) }
        if delta.y < 0 { cand.append(.moveUp) }
        if delta.y > 0 { cand.append(.moveDown) }
        return cand
    }
    
    private func getBlock(delta: Position) -> Command? {
        if delta.x > 0 { return .blockRight }
        if delta.x < 0 { return .blockLeft }
        if delta.y < 0 { return .blockUp }
        if delta.y > 0 { return .blockDown }
        return nil
    }
}
