//
//  MonteCarloTreeSearch.swift
//  TicTacToeUltimatum
//
//  Created by Maksim Khrapov on 5/18/19.
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


import Foundation


final class MonteCarloTreeSearch {
    let boardState: BoardState
    
    
    init(_ boardState: BoardState) {
        self.boardState = boardState
    }
    
    
    func basic(_ iterCount: Int) -> (Int, Int) {
        let moves = boardState.allLegalMoves()
        let whoami = boardState.player
        var counts: [Double] = Array(repeating: 0.0, count: moves.count)
        
        for _ in 0..<iterCount {  // was c
            for i in 0..<counts.count {
                let (x, y) = moves[i]
                let child = boardState.clone()
                _ = child.set(x, y)
                let res = playout(child)
                if res == whoami {
                    counts[i] += 1.0
                }
                else if res == DONE {
                    counts[i] += 0.05  // What would a good value be?
                }
            }
            
            /*
            print(c)
            if c % 100 == 0 {
                prettyPrint(counts)
            }
 */
        }
        
        let maxCount = counts.max()!
        let maxIndex = counts.firstIndex(of: maxCount)!
        
        //prettyPrint(counts)
        
        return moves[maxIndex]
    }
    
    
    func playout(_ state: BoardState) -> Int {
        while !state.isTerminal() {
            let moves = state.allLegalMoves()
            if moves.count == 0 {
                break
            }
            let index = Int.random(in: 0..<moves.count)
            let (x, y) = moves[index]
            _ = state.set(x, y)
        }
        
        return state.gameWon
    }
    
    
    func prettyPrint(_ counts: [Double]) {
        for y in 0..<9 {
            for x in 0..<9 {
                let i = y*9 + x
                print(String(format: " %7.1f", counts[i]), terminator: "")
            }
            print()
        }
    }
    
    
    /*
    func bridge_to_c(_ iterCount: Int) -> (Int, Int) {
        let bs_p = UnsafeMutablePointer<board_state>.allocate(capacity: 1)
        
        let bs_int32 = BoardStateInt32(boardState)
        
        bs_p.pointee.player = bs_int32.player
        bs_p.pointee.gameWon = bs_int32.gameWon
        
        bs_p.pointee.sectionWon = (
            bs_int32.sectionWon[0],
            bs_int32.sectionWon[1],
            bs_int32.sectionWon[2],
            bs_int32.sectionWon[3],
            bs_int32.sectionWon[4],
            bs_int32.sectionWon[5],
            bs_int32.sectionWon[6],
            bs_int32.sectionWon[7],
            bs_int32.sectionWon[8]
        )
        
        bs_p.pointee.sectionAllowed = (
            bs_int32.sectionAllowed[0],
            bs_int32.sectionAllowed[1],
            bs_int32.sectionAllowed[2],
            bs_int32.sectionAllowed[3],
            bs_int32.sectionAllowed[4],
            bs_int32.sectionAllowed[5],
            bs_int32.sectionAllowed[6],
            bs_int32.sectionAllowed[7],
            bs_int32.sectionAllowed[8]
        )
        
        bs_p.pointee.sectionNextValue = (
            bs_int32.sectionNextValue[0],
            bs_int32.sectionNextValue[1],
            bs_int32.sectionNextValue[2],
            bs_int32.sectionNextValue[3],
            bs_int32.sectionNextValue[4],
            bs_int32.sectionNextValue[5],
            bs_int32.sectionNextValue[6],
            bs_int32.sectionNextValue[7],
            bs_int32.sectionNextValue[8]
        )
        
        
        bs_p.pointee.cellValue = (
            bs_int32.cellValue[0],
            bs_int32.cellValue[1],
            bs_int32.cellValue[2],
            bs_int32.cellValue[3],
            bs_int32.cellValue[4],
            bs_int32.cellValue[5],
            bs_int32.cellValue[6],
            bs_int32.cellValue[7],
            bs_int32.cellValue[8],
            bs_int32.cellValue[9],
            bs_int32.cellValue[10],
            bs_int32.cellValue[11],
            bs_int32.cellValue[12],
            bs_int32.cellValue[13],
            bs_int32.cellValue[14],
            bs_int32.cellValue[15],
            bs_int32.cellValue[16],
            bs_int32.cellValue[17],
            bs_int32.cellValue[18],
            bs_int32.cellValue[19],
            bs_int32.cellValue[20],
            bs_int32.cellValue[21],
            bs_int32.cellValue[22],
            bs_int32.cellValue[23],
            bs_int32.cellValue[24],
            bs_int32.cellValue[25],
            bs_int32.cellValue[26],
            bs_int32.cellValue[27],
            bs_int32.cellValue[28],
            bs_int32.cellValue[29],
            bs_int32.cellValue[30],
            bs_int32.cellValue[31],
            bs_int32.cellValue[32],
            bs_int32.cellValue[33],
            bs_int32.cellValue[34],
            bs_int32.cellValue[35],
            bs_int32.cellValue[36],
            bs_int32.cellValue[37],
            bs_int32.cellValue[38],
            bs_int32.cellValue[39],
            bs_int32.cellValue[40],
            bs_int32.cellValue[41],
            bs_int32.cellValue[42],
            bs_int32.cellValue[43],
            bs_int32.cellValue[44],
            bs_int32.cellValue[45],
            bs_int32.cellValue[46],
            bs_int32.cellValue[47],
            bs_int32.cellValue[48],
            bs_int32.cellValue[49],
            bs_int32.cellValue[50],
            bs_int32.cellValue[51],
            bs_int32.cellValue[52],
            bs_int32.cellValue[53],
            bs_int32.cellValue[54],
            bs_int32.cellValue[55],
            bs_int32.cellValue[56],
            bs_int32.cellValue[57],
            bs_int32.cellValue[58],
            bs_int32.cellValue[59],
            bs_int32.cellValue[60],
            bs_int32.cellValue[61],
            bs_int32.cellValue[62],
            bs_int32.cellValue[63],
            bs_int32.cellValue[64],
            bs_int32.cellValue[65],
            bs_int32.cellValue[66],
            bs_int32.cellValue[67],
            bs_int32.cellValue[68],
            bs_int32.cellValue[69],
            bs_int32.cellValue[70],
            bs_int32.cellValue[71],
            bs_int32.cellValue[72],
            bs_int32.cellValue[73],
            bs_int32.cellValue[74],
            bs_int32.cellValue[75],
            bs_int32.cellValue[76],
            bs_int32.cellValue[77],
            bs_int32.cellValue[78],
            bs_int32.cellValue[79],
            bs_int32.cellValue[80]
        )
        
        bs_p.pointee.cellAllowed = (
            bs_int32.cellAllowed[0],
            bs_int32.cellAllowed[1],
            bs_int32.cellAllowed[2],
            bs_int32.cellAllowed[3],
            bs_int32.cellAllowed[4],
            bs_int32.cellAllowed[5],
            bs_int32.cellAllowed[6],
            bs_int32.cellAllowed[7],
            bs_int32.cellAllowed[8],
            bs_int32.cellAllowed[9],
            bs_int32.cellAllowed[10],
            bs_int32.cellAllowed[11],
            bs_int32.cellAllowed[12],
            bs_int32.cellAllowed[13],
            bs_int32.cellAllowed[14],
            bs_int32.cellAllowed[15],
            bs_int32.cellAllowed[16],
            bs_int32.cellAllowed[17],
            bs_int32.cellAllowed[18],
            bs_int32.cellAllowed[19],
            bs_int32.cellAllowed[20],
            bs_int32.cellAllowed[21],
            bs_int32.cellAllowed[22],
            bs_int32.cellAllowed[23],
            bs_int32.cellAllowed[24],
            bs_int32.cellAllowed[25],
            bs_int32.cellAllowed[26],
            bs_int32.cellAllowed[27],
            bs_int32.cellAllowed[28],
            bs_int32.cellAllowed[29],
            bs_int32.cellAllowed[30],
            bs_int32.cellAllowed[31],
            bs_int32.cellAllowed[32],
            bs_int32.cellAllowed[33],
            bs_int32.cellAllowed[34],
            bs_int32.cellAllowed[35],
            bs_int32.cellAllowed[36],
            bs_int32.cellAllowed[37],
            bs_int32.cellAllowed[38],
            bs_int32.cellAllowed[39],
            bs_int32.cellAllowed[40],
            bs_int32.cellAllowed[41],
            bs_int32.cellAllowed[42],
            bs_int32.cellAllowed[43],
            bs_int32.cellAllowed[44],
            bs_int32.cellAllowed[45],
            bs_int32.cellAllowed[46],
            bs_int32.cellAllowed[47],
            bs_int32.cellAllowed[48],
            bs_int32.cellAllowed[49],
            bs_int32.cellAllowed[50],
            bs_int32.cellAllowed[51],
            bs_int32.cellAllowed[52],
            bs_int32.cellAllowed[53],
            bs_int32.cellAllowed[54],
            bs_int32.cellAllowed[55],
            bs_int32.cellAllowed[56],
            bs_int32.cellAllowed[57],
            bs_int32.cellAllowed[58],
            bs_int32.cellAllowed[59],
            bs_int32.cellAllowed[60],
            bs_int32.cellAllowed[61],
            bs_int32.cellAllowed[62],
            bs_int32.cellAllowed[63],
            bs_int32.cellAllowed[64],
            bs_int32.cellAllowed[65],
            bs_int32.cellAllowed[66],
            bs_int32.cellAllowed[67],
            bs_int32.cellAllowed[68],
            bs_int32.cellAllowed[69],
            bs_int32.cellAllowed[70],
            bs_int32.cellAllowed[71],
            bs_int32.cellAllowed[72],
            bs_int32.cellAllowed[73],
            bs_int32.cellAllowed[74],
            bs_int32.cellAllowed[75],
            bs_int32.cellAllowed[76],
            bs_int32.cellAllowed[77],
            bs_int32.cellAllowed[78],
            bs_int32.cellAllowed[79],
            bs_int32.cellAllowed[80]
        )
        
        bs_p.pointee.cellOccupied = (
            bs_int32.cellOccupied[0],
            bs_int32.cellOccupied[1],
            bs_int32.cellOccupied[2],
            bs_int32.cellOccupied[3],
            bs_int32.cellOccupied[4],
            bs_int32.cellOccupied[5],
            bs_int32.cellOccupied[6],
            bs_int32.cellOccupied[7],
            bs_int32.cellOccupied[8],
            bs_int32.cellOccupied[9],
            bs_int32.cellOccupied[10],
            bs_int32.cellOccupied[11],
            bs_int32.cellOccupied[12],
            bs_int32.cellOccupied[13],
            bs_int32.cellOccupied[14],
            bs_int32.cellOccupied[15],
            bs_int32.cellOccupied[16],
            bs_int32.cellOccupied[17],
            bs_int32.cellOccupied[18],
            bs_int32.cellOccupied[19],
            bs_int32.cellOccupied[20],
            bs_int32.cellOccupied[21],
            bs_int32.cellOccupied[22],
            bs_int32.cellOccupied[23],
            bs_int32.cellOccupied[24],
            bs_int32.cellOccupied[25],
            bs_int32.cellOccupied[26],
            bs_int32.cellOccupied[27],
            bs_int32.cellOccupied[28],
            bs_int32.cellOccupied[29],
            bs_int32.cellOccupied[30],
            bs_int32.cellOccupied[31],
            bs_int32.cellOccupied[32],
            bs_int32.cellOccupied[33],
            bs_int32.cellOccupied[34],
            bs_int32.cellOccupied[35],
            bs_int32.cellOccupied[36],
            bs_int32.cellOccupied[37],
            bs_int32.cellOccupied[38],
            bs_int32.cellOccupied[39],
            bs_int32.cellOccupied[40],
            bs_int32.cellOccupied[41],
            bs_int32.cellOccupied[42],
            bs_int32.cellOccupied[43],
            bs_int32.cellOccupied[44],
            bs_int32.cellOccupied[45],
            bs_int32.cellOccupied[46],
            bs_int32.cellOccupied[47],
            bs_int32.cellOccupied[48],
            bs_int32.cellOccupied[49],
            bs_int32.cellOccupied[50],
            bs_int32.cellOccupied[51],
            bs_int32.cellOccupied[52],
            bs_int32.cellOccupied[53],
            bs_int32.cellOccupied[54],
            bs_int32.cellOccupied[55],
            bs_int32.cellOccupied[56],
            bs_int32.cellOccupied[57],
            bs_int32.cellOccupied[58],
            bs_int32.cellOccupied[59],
            bs_int32.cellOccupied[60],
            bs_int32.cellOccupied[61],
            bs_int32.cellOccupied[62],
            bs_int32.cellOccupied[63],
            bs_int32.cellOccupied[64],
            bs_int32.cellOccupied[65],
            bs_int32.cellOccupied[66],
            bs_int32.cellOccupied[67],
            bs_int32.cellOccupied[68],
            bs_int32.cellOccupied[69],
            bs_int32.cellOccupied[70],
            bs_int32.cellOccupied[71],
            bs_int32.cellOccupied[72],
            bs_int32.cellOccupied[73],
            bs_int32.cellOccupied[74],
            bs_int32.cellOccupied[75],
            bs_int32.cellOccupied[76],
            bs_int32.cellOccupied[77],
            bs_int32.cellOccupied[78],
            bs_int32.cellOccupied[79],
            bs_int32.cellOccupied[80]
        )
        
        let res = monte_carlo_tree_search(Int32(iterCount), bs_p)
        bs_p.deallocate()
        
        let x: Int = Int(res) % 9
        let y: Int = Int(res) / 9
        return (x, y)
    }
 
 */
    
}
