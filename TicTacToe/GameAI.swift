//
//  GameAI.swift
//  TicTacToe
//
//  Created by Gonzo Fialho on 30/09/18.
//  Copyright © 2018 Gonzo Fialho. All rights reserved.
//

import UIKit

class GameAI {

    static func solveGame(state: Game.GameState, for player: Game.Player) -> Game.CellPosition {
        var _state = state
        var results: [(Int, Game.CellPosition)] = []
        for position in state.freeSpaces {
            _state[position] = .occupied(player)
            let score = minimax(state: _state, player: player.other, max: false, targetPlayer: player)
            results.append((score, position))
            _state[position] = .free
        }
        return results.shuffled().max {$0.0 < $1.0}!.1
    }

    static func minimax(state: Game.GameState, player: Game.Player, max: Bool, targetPlayer: Game.Player) -> Int {
        let (finished, winningPlayer, _) = Game.checkGameFinished(gameState: state)
        if finished {
            switch winningPlayer {
            case .none: return 0
            case .some(let p): return p == targetPlayer ? 1 : -1
            }
        }
        var _state = state
        var results: [Int] = []
        for position in state.freeSpaces {
            _state[position] = .occupied(player)
            let score = minimax(state: _state, player: player.other, max: !max, targetPlayer: targetPlayer)
            results.append(score)
            _state[position] = .free
        }

        if max {
            return results.max()!
        } else {
            return results.min()!
        }
    }
}
