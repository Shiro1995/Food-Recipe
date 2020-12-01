//
//  RecipeTypeModel.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import Foundation

class RecipeTypeModel: NSObject {
    var name: String?
    var id : Int?
    
    convenience init(name: String, typeId: Int) {
        self.init()
        self.name = name
    }
}
