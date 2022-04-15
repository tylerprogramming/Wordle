//
//  DataManager.swift
//  Wordle
//
//  Created by Tyler Reed on 4/8/22.
//

import SwiftUI
import Firebase

class DataManager: ObservableObject {
    @Published var player: Player
    
    init() {
        player = Player(playerName: "", email: "", userId: "", numberOfGames: 0, numberOfWins: 0, maxStreak: 0, currentStreak: 0)
        fetchPlayerInfo()
    }
    
    func fetchPlayerInfo() {
        let userId = Auth.auth().currentUser?.uid
        
        if userId != nil {
        
            let db = Firestore.firestore()
            let ref = db.collection("Players").document("\(userId ?? "")")
            ref.getDocument { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                if let snapshot = snapshot {
                    let data = snapshot.data()
                    let name = data?["playerName"] as? String ?? ""
                    let email = data?["email"] as? String ?? ""
                    let id = data?["userId"] as? String ?? ""
                    let games = data?["numberOfGames"] as? Int ?? 0
                    let wins = data?["numberOfWins"] as? Int ?? 0
                    let maxStreak = data?["maxStreak"] as? Int ?? 0
                    let currentStreak = data?["currentStreak"] as? Int ?? 0
                    
                    self.player = Player(playerName: name, email: email, userId: id, numberOfGames: games, numberOfWins: wins, maxStreak: maxStreak, currentStreak: currentStreak)
                    print("HI")
                    print(self.player)
                }
            }
        }
    }
}
