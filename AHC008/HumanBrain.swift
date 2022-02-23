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
        case .move, .forceMove:
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
        let notAllowedPositionsOutsideGrid = isInGrid(pos: pos) ? [] : notAllowedPositions
        guard let jobUnit = jobUnit else { return [.none] }
        switch jobUnit.kind {
        case .forceMove:
            return CommandUtil.calcShortestMove(from: pos, to: jobUnit.pos, field: field).shuffled()
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
            let to = isInGrid(pos: pos) ? jobUnit.pos : (target?.pos ?? jobUnit.pos)
            return CommandUtil.calcShortestMove(from: pos, to: to, field: field, notAllowedPositions: notAllowedPositionsOutsideGrid).shuffled()
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
            return CommandUtil.calcShortestMove(from: pos, to: jobUnit.pos, field: field, notAllowedPositions: notAllowedPositionsOutsideGrid).shuffled()
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
                let cand = CommandUtil.calcShortestMove(from: pos, to: jobUnit.pos, field: field, notAllowedPositions: notAllowedPositionsOutsideGrid)
                if cand.count == 0 { return [.none] }
                return cand.shuffled()
            }
        }
    }
    
    private func isInGrid(pos: Position) -> Bool {
        for grid in grids {
            if grid.zone.contains(pos)
                || grid.gates.contains(pos) { return true }
        }
        return false
    }
}
