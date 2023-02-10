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
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var indicatorFavourite: UIActivityIndicatorView!
    
    var imgLink = ""
    var screen = ""
    var new = News(title: "", pubDate: "", link: "", description: "", imgLink: "", htmlString: "")
    
    @IBOutlet weak var btnFavourite: UIButton!
    var delegate: ResetTable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnFavourite.tintAdjustmentMode = .normal
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnFavouriteClick(_ sender: Any) {
        let tittle = self.lbTittleNew.text?.replacingOccurrences(of: "'", with: "\\\\")
        let phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")!
        if self.screen != "Favourite" {
            btnFavourite.isHidden = true
            indicatorFavourite.startAnimating()
        }
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        let check = DatabaseManager.shared.checkFavourite(tittle: self.lbTittleNew.text!, phoneNumber: phoneNumber)
        dispatchGroup.leave()
        dispatchGroup.notify(queue: .main, execute: {
            if !check {
                self.addToFavourite(phoneNumber: phoneNumber, tittle: tittle!, completion: { success in
                    if success {
                        self.btnFavourite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                        self.indicatorFavourite.stopAnimating()
                        self.btnFavourite.isHidden = false
                    }
                })
            } else {
                let tittle = self.lbTittleNew.text?.replacingOccurrences(of: "'", with: "\\\\")
                if self.screen == "Favourite" {
                    self.delegate?.deleteFavourite(tittle: tittle!)
                } else {
                    self.deleteFavourite(phoneNumber: phoneNumber, tittle: tittle!, completion: { success in
                        if success {
                            self.btnFavourite.setImage(UIImage(systemName: "heart"), for: .normal)
                            self.indicatorFavourite.stopAnimating()
                            self.btnFavourite.isHidden = false
                        }
                    })
                }
            }
        })
    }
    
    func addToFavourite(phoneNumber: String, tittle: String, completion: @escaping (Bool) -> Void) {
        var htmlString = new.htmlString
        if htmlString.isEmpty {
            htmlString = try! String(contentsOf: URL(string: new.link)!)
        }
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DatabaseManager.shared.addToFavourite(phoneNumber: phoneNumber, title: tittle, pubDate: self.lbDateTime.text!, description: self.lbDesNew.text!, imgLink: self.imgLink, htmlString: htmlString, link: self.new.link)
        dispatchGroup.leave()
        dispatchGroup.notify(queue: .main, execute: {
            completion(true)
        })
    }
    
    func deleteFavourite(phoneNumber: String, tittle: String, completion: @escaping (Bool) -> Void) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DatabaseManager.shared.deleteFavouriteRow(tittle: tittle, phoneNumber: phoneNumber)
        dispatchGroup.leave()
        dispatchGroup.notify(queue: .main, execute: {
            completion(true)
        })
    }
    
}

