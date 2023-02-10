//
//  ListTittleCell.swift
//  HotNew24h
//
//  Created by ThanDuc on 04/01/2023.
//

import UIKit

protocol ClickToHideCate {
    func clickHideCate(indexOfRow: Int)
}

class ListTittleCell: UITableViewCell {
    
    @IBOutlet weak var lbCategory: UILabel!

    @IBOutlet weak var btnHidden: UIButton!
    @IBOutlet weak var btnSort: UIButton!
    
    var delegateHideCate: ClickToHideCate?
    var indexOfRow = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnSort.tintAdjustmentMode = .normal
        btnHidden.tintAdjustmentMode = .normal
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnHiddenClicked(_ sender: Any) {
        delegateHideCate?.clickHideCate(indexOfRow: indexOfRow)
    }
    
}
