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


    var aiEnabled = false
    var canPlay = true
    var gameState: GameState {
        didSet {
            delegate?.stateChanged(game: self)
        }
    }
    var currentPlayer: Player
    var delegate: GameDelegate?

    static var winingPositions: [[CellPosition]] = {
        var positions: [[CellPosition]] = []

        positions.append((0..<3).map {CellPosition(row: $0, column: 0)})
        positions.append((0..<3).map {CellPosition(row: $0, column: 1)})
        positions.append((0..<3).map {CellPosition(row: $0, column: 2)})

        positions.append((0..<3).map {CellPosition(row: 0, column: $0)})
        positions.append((0..<3).map {CellPosition(row: 1, column: $0)})
        positions.append((0..<3).map {CellPosition(row: 2, column: $0)})

        positions.append((0..<3).map {CellPosition(row: $0, column: $0)})

        positions.append((0..<3).map {CellPosition(row: $0, column: (2 - $0))})

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

    func makeAIMove() {
        guard canPlay, gameState.countFreeSpaces > 0 else {return}
        self.makeMove(at: GameAI.solveGame(state: gameState, for: currentPlayer))
    }

    func makeMove(at position: CellPosition) {
        guard canPlay, gameState[position] == .free else {return}

        gameState[position] = .occupied(currentPlayer)
        currentPlayer = currentPlayer.other
        checkGameFinished()
        if !canPlay {
            return
        }
        if currentPlayer == .nought && aiEnabled {
            self.makeMove(at: GameAI.solveGame(state: gameState, for: currentPlayer))
        }
    }

    func checkGameFinished() {
        let (finished, player, positions) = Game.checkGameFinished(gameState: gameState)
        if finished {
            delegate?.gameFinished(result: player, positions: positions)
            canPlay = false
        }
    }

    static func checkGameFinished(gameState: GameState) -> (Bool, Player?, [CellPosition]?){
        for positions in winingPositions {
            let states = positions.map {gameState[$0] ?? .free}
            for player in Player.allPlayers {
                if states.count(state: .occupied(player)) == 3 {
                    return (true, player, positions)
                }
            }
        }

        if gameState.countFreeSpaces == 0 {
            return (true, nil, nil)
        }

        return (false, nil, nil)
    }
}

extension Dictionary where Key == Game.CellPosition, Value == Game.CellState {
    var countFreeSpaces: Int {
        return reduce(0) {$0 + ($1.1 == .free ? 1 : 0)}
    }

    var freeSpaces: [Game.CellPosition] {
        return (filter {$0.value == .free}).map {$0.0}
    }
}

extension Array where Iterator.Element == Game.CellState {
    func count(state: Game.CellState) -> Int {
        return reduce(0) {$0 + ($1 == state ? 1 : 0)}
    }
}
