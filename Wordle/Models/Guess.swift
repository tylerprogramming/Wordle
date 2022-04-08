//
//  Guess.swift
//  Wordle
//
//  Created by Tyler Reed on 2022-04-05.
//

import SwiftUI

struct Guess {
    let index: Int
    var word = "     "
    var bgColors = [Color](repeating: .wrong, count: 5)
    var cardFlipped = [Bool](repeating: false, count: 5)
    var guessLetters: [String] {
        word.map { String($0) }
    }
    
    // computed property
    var results: String {
        let tryColors: [Color : String] = [.misplaced : "🟨", .correct : "🟩", .wrong : "⬛"]
        
        // map colors from bgColors to the tryColors here and join them together as a String
        return bgColors.compactMap {tryColors[$0]}.joined(separator: "")
    }
}
