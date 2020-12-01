//
//  RecipeService.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import Foundation
import SQLite
import UIKit

class ListRecipe {
    static let shared = ListRecipe()
    
    private let tb = Table("tbListRecipe")
    
    private let id = Expression<Int64>("id")
    private let name = Expression<String>("name")
    private let imageLink = Expression<String>("imageLink")
    private let typeId = Expression<Int64>("typeId")
    
    
    private init() {
       
    }
    func InsertTable(){
       // create table
        do {
            if let connection = Database.shared.connection {
                try connection.run(tb.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (table) in
                    table.column(self.id, primaryKey: true)
                    table.column(self.name)
                    table.column(self.imageLink)
                    table.column(self.typeId)
                }))
            } else {
                print("Create table failed")
            }
        } catch {
            let nserror = error as NSError
            print("Create table ListFood faild. Error is \(nserror), \(nserror.userInfo)")
        }
    }
    // Insert
    
    func insert(name: String,imageLink: String, typeId: Int64 ) -> Int64? {
        let i = String(describing: self.id)
        do {
            let image:UIImage = UIImage(named: imageLink)!
            let imageData:NSData = image.pngData()! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            let insert = tb.insert(
                self.name <- name,
                self.imageLink <- strBase64,
                self.typeId <- typeId )
            let insertedId = try Database.shared.connection?.run(insert)
            print("insert success id: \(insertedId)")
            return insertedId
        } catch {
            let nserror = error as NSError
            print("Cannot Insert listfood")
            return nil
        }
    }
    
    func create(name: String,imageLink: String, typeId: Int64 ) -> Int64? {
        let i = String(describing: self.id)
        do {
            let insert = tb.insert(
                self.name <- name,
                self.imageLink <- imageLink,
                self.typeId <- typeId )
            let insertedId = try Database.shared.connection?.run(insert)
            print("insert success id: \(insertedId)")
            return insertedId
        } catch {
            let nserror = error as NSError
            print("Cannot Insert listfood")
            return nil
        }
    }
    
    func update(id: Int64, typeId: Int64?, name: String?, imageLink: String?) -> Bool {
        if Database.shared.connection == nil {
            return false
        }
        do {
            let tbFilter = self.tb.filter(self.id == id)
            var setters:[SQLite.Setter] = [SQLite.Setter]()
            if name != nil {
                setters.append(self.name <- name!)
            }
            if imageLink != nil {
                setters.append(self.imageLink <- imageLink!)
            }
            if typeId != nil {
                setters.append(self.typeId <- typeId!)
            }
            if setters.count == 0 {
                print("nothing to update")
                return false
            }
            let update = tbFilter.update(setters)
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
    
    func delete(id: Int) -> Bool {
        do {
            let tbfilter = tb.filter(self.id == Int64(id)).delete()
//            var setter:[SQLite.Setter] = [SQLite.Setter]()

            try Database.shared.connection?.run(tbfilter)
            return true
        } catch {
            let nserror = error as NSError
            print("Cannot delete listfood")
            return false
        }
    }
        
    func filter() -> AnySequence<Row>? {
        do {
            return try Database.shared.connection?.prepare(self.tb.filter(self.id == 1))
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
    
    func rowToModel(food: Row) -> RecipeModel {
           let item = RecipeModel()
           item.id = Int(exactly: food[self.id])
           item.name = food[self.name]
           item.imageLink = food[self.imageLink]
           item.typeId = Int(exactly: food[self.typeId])
           //
           return item
       }
    func toString(food: Row){
        print("""
            id: \(food[self.id])
            Food name: \(food[self.name])
            TypeId: \(food[self.typeId])
            """)
    }
}

