//
//  StepModel.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import Foundation
class StepsModel: NSObject {
    var id = 0
    var recipeId = -1
    var steps = 0
    var name: String = ""
    
    convenience init(id: Int, recipeId: Int,steps: Int, name: String) {
        self.init()
        self.id = id
        self.name = name
        self.steps = steps
        self.recipeId = recipeId
    }
}
