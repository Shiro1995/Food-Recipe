//
//  StepService.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import Foundation
import Foundation
import SQLite
class ListStep {
    static let shared = ListStep()
    
    private let tb = Table("tbSteps")
    
    private let id = Expression<Int64>("id")
    private let step = Expression<Int>("step")
    private let name = Expression<String>("name")
    private let recipeId = Expression<Int64>("recipeId")
    
    private init() {

    }
    
    func InsertTable(){
        //create table
        do {
            if let connection = Database.shared.connection {
                try connection.run(tb.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (table) in
                    table.column(self.id, primaryKey: true)
                    table.column(self.name)
                    table.column(self.step)
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
    
    func insert(id: Int64, step: Int, name: String) -> Int64? {
        do {
            let insert = tb.insert(
                self.name <- name,
                self.step <- step,
                self.recipeId <- id
            )
            let result = try Database.shared.connection?.run(insert)
            return result
        } catch {
            print("Cannot Insert list Recipe")
            return nil
        }
    }
    
    func update(id: Int64?, recipeId: Int64?, step: Int?, name: String?) -> Bool {
        if Database.shared.connection == nil {
            return false
        }
        do {
            let tbFilter = self.tb.filter(self.id == id!)
            var setters:[SQLite.Setter] = [SQLite.Setter]()
            if name != nil {
                setters.append(self.name <- name!)
            }
            if name != nil {
                setters.append(self.step <- step!)
            }
            if setters.count == 0 {
                print("nothing to update")
                return false
            }
            
            let update = tbFilter.update(setters)
            if try Database.shared.connection!.run(update) <= 0 {
                return false
            }
            return true
        } catch {
            let nserror = error as NSError
            print("Cannot query listfood")
            return false
        }
    }
    
    func filterById(recipeId: Int) -> AnySequence<Row>? {
        do {
            let reId = Int64(recipeId)
            return try Database.shared.connection?.prepare(self.tb.filter(self.recipeId == reId))
        } catch {
            let nserror = error as NSError
            print("Cannot query listfood")
            return nil
        }
    }
//    func delete(name: String) -> Void {
//          do {
//            let delete = Database.shared.connection?.prepare(self.tb.delete())
//             print("delete success")
//          } catch {
//              let nserror = error as NSError
//                        print("Cannot delete listrecipe")
//          }
//     }

    func queryAll() -> AnySequence<Row>?{
        do {
            return try Database.shared.connection?.prepare(self.tb)
        } catch {
            let nserror = error as NSError
            print("Cannot query listfood")
            return nil
        }
    }
    func toString(step: Row){
        let item = StepsModel()
        item.name = step[self.name]
        print("""
            Recipe name = \(item.name)
            """)
    }
    
  
    
    func rowToModel(step: Row) -> StepsModel {
        let item = StepsModel()
        item.id = Int(step[self.id])
        item.name = step[self.name]
        item.steps = step[self.step]
        item.recipeId = Int(exactly: step[self.recipeId])!
        return item
    }
    
    
    
}
