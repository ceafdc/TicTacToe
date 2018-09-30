//
//  ViewController.swift
//  TicTacToe
//
//  Created by Gonzo Fialho on 30/09/18.
//  Copyright © 2018 Gonzo Fialho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let game = Game()
    @IBOutlet weak var gameView: GameView!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        game.gameState[Game.CellPosition(row: 0, column: 0)] = .occupied(.cross)
        game.gameState[Game.CellPosition(row: 1, column: 2)] = .occupied(.nought)

        gameView.gameState = game.gameState
        gameView.positionTouchedAction = positionTouched(_:)
    }

    func positionTouched(_ position: Game.CellPosition)  {
        print(position)
    }
}

