//
//  GameAI.swift
//  TicTacToe
//
//  Created by Gonzo Fialho on 30/09/18.
//  Copyright © 2018 Gonzo Fialho. All rights reserved.
//

import UIKit

class GameAI {

    static let shared = GameAI()

    struct Query: Hashable {
        let state: String
        let player: String
        let max: Bool
        let targetPlayer: String
    }

    var memo: [Query: Int] = [:]

    func solveGame(state: Game.GameState, for player: Game.Player) -> Game.CellPosition {
        var _state = state
        var results: [(Int, Game.CellPosition)] = []
        for position in state.freeSpaces {
            _state[position] = player
            let score = minimax(state: _state, player: player.other, max: false, targetPlayer: player)
            results.append((score, position))
            _state[position] = nil
        }
        return results.shuffled().max {$0.0 < $1.0}!.1
    }

    func minimax(state: Game.GameState, player: Game.Player, max: Bool, targetPlayer: Game.Player) -> Int {
        let query = Query(
            state: state.serialized(),
            player: player.rawValue,
            max: max,
            targetPlayer: targetPlayer.rawValue)
        if let score = memo[query] {
            return score
        }
        let (finished, winningPlayer, _) = Game.checkGameFinished(gameState: state)
        let score: Int
        if finished {
            switch winningPlayer {
            case .none: score = 0
            case .some(let p): score = p == targetPlayer ? 1 : -1
            }
        } else {
            var _state = state
            var results: [Int] = []
            for position in state.freeSpaces {
                _state[position] = player
                let score = minimax(state: _state, player: player.other, max: !max, targetPlayer: targetPlayer)
                results.append(score)
                _state[position] = nil
            }

            if max {
                score = results.max()!
            } else {
                score = results.min()!
            }
        }

        memo[query] = score
        return score
    }
}
