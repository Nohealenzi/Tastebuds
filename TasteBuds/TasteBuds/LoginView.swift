//
//  LoginView.swift
//  TasteBuds
//
//  Created by Iacopo Lenzi on 12/9/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @Binding var isUserLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isNavigatingToSignUp = false
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            Image("TasteBuds_fullLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.bottom)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Login") {
                handleLogin()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.primaryGreen)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button("Don’t have an account? Sign Up") {
                isNavigatingToSignUp = true
            }
            .padding()

            Spacer()

            NavigationLink(destination: SignUpView(isUserLoggedIn: $isUserLoggedIn), isActive: $isNavigatingToSignUp) {
                EmptyView()
            }
        }
        .padding()
    }

    private func handleLogin() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                return
            } else {
                isUserLoggedIn = true
            }
            if let user = authResult?.user {
                createUserDocumentIfNeeded(for: user)
            }
        }
    }
    
    private func createUserDocumentIfNeeded(for user: User) {
        let userDoc = db.collection("Users").document(user.uid)
        
        userDoc.getDocument { snapshot, error in
            if let error = error {
                print("Error checking user document: \(error.localizedDescription)")
                return
            }
            
            if !(snapshot?.exists ?? false) {
                userDoc.setData(["favorites": []]) { error in
                    if let error = error {
                        print("Error creating user document: \(error.localizedDescription)")
                    } else {
                        print("User document created successfully.")
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView(isUserLoggedIn: .constant(false))
}
