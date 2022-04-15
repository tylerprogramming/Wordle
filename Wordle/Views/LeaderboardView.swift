//
//  LeaderboardView.swift
//  Wordle
//
//  Created by Tyler Reed on 4/9/22.
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var dm: WordleDataModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            Text("LEADERBOARD")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .shadow(color: .black.opacity(0.3), radius: 10)
            
            VStack(alignment: .leading, spacing: 5) {
                ForEach(0..<dm.allPlayers.count) { index in
                    HStack {
                        LeaderboardRow(playerName: dm.allPlayers[index].playerName, games: dm.allPlayers[index].numberOfGames, wins: dm.allPlayers[index].numberOfWins, index: index + 1)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("**X**")
                }
            }
        }
        .onAppear {
            print("getting players:")
            print(dm.allPlayers)
        }
    }
}

struct LeaderboardRow: View {
    let playerName: String
    let games: Int
    let wins: Int
    let index: Int
    
    var body: some View {
        HStack {
            Image(systemName: "\(index).square")
                .font(.largeTitle)
                .foregroundColor(getLeaderboardRankColor(for: index))
            Text("\(playerName) - \(wins) wins with \(Int(100 * wins / games))%")
                .font(.title2)
                .foregroundColor(.black)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
    }
    
    func getLeaderboardRankColor(for index: Int) -> Color {
        if index == 1 {
            return .yellow
        } else if index == 2 {
            return .green
        } else if index == 3 {
            return .orange
        } else {
            return .white
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
