//
//  RecipeListView.swift
//  TasteBuds
//
//  Created by Iacopo Lenzi on 12/9/24.
//

import Foundation
import SwiftUI

struct RecipeListView: View {
    let recipes: [Recipe]
    
    var body: some View {
        List(recipes) { recipe in
            NavigationLink(destination: RecipeDetailView(recipeID: recipe.id)) {
                HStack {
                    AsyncImage(url: URL(string: recipe.strMealThumb)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    
                    Text(recipe.strMeal)
                        .font(.headline)
                }
            }
        }
    }
}
