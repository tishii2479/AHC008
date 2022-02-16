protocol HumanLogic {
    // Return command with sorted by high priority
    func command(field: Field, pos: Position, jobUnit: Schedule.Job.Unit?) -> [Command]
}

class Logic: HumanLogic {
    func command(field: Field, pos: Position, jobUnit: Schedule.Job.Unit?) -> [Command] {
        guard let jobUnit = jobUnit else { return [.none] }
        switch jobUnit.kind {
        case .move:
            let cand = CommandUtil.getCandidateMove(delta: jobUnit.pos - pos)
            if cand.count == 0 { return [.none] }
            return cand.shuffled()
        case .block:
            let dist: Int = pos.dist(to: jobUnit.pos)
            if dist == 0 {
                // if human is on the target, move some where random
                // (because human can't block where he is)
                return Command.moves.shuffled()
            }
            else if dist == 1 {
                // adjacent to block, so place it
                guard let block = CommandUtil.getBlock(delta: jobUnit.pos - pos) else { return [.none] }
                return [block]
            }
            else {
                // cant place block, so move towards the block
                let cand = CommandUtil.getCandidateMove(delta: jobUnit.pos - pos)
                if cand.count == 0 { return [.none] }
                return cand
            }
        }
    }
}
