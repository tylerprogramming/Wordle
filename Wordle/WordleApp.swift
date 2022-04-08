//
//  WordleApp.swift
//  Wordle
//
//  Created by Tyler Reed on 2022-04-05.
//

import SwiftUI

@main
struct WordleApp: App {
    @StateObject var dm = WordleDataModel()
    
    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(dm)
        }
    }
}
