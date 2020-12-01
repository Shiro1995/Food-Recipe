//
//  IngredientModel.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import Foundation

class IngredientsModel: NSObject {
    var id = 0
    var recipeId = -1
    var name: String = ""
    var amount : String = ""
    
    convenience init(id: Int, recipeId: Int, name: String, amount: String) {
        self.init()
        self.id = id
        self.name = name
        self.amount = amount
        self.recipeId = recipeId
    }
}
