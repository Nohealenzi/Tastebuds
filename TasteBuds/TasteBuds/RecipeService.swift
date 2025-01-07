//  RecipeService.swift
//  TasteBuds
//
//  Created by Iacopo Lenzi on 12/9/24.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth


class RecipeService {
    static let shared = RecipeService()
    private let baseURL = "https://www.themealdb.com/api/json/v1/1"
    private let firestore = Firestore.firestore()

    func fetchRandomRecipes(completion: @escaping (Result<[Recipe], Error>) -> Void) {
        let endpoint = "\(baseURL)/random.php"
        var recipes: [Recipe] = []
        let group = DispatchGroup()

        for _ in 0..<6 { // Fetch 6 random recipes
            group.enter()
            guard let url = URL(string: endpoint) else { continue }

            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }

                if let error = error {
                    print("Error fetching random recipe: \(error.localizedDescription)")
                    return
                }

                guard let data = data else { return }

                do {
                    let response = try JSONDecoder().decode(RecipeSearchResponse.self, from: data)
                    if let meal = response.meals?.first {
                        recipes.append(meal)
                    }
                } catch {
                    print("Error decoding recipe: \(error.localizedDescription)")
                }
            }.resume()
        }

        group.notify(queue: .main) {
            completion(.success(recipes))
        }
    }

    func searchRecipes(byIngredient ingredient: String, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        let endpoint = "\(baseURL)/filter.php?i=\(ingredient)"
        guard let url = URL(string: endpoint) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                let response = try JSONDecoder().decode(RecipeSearchResponse.self, from: data)
                completion(.success(response.meals ?? []))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchRecipeDetails(byID id: String, completion: @escaping (Result<RecipeDetails, Error>) -> Void) {
        let endpoint = "\(baseURL)/lookup.php?i=\(id)"
        guard let url = URL(string: endpoint) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                let response = try JSONDecoder().decode(RecipeDetailResponse.self, from: data)
                if let details = response.meals?.first {
                    completion(.success(details)) // Ingredients are already parsed in the initializer
                } else {
                    completion(.failure(NSError(domain: "No recipe details found", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchRecipesByIDs(_ ids: [String], completion: @escaping (Result<[Recipe], Error>) -> Void) {
        let group = DispatchGroup()
        var fetchedRecipes: [Recipe] = []

        for id in ids {
            group.enter()
            let endpoint = "\(baseURL)/lookup.php?i=\(id)"
            guard let url = URL(string: endpoint) else { continue }

            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }

                if let error = error {
                    print("Error fetching recipe: \(error.localizedDescription)")
                    return
                }

                guard let data = data else { return }

                do {
                    let response = try JSONDecoder().decode(RecipeDetailResponse.self, from: data)
                    if let recipeDetails = response.meals?.first {
                        // Map RecipeDetails to Recipe
                        let recipe = Recipe(
                            idMeal: id,
                            strMeal: recipeDetails.strMeal,
                            strMealThumb: recipeDetails.strMealThumb
                        )
                        fetchedRecipes.append(recipe)
                    }
                } catch {
                    print("Error decoding recipe: \(error.localizedDescription)")
                }
            }.resume()
        }

        group.notify(queue: .main) {
            completion(.success(fetchedRecipes))
        }
    }
    
    // Save a recipe to favorites
    func saveRecipeToFavorites(_ recipeDetails: RecipeDetails) {
        guard let user = Auth.auth().currentUser else { return }
        let userRef = firestore.collection("Users").document(user.uid)
        let favoriteRecipe = [
            "id": recipeDetails.strMeal,
            "name": recipeDetails.strMeal,
            "image": recipeDetails.strMealThumb
        ]

        userRef.collection("favorites").document(recipeDetails.strMeal).setData(favoriteRecipe) { error in
            if let error = error {
                print("Error saving recipe: \(error.localizedDescription)")
            } else {
                print("Recipe saved to favorites.")
            }
        }
    }

    // Remove a recipe from favorites
    func removeRecipeFromFavorites(_ recipeDetails: RecipeDetails) {
        guard let user = Auth.auth().currentUser else { return }
        let userRef = firestore.collection("Users").document(user.uid)

        userRef.collection("favorites").document(recipeDetails.strMeal).delete { error in
            if let error = error {
                print("Error removing recipe: \(error.localizedDescription)")
            } else {
                print("Recipe removed from favorites.")
            }
        }
    }

    // Check if a recipe is saved in favorites
    func isRecipeSaved(_ recipeDetails: RecipeDetails) -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        let userRef = firestore.collection("Users").document(user.uid)

        var isSaved = false
        let semaphore = DispatchSemaphore(value: 0)

        userRef.collection("favorites").document(recipeDetails.strMeal).getDocument { document, error in
            if let document = document, document.exists {
                isSaved = true
            }
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .distantFuture)
        return isSaved
    }
}

struct Recipe: Codable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String

    var id: String { idMeal }
}

struct RecipeDetails: Codable {
    let strMeal: String
    let strInstructions: String
    let strMealThumb: String
    var ingredients: [String]

    enum CodingKeys: String, CodingKey {
        case strMeal, strInstructions, strMealThumb
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        strMeal = try container.decode(String.self, forKey: .strMeal)
        strInstructions = try container.decode(String.self, forKey: .strInstructions)
        strMealThumb = try container.decode(String.self, forKey: .strMealThumb)

        ingredients = []

        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
        for index in 1...20 {
            let ingredientKey = DynamicCodingKey(stringValue: "strIngredient\(index)")!
            let measureKey = DynamicCodingKey(stringValue: "strMeasure\(index)")!

            if let ingredient = try dynamicContainer.decodeIfPresent(String.self, forKey: ingredientKey),
               let measure = try dynamicContainer.decodeIfPresent(String.self, forKey: measureKey),
               !ingredient.isEmpty, !measure.isEmpty {
                ingredients.append("\(measure) \(ingredient)")
            }
        }
    }
}

struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int? { return nil }

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }
}

struct RecipeSearchResponse: Codable {
    let meals: [Recipe]?
}

struct RecipeDetailResponse: Codable {
    let meals: [RecipeDetails]?
}
