//
//  Game.swift
//  TicTacToe
//
//  Created by Gonzo Fialho on 30/09/18.
//  Copyright © 2018 Gonzo Fialho. All rights reserved.
//

import UIKit

protocol GameDelegate {
    func stateChanged(game: Game)
}

class Game {
    enum Player {
        case cross
        case nought

        var other: Player {
            switch self {
            case .cross: return .nought
            case .nought: return .cross
            }
        }
    }

    enum CellState: Equatable {
        case free
        case occupied(Player)
    }

    struct CellPosition: Hashable {
        let row: Int
        let column: Int
    }

    typealias GameState = Dictionary<CellPosition, CellState>


    var gameState: GameState
    var currentPlayer: Player
    var delegate: GameDelegate?

    init() {
        gameState = [:]
        for i in 0..<3 {
            for j in 0..<3 {
                gameState[CellPosition(row: i, column: j)] = .free
            }
        }

        currentPlayer = .cross
    }

    func makeMove(at position: CellPosition) {
        guard gameState[position] == .free else {return}

        gameState[position] = .occupied(currentPlayer)
        currentPlayer = currentPlayer.other
        delegate?.stateChanged(game: self)
    }
}
