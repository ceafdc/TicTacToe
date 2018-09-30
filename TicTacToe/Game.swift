//
//  Game.swift
//  TicTacToe
//
//  Created by Gonzo Fialho on 30/09/18.
//  Copyright © 2018 Gonzo Fialho. All rights reserved.
//

import UIKit

class Game {
    enum Player {
        case cross
        case nought
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

    init() {
        gameState = [:]
        for i in 0..<3 {
            for j in 0..<3 {
                gameState[CellPosition(row: i, column: j)] = .free
            }
        }

        currentPlayer = .cross
    }
    }
}
