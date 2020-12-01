//
//  DetailViewController.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import UIKit

class DetailViewController: UIViewController, UIActionSheetDelegate {
//    @IBOutlet weak var lbName:UILabel?
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var lbName: UITextField!
    @IBOutlet weak var EditButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var changeTypeBtn: UIButton!
    @IBOutlet weak var changeImageButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var editDetailButton: UIButton!
    @IBOutlet weak var bottomTableview: NSLayoutConstraint!
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    var imageRecipe:UIImage?
    let toPopupDetail = "toPopupDetail"
    var stringState = ["Edit Steps", "Edit Ingredients"]
    var recipeInfo = RecipeModel()
    var ingres : [IngredientsModel] = []
    var steps: [StepsModel] = []
    var didEdit: ((RecipeModel) -> ())?
    var didDelete: ((Int) -> ())?
    var recipeTypes:[RecipeTypeModel] = []
    var isEdit:Bool = false
    var state:Int = 0
    var selectedType:Int = 0
    var imageLink:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedType = recipeInfo.typeId!
        self.lbName.isUserInteractionEnabled = false
        self.lbName.borderStyle = .none
        lbName?.text = recipeInfo.name
        let dataDecoded = Data(base64Encoded: recipeInfo.imageLink!, options: .ignoreUnknownCharacters)!
        imageLink = recipeInfo.imageLink
        self.image.image =  UIImage(data: dataDecoded as Data)!
        navigationItem.rightBarButtonItem = EditButton
        let aboutButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(clickEdit))
        navigationItem.rightBarButtonItem = aboutButton
        picker = UIPickerView.init()
        loadDetailInfo()
    }
    
    func loadDetailInfo(){
        if let listInges: AnySequence = ListIngres.shared.filterById(id: recipeInfo.id!){
            for inges in listInges {
                let item:IngredientsModel = ListIngres.shared.rowToModel(ingres: inges)
                ingres.append(item)
            }
        }
        if let listSteps: AnySequence = ListStep.shared.filterById(recipeId: recipeInfo.id!){
            for step in listSteps {
                let item:StepsModel = ListStep.shared.rowToModel(step: step)
                steps.append(item)
            }
        }
    }
    
    @IBAction func changeTypeTapped(_ sender: Any) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toPopupDetail,
           let dest = segue.destination as? EditDetailViewController{
            dest.recipeInfo = recipeInfo
            
            if state == 0 {
                dest.Stringlabel1 = "Step"
                dest.Stringlabel2 = "Description"
                if let row = sender as? Int {
                    dest.string1 = String(steps[row].steps)
                    dest.string2 = steps[row].name
                    dest.didSendData = { [self] result in
                        if ListStep.shared.update(id: Int64(steps[row].id), recipeId: Int64(steps[row].recipeId), step: Int(result[0])!, name: result[1]) {
                            self.steps[row].steps = Int(result[0])!
                            self.steps[row].name = result[1]
                        }
                        tableView?.reloadData()
                    }
                }else{
                    dest.didSendData = { [self] result in
                        if let id = ListStep.shared.insert(id: Int64(self.recipeInfo.id!), step: Int(result[0])!, name: result[1]) {
                            steps.append(StepsModel(id: Int(id), recipeId: recipeInfo.id!, steps: Int(result[0])!, name: result[1]))
                        }
                        tableView?.reloadData()
                    }
                }
            } else{
                dest.Stringlabel1 = "Name"
                dest.Stringlabel2 = "Amount"
                if let row = sender as? Int {
                    dest.string1 = ingres[row].name
                    dest.string2 = ingres[row].amount
                    dest.didSendData = { [self] result in
                        if ListIngres.shared.update(id: Int64(ingres[row].id), recipeId: Int64(ingres[row].recipeId), name: result[0], amount: result[1]){
                            self.ingres[row].name = result[0]
                            self.ingres[row].amount = result[1]
                        }
                        tableView?.reloadData()
                    }
                } else{
                    dest.didSendData = { [self] result in
                        if let id = ListIngres.shared.insert(id: Int64(self.recipeInfo.id!), name: result[0], amount: result[1]) {
                            ingres.append(IngredientsModel(id: Int(id), recipeId: recipeInfo.id!, name: result[0], amount: result[1]))
                        }
                        tableView?.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func clickEdit(){
        self.isEdit.toggle()
        changeImageButton.isHidden.toggle()
        deleteButton.isHidden.toggle()
        changeTypeBtn.isHidden.toggle()
        self.lbName.isUserInteractionEnabled.toggle()
        if isEdit {
            UIView.animate(withDuration: 0.5) {
                self.bottomTableview.constant = 110
            }

        } else{
            let imageData:NSData = image.image!.pngData()! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            if (strBase64 == imageLink) {
                imageLink = nil
            } else{
                imageLink = strBase64
            }
            if ListRecipe.shared.update(id: Int64(recipeInfo.id!), typeId: Int64(selectedType), name: lbName.text, imageLink: strBase64 ) {
                let recipe = RecipeModel(id: recipeInfo.id, name: lbName.text ?? "", typeId: recipeInfo.typeId!, imageLink: strBase64)
                didEdit?(recipe)
            }
            UIView.animate(withDuration: 0.5) {
                self.bottomTableview.constant = 20
            }
        }
        navigationItem.rightBarButtonItem?.title = self.isEdit ? "Save" : "Edit"
        tableView?.reloadData()
    }
    
    @IBAction func changeImageTapped(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.state = 0
            tableView?.reloadData()
            break;
        case 1:
            self.state = 1
            tableView?.reloadData()
            break;
        default:
            break;
        }
    }
    
    
    @IBAction func deleteBtnTapped(_ sender: Any) {
//        ListRecipe.shared.delete(id: recipeInfo.id!)
        let refreshAlert = UIAlertController(title: "Delete Recipe", message: "Are you sure you want to delete?", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            if ListRecipe.shared.delete(id: self.recipeInfo.id!) {
                self.didDelete?(self.recipeInfo.id!)
            }
            _ = self.navigationController?.popViewController(animated: true)
          }))
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                
          }))

        present(refreshAlert, animated: true, completion: nil)
   
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isEdit {
            return 40
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if isEdit {
            return .delete
        }
            return .none
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isEdit {
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
        } else{
            let uiView = UIView()
            uiView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            return uiView
        }
      
    }
    
    @objc func addInfoTapped(sender: UIButton!){
        self.performSegue(withIdentifier: self.toPopupDetail, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEdit {
            self.performSegue(withIdentifier: self.toPopupDetail, sender: indexPath.row)
        }
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCell", for: indexPath) as! DetailsTableViewCell
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

extension DetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
        
        if let typeID = recipeTypes[row - 1].id {
            selectedType = typeID
        }
        
    }
}

extension DetailViewController : UIImagePickerControllerDelegate & UINavigationControllerDelegate {
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
