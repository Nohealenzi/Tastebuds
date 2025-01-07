//
//  UserProfileView.swift
//  TasteBuds
//
//  Created by Iacopo Lenzi on 12/10/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct UserProfileView: View {
    @Binding var isUserLoggedIn: Bool
    @State private var favorites: [Recipe] = []
    @State private var isLoading = true
    private let db = Firestore.firestore()

    var body: some View {
        VStack {
            Text("Your Profile")
                .font(.largeTitle)
                .padding()

            Text("Iacopo Nohea Lenzi")
                .font(.title)

            Text("Z23444625")
                .font(.title)

                .padding()
            Text("Your Favorites")
                .font(.headline)
                .padding()

            if isLoading {
                CustomLoadingView()
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                        ForEach(favorites) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipeID: recipe.id)) {
                                VStack {
                                    AsyncImage(url: URL(string: recipe.strMealThumb)) { image in
                                        image.resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(height: 120)
                                    .cornerRadius(10)

                                    Text(recipe.strMeal)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 5)
                                }
                                .background(Color.secondaryGreen)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                            }
                        }
                    }
                    .padding()
                }
            }

            Button(action: signOut) {
                Text("Sign Out")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .onAppear {
            fetchFavorites()
        }
    }

    private func fetchFavorites() {
        guard let user = Auth.auth().currentUser else { return }
        let userDoc = db.collection("Users").document(user.uid)

        userDoc.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                isLoading = false
                return
            }

            if let data = snapshot?.data(),
               let favoriteIDs = data["favorites"] as? [String] {
                RecipeService.shared.fetchRecipesByIDs(favoriteIDs) { result in
                    DispatchQueue.main.async {
                        isLoading = false
                        switch result {
                        case .success(let recipes):
                            favorites = recipes
                        case .failure(let error):
                            print("Error fetching favorites: \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                isLoading = false
            }
        }
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
            isUserLoggedIn = false
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

 
#Preview {
    UserProfileView(isUserLoggedIn: .constant(true))
}
