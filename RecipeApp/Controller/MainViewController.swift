//
//  ViewController.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import UIKit
import SQLite

class MainViewController: UIViewController, ItemParserDelegate {
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView?
    let toRecipeDetail = "ToRecipeDetail"
    let toSelectType = "toSelectType"
    let toAddRecipe = "toAddRecipe"
    var selectedType:Int = 0
    var recipeTypes: [RecipeTypeModel] = []
    var allRecipes: [RecipeModel] = []
    var selectedRecipes: [RecipeModel] = []
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromFile()
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore  {
            print("First launch, Insert data")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            inserData()
        }
        picker = UIPickerView.init()
        getListRecipe()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        onDoneButtonTapped()
    }
    
    func getListRecipe(){
        if let listFoodQuery: AnySequence<Row> = ListRecipe.shared.queryAll(){
            for food in listFoodQuery {
                // ListRecipe.shared.toString(food: food)
                let item:RecipeModel = ListRecipe.shared.rowToModel(food: food)
                allRecipes.append(item)
            }
        }
        selectedRecipes = allRecipes
    }
    
    func loadDataFromFile(){
        XmlParserHelper.sharedInstance.parserDelegate = self
        XmlParserHelper.sharedInstance.readXmlFromFile(fileName: "DataXml", fileType: "xml")
    }
    
    func sendData(result: [RecipeTypeModel]) {
        recipeTypes.append(contentsOf: result)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toRecipeDetail,
           let dest = segue.destination as? DetailViewController,
           let recipe = sender as? RecipeModel {
            dest.recipeInfo = recipe
            dest.recipeTypes = self.recipeTypes
            dest.didEdit = { result in
                if self.selectedType == 0 {
                    if let x = self.selectedRecipes.filter({$0.id == result.id}).first {
                        x.imageLink = result.imageLink
                        x.name = result.name
                        x.typeId = result.typeId
                    } else {
                        if self.recipeTypes[self.selectedType - 1].id == result.typeId {
                            self.selectedRecipes.append(result)
                        }
                    }
                    self.tableView?.reloadData()
                }
            }
            dest.didDelete =  { result in
                if self.selectedType == 0 {
                    self.selectedRecipes.removeAll { (RecipeModel) -> Bool in
                        RecipeModel.id == result
                    }
                }
                self.tableView?.reloadData()
            }
        }
        if segue.identifier == toAddRecipe,
           let add = segue.destination as? AddViewController, let count = sender as? Int {
            add.listType = recipeTypes
            add.count = count
            add.didCreate = { result in
                print(result.name as Any)
                self.allRecipes.append(result)
                if self.selectedType == 0 {
                        self.selectedRecipes.append(result)
                    } else {
                        if self.recipeTypes[self.selectedType - 1].id == result.typeId {
                            self.selectedRecipes.append(result)
                        }
                    }
                self.tableView?.reloadData()
            }
        }
    }
    
    @IBAction func filterAction(_ sender: Any) {
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(picker)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.view.addSubview(toolBar)
    }
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
    @IBAction func addRecipeTapped(_ sender: Any) {
        performSegue(withIdentifier: toAddRecipe, sender: allRecipes.count)
    }
    
    func filterRecipeByTypeID(_ typeID: Int) {
        //1. Fillter rec ipes
        selectedRecipes = allRecipes.filter{$0.typeId == typeID}
        
        //2. reload tableview
        tableView?.reloadData()
    }
    
    
    
    func inserData(){
        print("inserting ...")
        ListRecipe.shared.InsertTable()
        ListIngres.shared.InsertTable()
        ListStep.shared.InsertTable()
        _ = ListRecipe.shared.insert(name: "Almond Rice Pudding",imageLink: "1", typeId: 1)
        _ = ListRecipe.shared.insert(name: "Any Berry Sauce",imageLink: "2", typeId: 3)
        _ = ListRecipe.shared.insert(name: "Apple Bars",imageLink: "3",typeId: 1)
        _ = ListRecipe.shared.insert(name: "Apple Spice Baked Oatmeal",imageLink: "4",typeId: 1)
        _ = ListRecipe.shared.insert(name: "Banana Oatmeal Muffins",imageLink: "5", typeId: 2)
        _ = ListRecipe.shared.insert(name: "Any Berry Sauce",imageLink: "2", typeId: 1)
        _ = ListRecipe.shared.insert(name: "Apple Bars",imageLink: "3",typeId: 1)
        _ = ListRecipe.shared.insert(name: "Apple Spice Baked Oatmeal",imageLink: "4",typeId: 3)
        _ = ListRecipe.shared.insert(name: "Banana Oatmeal Muffins",imageLink: "5", typeId: 2)
        _ = ListRecipe.shared.insert(name: "Buttermilk Scones",imageLink: "6", typeId: 1)
        _ = ListRecipe.shared.insert(name: "Cherry Scones",imageLink: "7",typeId: 2)
        _ = ListRecipe.shared.insert(name: "Sweet Carrot Bread or Muffins",imageLink: "8",typeId: 2)
        _ = ListRecipe.shared.insert(name: "Asian Beef and Noodles",imageLink: "9", typeId: 3)
        _ = ListRecipe.shared.insert(name: "Baked Bean Medley",imageLink: "10", typeId: 1)
        _ = ListRecipe.shared.insert(name: "Burrito Soups",imageLink: "11",typeId: 3)
        _ = ListRecipe.shared.insert(name: "Ham and Vegetable Chowder",imageLink: "12",typeId: 1)
        //
        for index in 1..<17 {
            _ = ListIngres.shared.insert(id: Int64(index), name: "milk", amount: "1 cup")
            _ = ListIngres.shared.insert(id: Int64(index), name: "egg", amount: "2")
            _ = ListIngres.shared.insert(id: Int64(index), name: "salt", amount: "1/4 teaspoon")
            _ = ListIngres.shared.insert(id: Int64(index), name: "quick rolled oats", amount: "1 cup")
            _ = ListStep.shared.insert(id: Int64(index), step: 1, name: "Preheat oven to 400 degrees F. Lightly oil or spray the bottoms of 12 muffin cups.")
            _ = ListStep.shared.insert(id: Int64(index), step: 2, name: "Mix oats with milk. Stir in lightly-beaten eggs, oil and bananas. Let stand while measuring dry ingredients.")
            _ = ListStep.shared.insert(id: Int64(index), step: 3, name: "In a separate bowl, combine dry ingredients and stir well.")
            _ = ListStep.shared.insert(id: Int64(index), step: 4, name: "Bake at 400 degrees F until golden brown and a toothpick inserted in the center comes out moist but clean, about 18 to 20 minutes.")
        }
    }
}
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = selectedRecipes[indexPath.row]
        performSegue(withIdentifier: self.toRecipeDetail, sender: recipe)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedRecipes.count
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            if ListRecipe.shared.delete(id: selectedRecipes[indexPath.row].id!) {
                selectedRecipes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell", for: indexPath) as! RecipeTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let item:RecipeModel = selectedRecipes[indexPath.row]
        cell.name?.text = "\(String(item.id!)) \(String(item.name!))"
        let dataDecoded = Data(base64Encoded: item.imageLink!, options: .ignoreUnknownCharacters)!
        cell.image1.image = UIImage(data: dataDecoded as Data)!
        return cell
    }
}

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recipeTypes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 { return "show All"
        } else{
            return self.recipeTypes[row - 1].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedType = row
            if row == 0 {
                self.selectedRecipes = self.allRecipes
                tableView?.reloadData()
            } else {
                if let typeID = recipeTypes[row - 1].id {
                    self.filterRecipeByTypeID(typeID)
                }
            }
        
    }
}


