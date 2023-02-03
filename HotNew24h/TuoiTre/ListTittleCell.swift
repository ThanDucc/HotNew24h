//
//  ListTittleCell.swift
//  HotNew24h
//
//  Created by ThanDuc on 04/01/2023.
//

import UIKit

class ListTittleCell: UITableViewCell {
    
    @IBOutlet weak var lbCategory: UILabel!

    @IBOutlet weak var btnSort: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
