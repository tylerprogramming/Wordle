//
//  WordleDataModel.swift
//  Wordle
//
//  Created by Tyler Reed on 2022-04-05.
//

import SwiftUI
import Firebase

// currentWord is the word for the game to guess
// tryindex is the current row we are trying on, so we start on row 0
// inPlay determines when a player can press enter and backspace, don't want to press enter on fewer than 5 letters or backspace on empty row and error out
class WordleDataModel: ObservableObject {
    @Published var guesses: [Guess] = []
    @Published var incorrectAttempts = [Int](repeating: 0, count: 6)
    @Published var toastText: String?
    @Published var showStats: Bool = false

    @AppStorage("hardMode") var hardMode = false
    
    @Published var player: Player
    @Published var allPlayers: [Player] = []
    
    var keyColors = [String : Color]()
    var matchedLetters = [String]()
    var misplacedLetters = [String]()
    var correctlyPlacedLetters = [String]()
    var selectedWord = ""
    var currentWord = ""
    var tryIndex = 0
    var inPlay = false
    var gameOver = false
    var toastWords = ["Genius", "Magnificent", "Impressive", "Splendid", "Great", "Phew."]
    var currentStat: Statistic
    
    var gameStarted: Bool {
        !currentWord.isEmpty || tryIndex > 0
    }
    
    var disabledKeys: Bool {
        !inPlay || currentWord.count == 5
    }
    
    init() {
        currentStat = Statistic.loadStat()
        player = Player(playerName: "", email: "", userId: "", numberOfGames: 0, numberOfWins: 0, maxStreak: 0, currentStreak: 0)
        fetchPlayerInfo()
        fetchPlayers()
        newGame()
    }
    
    // MARK: - Setup
    func newGame() {
        populateDefaults()
        selectedWord = Global.commonWords.randomElement()!
        correctlyPlacedLetters = [String](repeating: "-", count: 5)
        currentWord = ""
        inPlay = true
        tryIndex = 0
        gameOver = false
        print(selectedWord)
    }
    
    func populateDefaults() {
        guesses = []
        for index in 0...5 {
            guesses.append(Guess(index: index))
        }
        // reset keyboard colors
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for char in letters {
            keyColors[String(char)] = .unused
        }
        matchedLetters = []
        misplacedLetters = []
    }
    
    // MARK: - Game Play
    func addToCurrentWord(_ letter: String) {
        currentWord += letter
        updateRow()
    }
    
    func enterWord() {
        if currentWord == selectedWord {
            gameOver = true
            print("You Win!")
            setCurrentGuessColors()
            currentStat.update(win: true, index: tryIndex)
            player.numberOfWins += 1
            player.numberOfGames += 1
            player.currentStreak = player.currentStreak + 1
            player.maxStreak = max(player.currentStreak, player.maxStreak)
            savePlayerInfo()
            fetchPlayers()
            showToast(with: toastWords[tryIndex])
            inPlay = false
        } else if verifyWord() {
            if hardMode {
                if let toastString = hardCorrectCheck() {
                    showToast(with: toastString)
                    return
                }
                if let toastString = hardMisplacedCheck() {
                    showToast(with: toastString)
                    return
                }
            }
            setCurrentGuessColors()
            tryIndex += 1
            currentWord = ""
            
            if tryIndex == 6 {
                currentStat.update(win: false)
                player.currentStreak = 0
                player.numberOfGames += 1
                gameOver = true
                inPlay = false
                showToast(with: selectedWord)
                savePlayerInfo()
                fetchPlayers()
            }
        } else {
            withAnimation {
                self.incorrectAttempts[tryIndex] += 1
            }
            showToast(with: "Not in Word List.")
            incorrectAttempts[tryIndex] = 0
        }
    }
    
    func removeLetterFromCurrentWord() {
        currentWord.removeLast()
        updateRow()
    }
    
    func updateRow() {
        let guessWord = currentWord.padding(toLength: 5, withPad: " ", startingAt: 0)
        guesses[tryIndex].word = guessWord
    }
    
    func verifyWord() -> Bool {
        UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: currentWord)
    }
    
    func hardCorrectCheck() -> String? {
        let guessLetters = guesses[tryIndex].guessLetters
        for i in 0...4 {
            if correctlyPlacedLetters[i] != "-" {
                if guessLetters[i] != correctlyPlacedLetters[i] {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .ordinal
                    
                    return "\(formatter.string(for: i + 1)!) letter must be `\(correctlyPlacedLetters[i])`."
                }
            }
        }
        
        return nil
    }
    
    func hardMisplacedCheck() -> String? {
        let guessLetters = guesses[tryIndex].guessLetters
        
        for letter in misplacedLetters {
            if !guessLetters.contains(letter) {
                return ("Must contain the letter `\(letter)`.")
            }
        }
        
        return nil
    }
    
    func setCurrentGuessColors() {
        let correctLetters = selectedWord.map { String($0) }
        var frequency = [String : Int]()
    
        for letter in correctLetters {
            frequency[letter, default: 0] += 1
        }
    
        // for finding correct letters or matching letters
        for index in 0...4 {
            let correctLetter = correctLetters[index]
            let guessLetter = guesses[tryIndex].guessLetters[index]
            if guessLetter == correctLetter {
                guesses[tryIndex].bgColors[index] = .correct
                
                if !matchedLetters.contains(guessLetter) {
                    matchedLetters.append(guessLetter)
                    keyColors[guessLetter] = .correct
                }
                
                if misplacedLetters.contains(guessLetter) {
                    if let index = misplacedLetters.firstIndex(where: {$0 == guessLetter}) {
                        misplacedLetters.remove(at: index)
                    }
                }
                
                correctlyPlacedLetters[index] = correctLetter
                frequency[guessLetter]! -= 1
            }
        }
        
        for index in 0...4 {
            let guessLetter = guesses[tryIndex].guessLetters[index]
            
            if correctLetters.contains(guessLetter)
                && guesses[tryIndex].bgColors[index] != .correct
                && frequency[guessLetter]! > 0 {
                guesses[tryIndex].bgColors[index] = .misplaced
                
                if !misplacedLetters.contains(guessLetter) && !matchedLetters.contains(guessLetter) {
                    misplacedLetters.append(guessLetter)
                    keyColors[guessLetter] = .misplaced
                }
                frequency[guessLetter]! -= 1
            }
        }
        
        for index in 0...4 {
            let guessLetter = guesses[tryIndex].guessLetters[index]
            if keyColors[guessLetter] != .correct
                && keyColors[guessLetter] != .misplaced {
                keyColors[guessLetter] = .wrong
            }
        }
        
        flipCards(for: tryIndex)
    }
    
    func flipCards(for row: Int) {
        for col in 0...4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(col) * 0.2) {
                self.guesses[row].cardFlipped[col].toggle()
            }
        }
    }
    
    func showToast(with text: String?) {
        withAnimation {
            toastText = text
        }
        
        withAnimation(Animation.linear(duration: 0.2).delay(3)) {
            toastText = nil
            
            if gameOver {
                withAnimation(Animation.linear(duration: 0.2).delay(3)) {
                    showStats.toggle()
                }
            }
        }
    }
    
    func shareResult() {
        let stat = Statistic.loadStat()
        let resultString = """
        Wordle \(stat.games) \(tryIndex < 6 ? "\(tryIndex + 1)/6" : "")
        \(guesses.compactMap{$0.results}.joined(separator: "\n"))
        """
        
        let activityController = UIActivityViewController(activityItems: [resultString], applicationActivities: nil)
        
        switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                UIWindow.key?.rootViewController!
                    .present(activityController, animated: true)
            case .pad:
                activityController.popoverPresentationController?.sourceView = UIWindow.key
                activityController.popoverPresentationController?.sourceRect = CGRect(x: Global.screenWidth / 2,
                                                                                      y: Global.screenHeight / 2,
                                                                                      width: 200,
                                                                                      height: 200)
                UIWindow.key?.rootViewController!.present(activityController, animated: true)
            
        default:
            break
        }
    }
    
    func savePlayerInfo() {
        let userId = Auth.auth().currentUser?.uid
        
        let db = Firestore.firestore()
        let ref = db.collection("Players").document("\(userId ?? "")")
        ref.updateData(
            [
                "numberOfWins": player.numberOfWins,
                "numberOfGames": player.numberOfGames,
                "maxStreak": player.maxStreak,
                "currentStreak": player.currentStreak
            ]
            ) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
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
                }
            }
        }
    }
    
    func fetchPlayers() {
        allPlayers.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Players")
            .order(by: "numberOfGames", descending: true)

        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }

            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let name = data["playerName"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let id = data["userId"] as? String ?? ""
                    let games = data["numberOfGames"] as? Int ?? 0
                    let wins = data["numberOfWins"] as? Int ?? 0
                    let maxStreak = data["maxStreak"] as? Int ?? 0
                    let currentStreak = data["currentStreak"] as? Int ?? 0

                    let player = Player(playerName: name, email: email, userId: id, numberOfGames: games, numberOfWins: wins, maxStreak: maxStreak, currentStreak: currentStreak)
                    self.allPlayers.append(player)
                }
            }
        }
    }
}
