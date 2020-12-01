//
//  EditDetailViewController.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import UIKit

class EditDetailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var viewDetail: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var tvString1: UITextView!
    @IBOutlet weak var tvString2: UITextView!
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var btOK: UIButton!
    var Stringlabel1:String = ""
    var Stringlabel2:String = ""
    var didSendData: (([String]) -> ())?
    var recipeInfo = RecipeModel()
    var string1:String = ""
    var string2:String = ""
    override func viewDidLoad() {
        tvString1.layer.borderWidth = 0.5
        tvString1.layer.borderColor = UIColor.gray.cgColor
        tvString2.layer.borderWidth = 0.5
        tvString2.layer.borderColor = UIColor.gray.cgColor
        label1.text = Stringlabel1
        label2.text = Stringlabel2
        if Stringlabel1 == "step" {
            tvString1.keyboardType = UIKeyboardType.numberPad
        }
        tvString1.text = string1
        tvString2.text = string2
    }
    
    @IBAction func OKTapped(_ sender: Any) {
//        self.heightView.constant = 200
        string1 = tvString1.text!
        string2 = tvString2.text!
        let x = [string1,string2]
        didSendData?(x)
        dismiss(animated: true)
    }
    
    @IBAction func CancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
