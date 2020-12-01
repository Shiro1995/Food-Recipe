//
//  RecipeTableViewCell.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel?
    
    @IBOutlet weak var image1: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
