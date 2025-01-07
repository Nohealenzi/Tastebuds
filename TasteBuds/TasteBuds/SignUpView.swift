//
//  SignUpView.swift
//  TasteBuds
//
//  Created by Iacopo Lenzi on 12/9/24.
//
import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @Binding var isUserLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    private let db = Firestore.firestore()

    var body: some View {
        VStack {
            Image("Tastebuds_IconLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.bottom)
            
            Text("Sign Up")
                .font(.largeTitle)
                .padding(.bottom)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Sign Up") {
                handleSignUp()
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

            Spacer()
        }
        .padding()
        
    }

    private func handleSignUp() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Signup error: \(error.localizedDescription)")
                return
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
    SignUpView(isUserLoggedIn: .constant(false))
}
