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
    func gameFinished(result: Game.Player?, positions: [Game.CellPosition]?)
}

class Game {
    enum Player {
        case cross
        case nought

        static let allPlayers: [Player] = [.cross, .nought]

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


    var canPlay = true
    var gameState: GameState {
        didSet {
            delegate?.stateChanged(game: self)
        }
    }
    var currentPlayer: Player
    var delegate: GameDelegate?

    lazy var winingPositions: [[CellPosition]] = {
        var positions: [[CellPosition]] = []

        positions.append((0..<3).map {CellPosition(row: $0, column: 0)})
        positions.append((0..<3).map {CellPosition(row: $0, column: 1)})
        positions.append((0..<3).map {CellPosition(row: $0, column: 2)})

        positions.append((0..<3).map {CellPosition(row: 0, column: $0)})
        positions.append((0..<3).map {CellPosition(row: 1, column: $0)})
        positions.append((0..<3).map {CellPosition(row: 2, column: $0)})

        positions.append((0..<3).map {CellPosition(row: $0, column: $0)})

        positions.append((0..<3).map {CellPosition(row: $0, column: (2 - $0))})

        print(positions)
        return positions
    }()

    init() {
        gameState = [:]
        currentPlayer = .cross
        self.reset()
    }

    func reset() {
        for i in 0..<3 {
            for j in 0..<3 {
                gameState[CellPosition(row: i, column: j)] = .free
            }
        }

        currentPlayer = .cross
        canPlay = true
    }

    func makeMove(at position: CellPosition) {
        guard canPlay, gameState[position] == .free else {return}

        gameState[position] = .occupied(currentPlayer)
        currentPlayer = currentPlayer.other
        checkGameFinished()
    }

    func checkGameFinished() {
        for positions in winingPositions {
            let states = positions.map {gameState[$0] ?? .free}
            for player in Player.allPlayers {
                if states.count(state: .occupied(player)) == 3 {
                    delegate?.gameFinished(result: player, positions: positions)
                    canPlay = false
                    return
                }
            }
        }

        if gameState.freeSpaces == 0 {
            delegate?.gameFinished(result: nil, positions: nil)
            canPlay = false
            return
        }
    }
}

extension Dictionary where Value == Game.CellState {
    var freeSpaces: Int {
        return reduce(0) {$0 + ($1.1 == .free ? 1 : 0)}
    }
}

extension Array where Iterator.Element == Game.CellState {
    func count(state: Game.CellState) -> Int {
        return reduce(0) {$0 + ($1 == state ? 1 : 0)}
    }
}
