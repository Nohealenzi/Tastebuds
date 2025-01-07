//
//  ContentView.swift
//  TasteBuds
//
//  Created by Iacopo Lenzi on 12/9/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isUserLoggedIn = Auth.auth().currentUser != nil

    var body: some View {
        NavigationView {
            if isUserLoggedIn {
                HomeView(isUserLoggedIn: $isUserLoggedIn)
            } else {
                LoginView(isUserLoggedIn: $isUserLoggedIn)
            }
        }
        .onAppear {
            // Listen to authentication state changes
            Auth.auth().addStateDidChangeListener { _, user in
                isUserLoggedIn = (user != nil)
            }
        }
    }
}

#Preview {
    ContentView()
}
