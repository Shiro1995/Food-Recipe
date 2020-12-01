//
//  AddViewController.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import UIKit

class AddViewController: UIViewController{
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var addInfoBtn: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var steps:[StepsModel] = []
    var ingres:[IngredientsModel] = []
    var count:Int = 0
    //    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    let toPopupDetail = "AddtoPopupDetail"
    var listType: [RecipeTypeModel] = []
    var idSelected = 1
    var state: Int = 0
    var didCreate: ((RecipeModel) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        openPicker()
        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toPopupDetail,
           let dest = segue.destination as? EditDetailViewController {
            if state == 0 {
                dest.Stringlabel1 = "Step"
                dest.Stringlabel2 = "Description"
                dest.didSendData = { [self] result in
                    let step = StepsModel(id: 0, recipeId: count, steps: Int(result[0])!, name: result[1])
                    self.steps.append(step)
                    tableview.reloadData()
                }
            } else{
                dest.Stringlabel1 = "Name"
                dest.Stringlabel2 = "Amount"
                dest.didSendData = { [self] result in
                    let ingre = IngredientsModel(id: 0, recipeId: count, name: result[0], amount: result[1])
                    ingres.append(ingre)
                    tableview.reloadData()
                }
            }
        }
    }
    
    @IBAction func textNameChange(_ sender: UITextField) {
       
    }
    
    let toolbar = UIToolbar()
    func openPicker(){
        if toolbar.items?.count == 0 || toolbar.items == nil  {
            let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
            toolbar.setItems([doneBtn], animated: true)
        }
        
        typeField.inputAccessoryView = toolbar
        typeField.inputView = picker
        
        toolbar.sizeToFit()
    }
    
    @objc func donePressed(){
        typeField.text = listType[idSelected].name
        self.view.endEditing(true )
    }
    
    @IBAction func addInfoTapped(_ sender: Any) {
        
    }
    
    @IBAction func selectImageTapped(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @IBAction func btOnpress(_ sender: Any) {
        if(name.text == "" || typeField.text == "") {
            let refreshAlert = UIAlertController(title: "Error!", message: "Please fill full field!", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
              }))
            present(refreshAlert, animated: true, completion: nil)
        } else{
            let imageData:NSData = (image.image?.pngData()!)! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            if let id = ListRecipe.shared.create(name: name.text!, imageLink: strBase64, typeId: Int64(listType[idSelected].id!)) {
                let recipe = RecipeModel(id: Int(id), name: name.text!, typeId: listType[idSelected].id!, imageLink: strBase64)
                didCreate?(recipe)
                steps.forEach { (step) in
                    _ = ListStep.shared.insert(id: id, step: step.steps, name: step.name)
                }
                ingres.forEach { (ingre) in
                    _ = ListIngres.shared.insert(id: id, name: ingre.name, amount: ingre.amount)
                }
                let refreshAlert = UIAlertController(title: "Success!", message: "Create Success!", preferredStyle: UIAlertController.Style.alert)
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    _ = self.navigationController?.popViewController(animated: true)
                  }))
                present(refreshAlert, animated: true, completion: nil)
                
            }
        }
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.state = 0
            tableview.reloadData()
            break;
        case 1:
            self.state = 1
            tableview.reloadData()
            break;
        default:
            break;
        }
    }
    
    @IBAction func addInfoTableTapped(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "Step", style: .default) { [self] action -> Void in
            self.performSegue(withIdentifier: self.toPopupDetail, sender: nil)

        }

        let secondAction: UIAlertAction = UIAlertAction(title: "Ingredient", style: .default) { [self] action -> Void in
            self.performSegue(withIdentifier: self.toPopupDetail, sender: nil)
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

        // add actions
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)

        present(actionSheetController, animated: true) {
        }
    }
}

extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 40
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1)
        let label = UILabel()
        label.frame = CGRect(x: self.view.frame.width/2 + 5, y: 0, width: self.view.frame.width/2 - 5, height: 30)
        label.text = "Swipe to delete row"
        label.backgroundColor = .gray
        label.textColor = .white
        if (state == 0 && steps.count > 0) || (state == 1 && ingres.count > 0) {
            headerView.addSubview(label)
        }
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/2 - 5, height: 30)
        button.setTitle(state == 0 ? "Add Step" : "Add Ingredient", for: .normal)
        button.backgroundColor = UIColor(red: 0.721568644, green:
                                            0.8862745166, blue: 0.5921568871, alpha: 1)
        button.addTarget(self, action: #selector(addInfoTapped), for: .touchUpInside)
        headerView.addSubview(button)
        return headerView
    }
    
    
    @objc func addInfoTapped(sender: UIButton!){
        self.performSegue(withIdentifier: self.toPopupDetail, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            if state == 0{
                steps.remove(at: indexPath.row)
            } else{
                ingres.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if state == 0 {
            return steps.count
        } else {
            return ingres.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addTableCell", for: indexPath) as! AddTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        if state == 0 {
            let item:StepsModel = steps[indexPath.row]
            cell.Title?.text = "\(item.steps). \(item.name)"
            cell.subTitle?.text = .none
        } else{
            let item:IngredientsModel = ingres[indexPath.row]
            cell.Title?.text = String(item.name)
            cell.subTitle?.text = item.amount
        }
        return cell
    }
    

}

extension AddViewController:  UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        listType.count
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return listType[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        idSelected = row
    }
}

extension AddViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageGet = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")]{
            self.image.image = imageGet as? UIImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
