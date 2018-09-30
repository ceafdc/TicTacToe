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


        game.gameState[Game.CellPosition(row: 0, column: 0)] = .cross
        game.gameState[Game.CellPosition(row: 1, column: 2)] = .nought

        gameView.gameState = game.gameState
    }
}

