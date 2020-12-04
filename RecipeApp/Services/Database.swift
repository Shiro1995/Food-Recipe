//
//  Database.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import Foundation
import SQLite


class Database {
    static let shared = Database()
    public let connection: Connection?
    public let databaseFileName = "Food-recipe.sqlite3"
    private init(){
        let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as String?
//        print(dbPath)
        do {
            connection = try Connection("\(dbPath!)/(databaseFileName)")
        } catch {
           connection = nil
            let nserror = error as NSError
            print("Cannot connect to database")
        }
    }
}
