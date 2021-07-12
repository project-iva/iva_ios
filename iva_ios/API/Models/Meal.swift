//
//  Meal.swift
//  iva_ios
//
//  Created by Igor Pidik on 11/07/2021.
//

import Foundation

struct MealIngredient: Codable {
    let ingredientName: String
    let amount: Float
    let kcal: Float
}

struct Meal: Codable {
    let id: Int
    let name: String
    let type: String
    let kcal: Float
    let ingredients: [MealIngredient]
}
