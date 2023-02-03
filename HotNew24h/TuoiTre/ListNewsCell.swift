//
//  ListNewsCell.swift
//  HotNew24h
//
//  Created by ThanDuc on 04/01/2023.
//

import UIKit
import WebKit

protocol ResetTable {
    func deleteFavourite(tittle: String)
}

class ListNewsCell: UITableViewCell {

    @IBOutlet weak var imgNew: UIImageView!
    @IBOutlet weak var lbTittleNew: UILabel!
    @IBOutlet weak var lbDesNew: UILabel!
    @IBOutlet weak var lbDateTime: UILabel!
    @IBOutlet weak var view: UIView!
    
    var imgLink = ""
    var new = News(title: "", pubDate: "", link: "", description: "", imgLink: "", htmlString: "")
    
    @IBOutlet weak var btnFavourite: UIButton!
    var delegate: ResetTable?
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnFavouriteClick(_ sender: Any) {
        let tittle = self.lbTittleNew.text?.replacingOccurrences(of: "'", with: "\\\\")
        let phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")!
        if !DatabaseManager.shared.checkFavourite(tittle: self.lbTittleNew.text!, phoneNumber: phoneNumber) {
            var htmlString = new.htmlString
            if htmlString.isEmpty {
                htmlString = try! String(contentsOf: URL(string: new.link)!)
            }
            DatabaseManager.shared.addToFavourite(phoneNumber: phoneNumber, title: tittle!, pubDate: self.lbDateTime.text!, description: self.lbDesNew.text!, imgLink: self.imgLink, htmlString: htmlString, link: self.new.link)
            self.btnFavourite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            let tittle = self.lbTittleNew.text?.replacingOccurrences(of: "'", with: "\\\\")
            self.delegate?.deleteFavourite(tittle: tittle!)
        }
    }
    
}

