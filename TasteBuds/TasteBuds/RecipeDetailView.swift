//
//  RecipeDetailView.swift
//  TasteBuds
//
//  Created by Iacopo Lenzi on 12/9/24.
//
import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct RecipeDetailView: View {
    let recipeID: String
    @State private var recipeDetails: RecipeDetails?
    @State private var isLoading = true
    @State private var isFavorite = false
    private let db = Firestore.firestore()

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("Loading recipe details...")
                    .padding()
            } else if let details = recipeDetails {
                VStack(alignment: .center, spacing: 16) {
                    // Recipe Title
                    Text(details.strMeal)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.primaryGreen)
                        .cornerRadius(10)

                    // Recipe Image
                    AsyncImage(url: URL(string: details.strMealThumb)) { image in
                        image.resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 200)
                    .cornerRadius(15)

                    // Ingredients Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ingredients")
                            .font(.headline)
                            .padding(.top)

                        ForEach(details.ingredients, id: \ .self) { ingredient in
                            Text("• \(ingredient)")
                                .font(.body)
                        }
                    }
                    .padding()
                    .background(Color.secondaryGreen.opacity(0.2))
                    .cornerRadius(10)

                    // Instructions Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions")
                            .font(.headline)
                            .padding(.top)

                        Text(details.strInstructions)
                            .font(.body)
                            .lineSpacing(5)
                    }
                    .padding()
                    .background(Color.secondaryGreen.opacity(0.2))
                    .cornerRadius(10)

                    // Save Button
                    Button(action: toggleFavorite) {
                        HStack {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : .gray)
                                .font(.title2)

                            Text(isFavorite ? "Remove from Favorites" : "Save to Favorites")
                                .foregroundColor(.primaryGreen)
                                .font(.headline)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            } else {
                Text("Failed to load recipe details.")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            fetchRecipeDetails()
            checkIfFavorite()
        }
        .background(Color.primaryGreen.opacity(0.1))
    }

    private func fetchRecipeDetails() {
        RecipeService.shared.fetchRecipeDetails(byID: recipeID) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let details):
                    recipeDetails = details
                case .failure(let error):
                    print("Error fetching recipe details: \(error.localizedDescription)")
                }
            }
        }
    }

    private func toggleFavorite() {
        guard let user = Auth.auth().currentUser else { return }
        let userDoc = db.collection("Users").document(user.uid)

        if isFavorite {
            // Remove from favorites
            userDoc.updateData([
                "favorites": FieldValue.arrayRemove([recipeID])
            ]) { error in
                if let error = error {
                    print("Error removing favorite: \(error.localizedDescription)")
                } else {
                    isFavorite = false
                    print("Recipe removed from favorites.")
                }
            }
        } else {
            // Add to favorites
            userDoc.updateData([
                "favorites": FieldValue.arrayUnion([recipeID])
            ]) { error in
                if let error = error {
                    print("Error adding favorite: \(error.localizedDescription)")
                } else {
                    isFavorite = true
                    print("Recipe added to favorites.")
                }
            }
        }
    }

    private func checkIfFavorite() {
        guard let user = Auth.auth().currentUser else { return }
        let userDoc = db.collection("Users").document(user.uid)

        userDoc.getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let favorites = data["favorites"] as? [String] {
                isFavorite = favorites.contains(recipeID)
            }
        }
    }
}
