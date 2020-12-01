//
//  DetailsTableViewCell.swift
//  RecipeApp
//
//  Created by Lucius on 11/30/20.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       
      
        // Configure the view for the selected state
    }

}
