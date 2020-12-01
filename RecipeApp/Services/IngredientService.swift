//
//  IngredientService.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import Foundation
import SQLite
class ListIngres {
    static let shared = ListIngres()
    
    private let tb = Table("tbIngres")
    
    private let id = Expression<Int64>("id")
    private let name = Expression<String>("name")
    private let amount = Expression<String>("amount")
    private let recipeId = Expression<Int64>("recipeId")
//    private let picture = Expression<String>("typeId")
    
    private init() {
     
    }
    
    func InsertTable() {
        //create table
        do {
            if let connection = Database.shared.connection {
                try connection.run(tb.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (table) in
                    table.column(self.id, primaryKey: true)
                    table.column(self.name)
                    table.column(self.amount)
                    table.column(self.recipeId)
//                     table.column(self.picture)
                }))
            } else {
                print("Create table failed")
            }
        } catch {
            let nserror = error as NSError
            print("Create table ListFood faild. Error is \(nserror), \(nserror.userInfo)")
        }
    }
    
    func insert(id: Int64, name: String, amount: String) -> Int64? {
        do {
            let insert = tb.insert(
                self.name <- name,
                self.amount <- amount,
                self.recipeId <- id
            )
            let result = try Database.shared.connection?.run(insert)
            return result
        } catch {
            print("Cannot Insert list Recipe")
            return nil
        }
    }

    func update(id: Int64?, recipeId: Int64?, name: String?, amount: String?) -> Bool {
        if Database.shared.connection == nil {
            return false
        }
        do {
            let tbFilter = self.tb.filter(self.id == id!)
            var setters:[SQLite.Setter] = [SQLite.Setter]()
            if name != nil {
                setters.append(self.name <- name!)
            }
            if amount != nil {
                setters.append(self.amount <- amount!)
            }
            if setters.count == 0 {
                print("nothing to update")
                return false
            }
            print(setters)
            let update = tbFilter.update(setters)
            print(update)
            let result  = try Database.shared.connection!.run(update)
            if result < 0 {
                return false
            } else{
                print(result)
            }
            return true
        } catch {
            let nserror = error as NSError
            print("Cannot query listfood")
            return false
        }
    }
    
    func filterById(id: Int) -> AnySequence<Row>? {
        do {
            let gresId = Int64(id)
            return try Database.shared.connection?.prepare(self.tb.filter(self.recipeId == gresId))
            
        } catch {
            let nserror = error as NSError
            print("Cannot query listfood")
            return nil
        }
    }
    
    func queryAll() -> AnySequence<Row>?{
        do {
            return try Database.shared.connection?.prepare(self.tb)
            
        } catch {
            let nserror = error as NSError
            print("Cannot query listfood")
            return nil
        }
    }
    
    
    func toString(ingres: Row){
        let item = IngredientsModel()
        item.name = ingres[self.name]
        print("""
            ingres name = \(item.name)
            """)
    }
    
  
    
    func rowToModel(ingres: Row) -> IngredientsModel {
        let item = IngredientsModel()
        item.id = Int(ingres[self.id])
        item.name = ingres[self.name]
        item.amount = ingres[self.amount]
        item.recipeId = Int(exactly: ingres[self.recipeId])!
        return item
    }
    
    
    
}
