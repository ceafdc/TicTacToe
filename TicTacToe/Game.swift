//
//  Game.swift
//  TicTacToe
//
//  Created by Gonzo Fialho on 30/09/18.
//  Copyright © 2018 Gonzo Fialho. All rights reserved.
//

import UIKit

class Game {
    enum CellState {
        case free
        case cross
        case nought
    }
    struct CellPosition: Hashable {
        let row: Int
        let column: Int
    }
    typealias GameState = Dictionary<CellPosition, CellState>


    var gameState: GameState

    init() {
        gameState = [:]
        for i in 0..<3 {
            for j in 0..<3 {
                gameState[CellPosition(row: i, column: j)] = .free
            }
        }
    }
}
