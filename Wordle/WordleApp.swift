//
//  WordleApp.swift
//  Wordle
//
//  Created by Tyler Reed on 2022-04-05.
//

import SwiftUI
import Firebase

@main
struct WordleApp: App {
    @StateObject var dm = WordleDataModel()
    @StateObject var csManager = ColorSchemeManager()
    @StateObject var dataManager = DataManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(dm)
                .environmentObject(csManager)
//                .environmentObject(dataManager)
                .onAppear {
                    csManager.applyColorScheme()
                }
        }
    }
}
