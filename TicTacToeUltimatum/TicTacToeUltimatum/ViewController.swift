//
//  ViewController.swift
//  TicTacToeUltimatum
//
//  Created by Maksim Khrapov on 5/16/19.
//  Copyright © 2019 Maksim Khrapov. 
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit


func calcHorizontalOffset() -> CGFloat {
    if UIScreen.main.bounds.size.width > 414.0 {
        return (UIScreen.main.bounds.size.width - 394.0) / 2.0
    }
    else {
        return 10.0
    }
}


class ViewController: UIViewController {

    var boardView: BoardView?
    var boardStateHistory: [BoardState] = []
    let gameStyleKey = "gameStyleKey"
    var currentGameStyle = 0
    var freezeUI = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.title = "Play"
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        let boardState = BoardState()
        boardStateHistory.append(boardState)
        
        let hOffset: CGFloat = calcHorizontalOffset()
        let vOffset: CGFloat = UIApplication.shared.statusBarFrame.size.height + self.navigationController!.navigationBar.frame.height + 5
        
        let boardSize = UIScreen.main.bounds.size.width - 2.0 * hOffset
        let frame = CGRect(x: hOffset, y: vOffset, width: boardSize, height: boardSize)
        boardView = BoardView(frame: frame)
        boardView!.setBoardState(boardState)
        boardView!.hOffset = hOffset
        boardView!.vOffset = vOffset
        view.addSubview(boardView!)
        
        currentGameStyle = UserDefaults.standard.integer(forKey: gameStyleKey)
        if currentGameStyle == 1 { // AI makes first move
            let ai = AI(boardState)
            let (x, y) = ai.respondFast()
            if boardState.legalPlay(x, y) {
                let nextBoardState = boardState.clone()
                boardStateHistory.append(nextBoardState)
                if nextBoardState.set(x, y) {
                    boardView!.setBoardState(nextBoardState)
                    boardView!.setNeedsDisplay()
                }
            }
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // if the game has not started yet and settings have changed
        // restart the game under new settings
        let checkGameStyle = UserDefaults.standard.integer(forKey: gameStyleKey)
        if checkGameStyle != currentGameStyle && boardStateHistory.count == 1 {
            setupNewGame()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if freezeUI {
            return
        }
        
        guard let touch = touches.first, let boardView = boardView,
            let boardState = boardStateHistory.last else {
                return
        }
        
        let loc = touch.location(in: boardView)
        
        // verify the touch was in desired location
        if loc.x < 0 || loc.y < 0 || loc.x > boardView.frame.width || loc.y > boardView.frame.height {
            return
        }
        
        // convert to game cell coordinates
        let cellSize = boardView.frame.width/9.0
        let x = Int(floor(loc.x / cellSize))
        let y = Int(floor(loc.y / cellSize))
        
        if boardState.legalPlay(x, y) {
            let nextBoardState = boardState.clone()
            boardStateHistory.append(nextBoardState)
            if nextBoardState.set(x, y) {
                boardView.setBoardState(nextBoardState)
                boardView.setNeedsDisplay()
                
                if !nextBoardState.isTerminal() && currentGameStyle != 0 {
                    // playing with AI, so AI should make a move
                    freezeUIandShowOverlay()
                    DispatchQueue.main.async(execute: {
                        let ai = AI(nextBoardState)
                        let (x, y) = ai.respond()
                        if nextBoardState.legalPlay(x, y) {
                            let nextBoardState2 = nextBoardState.clone()
                            self.boardStateHistory.append(nextBoardState2)
                            if nextBoardState2.set(x, y) {
                                boardView.setBoardState(nextBoardState2)
                                self.unfreezeUIandDismissOverlay()
                                boardView.setNeedsDisplay()
                            }
                        }
                        else {
                            // unfreeze UI anyway
                            self.unfreezeUIandDismissOverlay()
                            boardView.setNeedsDisplay()
                        }
                    })
                }
            }
        }
    }
    
    
    func setupNewGame() {
        if freezeUI {
            return
        }
        currentGameStyle = UserDefaults.standard.integer(forKey: gameStyleKey)
        boardStateHistory.removeAll()
        let boardState = BoardState()
        boardStateHistory.append(boardState)
        boardView!.setBoardState(boardState)
        
        if currentGameStyle == 1 { // AI makes first move
            let ai = AI(boardState)
            let (x, y) = ai.respondFast()
            if boardState.legalPlay(x, y) {
                let nextBoardState = boardState.clone()
                boardStateHistory.append(nextBoardState)
                if nextBoardState.set(x, y) {
                    boardView!.setBoardState(nextBoardState)
                    boardView!.setNeedsDisplay()
                }
            }
        }
    }
    
    
    func freezeUIandShowOverlay() {
        freezeUI = true
        boardView!.displayIndicator(true)
    }
    
    
    func unfreezeUIandDismissOverlay() {
        freezeUI = false
        boardView!.displayIndicator(false)
    }
    
    
    @IBAction func newGame(_ sender: Any) {
        let alert = UIAlertController(title: "Abandon Game ?", message: "Would you like to abandon the current game?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .default, handler: { _ in
            self.setupNewGame()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .default, handler: { _ in
            // do nothing
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func undo(_ sender: Any) {
        if freezeUI {
            return
        }
        
        var undoCount = 0
        
        if currentGameStyle == 0 {
            // 2 humans playing
            if boardStateHistory.count > 1 {
                undoCount = 1
            }
        }
        else if currentGameStyle == 1 {
            // AI plays Crosses (first)
            if boardStateHistory.count > 2 {
                let gameWon = boardStateHistory.last!.gameWon
                let nextPlayer = boardStateHistory.last!.player
                
                // if the game is over, undo only one move if the last player was human
                
                if gameWon == OPEN {
                    undoCount = 2
                }
                else if nextPlayer == CROS {  // AI
                    undoCount = 1
                }
                else if nextPlayer == NOUG {
                    undoCount = 2
                }
            }
        }
        else if currentGameStyle == 2 {
            // AI plays Noughts (second)
            if boardStateHistory.count > 1 {
                let gameWon = boardStateHistory.last!.gameWon
                let nextPlayer = boardStateHistory.last!.player
                
                // if the game is over, undo only one move if the last player was human
                
                if gameWon == OPEN {
                    undoCount = 2
                }
                else if nextPlayer == NOUG {  // AI
                    undoCount = 1
                }
                else if nextPlayer == CROS {
                    undoCount = 2
                }
            }
        }
        
        // perform undo action
        if undoCount == 2 {
            boardStateHistory.removeLast()
            boardStateHistory.removeLast()
            boardView!.setBoardState(boardStateHistory.last!)
            boardView!.setNeedsDisplay()
        }
        else if undoCount == 1 {
            boardStateHistory.removeLast()
            boardView!.setBoardState(boardStateHistory.last!)
            boardView!.setNeedsDisplay()
        }
        // otherwise do nothing
    }
}

