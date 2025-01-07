//
//  HomeView.swift
//  TasteBuds
//
//  Created by Iacopo Lenzi on 12/9/24.
import SwiftUI

struct HomeView: View {
    @Binding var isUserLoggedIn: Bool
    @State private var recipes: [Recipe] = []
    @State private var isLoading = true
    @State private var searchQuery = ""

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image("TasteBuds_TextLogo_noBG")
                        .resizable()
                        .scaledToFit()

                    Spacer()

                    HStack {
                        Button(action: {
                                searchRecipes() // Trigger the search functionality
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .scaleEffect(1.2)
                            }
                            TextField("Search ingredients", text: $searchQuery)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(8)
                                .background(Color.grayBackground)
                                .cornerRadius(8)
                    }
                    .frame(width: 200)
                    
                    NavigationLink(destination: UserProfileView(isUserLoggedIn: $isUserLoggedIn)) {
                        Image(systemName: "person.circle")
                            .font(.title)
                            .foregroundColor(.primaryGreen)
                    }
                }
                .background(Color.secondaryGreen)

                if isLoading {
                    CustomLoadingView()
                        .padding(.vertical, 4)
                } else {
                    recipeScrollView
                }
            }
            .onAppear(perform: fetchRandomRecipes)
            .background(gradientBackground)
        }
    }

    private var recipeScrollView: some View {
        ScrollView {
            ForEach(recipes.prefix(6)) { recipe in
                NavigationLink(destination: RecipeDetailView(recipeID: recipe.id)) {
                    RecipeCardView(recipe: recipe)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .background(Color.grayBackground)
    }

    private var gradientBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.secondaryGreen, Color.whiteBackground]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func fetchRandomRecipes() {
        isLoading = true
        RecipeService.shared.fetchRandomRecipes { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedRecipes):
                    recipes = fetchedRecipes
                case .failure(let error):
                    print("Error fetching recipes: \(error.localizedDescription)")
                }
            }
        }
    }

    private func searchRecipes() {
        guard !searchQuery.isEmpty else {
            print("Search query is empty.")
            return
        }
        isLoading = true
        RecipeService.shared.searchRecipes(byIngredient: searchQuery) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedRecipes):
                    if fetchedRecipes.isEmpty {
                        print("No recipes found for query: \(searchQuery)")
                    } else {
                        print("Fetched recipes: \(fetchedRecipes.count)")
                    }
                    recipes = fetchedRecipes
                case .failure(let error):
                    print("Error searching recipes: \(error.localizedDescription)")
                }
            }
        }
    }

}

#Preview {
    @State var isUserLoggedIn = true
    HomeView(isUserLoggedIn: $isUserLoggedIn)
}
