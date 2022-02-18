protocol Brain {
    // Return command with sorted by high priority
    func command(field: Field, pos: Position, jobUnit: Schedule.Job.Unit?) -> [Command]
}

class HumanBrain: Brain {
    func command(field: Field, pos: Position, jobUnit: Schedule.Job.Unit?) -> [Command] {
        guard let jobUnit = jobUnit else { return [.none] }
        switch jobUnit.kind {
        case .move:
            let cand = CommandUtil.getCandidateMove(from: pos, to: jobUnit.pos, field: field)
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
                guard let block = CommandUtil.deltaToBlockCommand(delta: jobUnit.pos - pos) else { return [.none] }
                return [block]
            }
            else {
                // cant place block, so move towards the block
                let cand = CommandUtil.getCandidateMove(from: pos, to: jobUnit.pos, field: field)
                if cand.count == 0 { return [.none] }
                return cand.shuffled()
            }
        }
    }
}

class HumanBrainWithGridKnowledge: Brain {
    let grids: [Grid]
    init(grids: [Grid]) {
        self.grids = grids
    }

    func command(field: Field, pos: Position, jobUnit: Schedule.Job.Unit?) -> [Command] {
        guard let jobUnit = jobUnit else { return [.none] }
        switch jobUnit.kind {
        case .move:
            var commands = [Command]()
            for grid in grids {
                guard !field.checkBlock(at: grid.gate),
                      grid.gate.dist(to: pos) == 1 else { continue }
                var petCount: Int = 0
                var humanCount: Int = 0
                for x in grid.topLeft.x ... grid.bottomRight.x {
                    for y in grid.topLeft.y ... grid.bottomRight.y {
                        petCount += field.getPetCount(x: x, y: y)
                        humanCount += field.getHumanCount(x: x, y: y)
                    }
                }
                if petCount > 0 && humanCount == 0 {
                    if let block = CommandUtil.deltaToBlockCommand(delta: grid.gate - pos) {
                        commands.append(block)
                    }
                }
            }
            return commands + CommandUtil.getCandidateMove(from: pos, to: jobUnit.pos, field: field)
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
                let cand = CommandUtil.getCandidateMove(from: pos, to: jobUnit.pos, field: field)
                if cand.count == 0 { return [.none] }
                return cand.shuffled()
            }
        }
    }
}
