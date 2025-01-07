//
//  RecipeCardView.swift
//  TasteBuds
//
//  Created by Iacopo Lenzi on 12/10/24.
//

import Foundation
import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe

    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: recipe.strMealThumb)) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(height: 200)
            .cornerRadius(15)
            .clipped()
            .shadow(radius: 5)

            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                startPoint: .top, endPoint: .bottom
            )
            .cornerRadius(15)

            VStack {
                Spacer()
                Text(recipe.strMeal)
                    .foregroundColor(.white)
                    .font(.headline)
                    .bold()
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}
