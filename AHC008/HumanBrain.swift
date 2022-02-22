protocol HumanBrain {
    var target: Pet? { get set }
    // Return command with sorted by high priority
    func command(field: Field, pos: Position, jobUnit: Schedule.Job.Unit?) -> [Command]
}

struct BasicHumanBrain: HumanBrain {
    var target: Pet? = nil
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
    var target: Pet? = nil
    var petCaptureLimit: Int = 1
    var notAllowedPositions: [Position] = []
    let grids: [Grid]

    func command(field: Field, pos: Position, jobUnit: Schedule.Job.Unit?) -> [Command] {
        guard let jobUnit = jobUnit else { return [.none] }
        switch jobUnit.kind {
        case .move:
            for grid in grids {
                for gate in grid.gates {
                    guard !field.checkBlock(at: gate),
                          gate.dist(to: pos) == 1,
                          grid.petCountInGrid(field: field) >= petCaptureLimit,
                          grid.isPrepared(field: field),
                          !grid.zone.contains(pos) else { continue }
                    if let block = CommandUtil.deltaToBlockCommand(delta: gate - pos) {
                        return [block, .none]
                    }
                }
            }
//            IO.log(pos, target?.pos, CommandUtil.calcShortestMove(from: pos, to: target?.pos ?? jobUnit.pos, field: field, treatAsBlocks: treatAsBlocks).shuffled())
            return CommandUtil.calcShortestMove(from: pos, to: target?.pos ?? jobUnit.pos, field: field, notAllowedPositions: notAllowedPositions).shuffled()
        case .close:
            for grid in grids {
                for gate in grid.gates {
                    guard !field.checkBlock(at: gate),
                          gate.dist(to: pos) == 1,
                          grid.petCountInGrid(field: field) >= petCaptureLimit,
                          grid.isPrepared(field: field),
                          !grid.zone.contains(pos) else { continue }
                    if let block = CommandUtil.deltaToBlockCommand(delta: gate - pos) {
                        return [block, .none]
                    }
                }
            }
            return CommandUtil.calcShortestMove(from: pos, to: jobUnit.pos, field: field, notAllowedPositions: notAllowedPositions).shuffled()
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
                let cand = CommandUtil.calcShortestMove(from: pos, to: jobUnit.pos, field: field, notAllowedPositions: notAllowedPositions)
                if cand.count == 0 { return [.none] }
                return cand.shuffled()
            }
        }
    }
}
