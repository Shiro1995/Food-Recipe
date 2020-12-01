//
//  RecipeModel.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import Foundation

class RecipeModel: NSObject {
    var id: Int?
    var name: String?
    var typeId: Int?
    var imageLink: String?
    var steps: [String]?
    var ingredients: [IngredientsModel]?
    
    convenience init(id: Int?, name: String, typeId: Int, imageLink: String) {
        self.init()
        self.id = id
        self.name = name
        self.typeId = typeId
        self.imageLink = imageLink
    }
}

