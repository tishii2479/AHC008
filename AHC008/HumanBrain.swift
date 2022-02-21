protocol HumanBrain {
    // Return command with sorted by high priority
    func command(field: Field, pos: Position, jobUnit: Schedule.Job.Unit?) -> [Command]
}

struct BasicHumanBrain: HumanBrain {
    func command(field: Field, pos: Position, jobUnit: Schedule.Job.Unit?) -> [Command] {
        guard let jobUnit = jobUnit else { return [.none] }
        switch jobUnit.kind {
        case .move:
            let cand = CommandUtil.calcShortestMove(from: pos, to: jobUnit.pos, field: field)
            if cand.count == 0 { return [.none] }
            return cand.shuffled() + Command.moves.shuffled()
        case .block, .close:
            let dist: Int = pos.dist(to: jobUnit.pos)
            if dist == 0 {
                // if human is on the target, move some where random
                // (because human can't block where he is)
                return Command.moves.shuffled()
            }
            else if dist == 1 {
                // adjacent to block, so place it
                guard let block = CommandUtil.deltaToBlockCommand(delta: jobUnit.pos - pos) else { return [.none] }
                return [block]
            }
            else {
                // cant place block, so move towards the block
                let cand = CommandUtil.calcShortestMove(from: pos, to: jobUnit.pos, field: field)
                if cand.count == 0 { return [.none] }
                return cand.shuffled()
            }
        }
    }
}

struct HumanBrainWithGridKnowledge: HumanBrain {
    let grids: [Grid]

    func command(field: Field, pos: Position, jobUnit: Schedule.Job.Unit?) -> [Command] {
        guard let jobUnit = jobUnit else { return Command.moves.shuffled() }
        switch jobUnit.kind {
        case .move, .close:
            for grid in grids {
                for gate in grid.gates {
                    guard !field.checkBlock(at: gate),
                          gate.dist(to: pos) == 1,
                          grid.petCountInGrid(field: field) > 0 else { continue }
                    if let block = CommandUtil.deltaToBlockCommand(delta: gate - pos) {
                        return [block, .none]
                    }
                }
            }
            return CommandUtil.calcShortestMove(from: pos, to: jobUnit.pos, field: field).shuffled()
        case .block:
            let dist: Int = pos.dist(to: jobUnit.pos)
            if dist == 0 {
                // if human is on the target, move some where random
                // (because human can't block where he is)
                return Command.moves.shuffled()
            }
            else if dist == 1 {
                // adjacent to block, so place it
                guard let block = CommandUtil.deltaToBlockCommand(delta: jobUnit.pos - pos) else {
                    IO.log("Block command not found", type: .warn)
                    return [.none]
                }
                return [block]
            }
            else {
                // cant place block, so move towards the block
                let cand = CommandUtil.calcShortestMove(from: pos, to: jobUnit.pos, field: field)
                if cand.count == 0 { return [.none] }
                return cand.shuffled()
            }
        }
    }
}
