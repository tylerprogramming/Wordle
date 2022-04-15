//
//  LoginView.swift
//  Wordle
//
//  Created by Tyler Reed on 4/8/22.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @EnvironmentObject var dataManager: DataManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var playerName = ""
    @State private var userIsLogginedIn: Bool = false
    
    var body: some View {
        if userIsLogginedIn {
            GameView()
        } else {
            content
        }
    }
    
    var content: some View {
        ZStack {
            Color.yellow
            
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.yellow, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 1000, height: 400)
                .rotationEffect(.degrees(135))
                .offset(y: -350)
            
            VStack {
                Text("Welcome")
                    .foregroundColor(.white)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .offset(x: -100, y: -100)
                
                TextField("Email", text: $email)
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                    .placeholder(when: email.isEmpty) {
                        Text("Email")
                            .foregroundColor(.white)
                            .bold()
                    }
                
                Divider()
                    .background(.white)
                
                SecureField("Password", text: $password)
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                    .placeholder(when: password.isEmpty) {
                        Text("Password")
                            .foregroundColor(.white)
                            .bold()
                    }
                
                Divider()
                    .background(.white)
                
                TextField("Username", text: $playerName)
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                    .placeholder(when: email.isEmpty) {
                        Text("Username")
                            .foregroundColor(.white)
                            .bold()
                    }
                
                Divider()
                    .background(.white)
                
                Button {
                    register()
                } label: {
                    Text("Sign Up")
                        .bold()
                        .frame(width: 200, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.linearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottomTrailing))
                        )
                        .shadow(radius: 5)
                        .foregroundColor(.white)
                }
                .padding(.top)
                .offset(y: 100)
                
                Button {
                    login()
                } label: {
                    Text("Already have an account? Login")
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.top)
                .offset(y: 110)
            }
            .frame(width: 350)
            .onAppear {
                Auth.auth().addStateDidChangeListener { auth, user in
                    if user != nil {
                        userIsLogginedIn.toggle()
                    }
                }
                
            }
        }
        .ignoresSafeArea()
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                createPlayerInfo()
            }
        }
    }
    
    func createPlayerInfo() {
        let db = Firestore.firestore()
        let name = playerName
        let email = Auth.auth().currentUser?.email
        let userId = Auth.auth().currentUser?.uid
        let numberOfWins = 0
        let currentStreak = 0
        let maxStreak = 0
        
        db.collection("Players").document("\(userId!)").setData(
            [
                "playerName": name,
                "email": email,
                "userId": userId!,
                "numberOfWins": numberOfWins,
                "currentStreak": currentStreak,
                "maxStreak": maxStreak
            ]
        )
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
