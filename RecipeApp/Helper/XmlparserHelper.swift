//
//  XmlparserHelper.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import Foundation
import UIKit

protocol ItemParserDelegate {
    func sendData(result: [RecipeTypeModel])
}

class XmlParserHelper: NSObject, XMLParserDelegate {
    static let sharedInstance = XmlParserHelper()
    
    var parserDelegate: ItemParserDelegate?
    var xmlParser: XMLParser?
    var recipeTypes:[RecipeTypeModel] = []
    
    var isId:Bool = false
    var isName:Bool = false
    
    func readXmlFromFile(fileName: String, fileType: String){
        let url = Bundle.main.url(forResource: fileName, withExtension: fileType)
        self.xmlParser = XMLParser(contentsOf: url!)
        self.xmlParser?.delegate = self
        
        let result = self.xmlParser?.parse()
        if result == false {
            print("Error when reading!!!")
        }

    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "id" {
            isId = true
            let newItem = RecipeTypeModel()
            recipeTypes.append(newItem)
        }
        if elementName == "name" {
            isName = true
        }
    }
    
    // 2
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if isId {
            isId = false
        }
        if isName {
            isName = false
        }
    }
    
    // 3
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        //
        //        if (!data.isEmpty) {
        if isId {
            recipeTypes[recipeTypes.count - 1 ].id = Int.init(string)
        }
        if isName {
            recipeTypes[recipeTypes.count - 1 ].name = (string)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print("end reading")
        print("Recipe type count: \(recipeTypes.count)")
        self.parserDelegate?.sendData(result: recipeTypes)
    }
}
