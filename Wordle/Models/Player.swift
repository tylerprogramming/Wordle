//
//  Player.swift
//  Wordle
//
//  Created by Tyler Reed on 4/8/22.
//

import SwiftUI

struct Player: Identifiable {
    var id = UUID()
    var playerName: String
    var email: String
    var userId: String
    var numberOfGames: Int
    var numberOfWins: Int
    var maxStreak: Int
    var currentStreak: Int
}

