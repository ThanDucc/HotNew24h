//
//  SideMenu.swift
//  HotNew24h
//
//  Created by ThanDuc on 28/12/2022.
//

import UIKit
import FirebaseAuth

protocol MenuDelegate: AnyObject {
    func selectMenuItem(with item: String)
    func close()
}

class SideMenu: UIViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tbListOption: UITableView!
    weak var delegate: MenuDelegate?
    var language = ""
    
    var list:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tbListOption.delegate = self
        tbListOption.dataSource = self
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeft.direction = .left
        swipeLeft.view?.isUserInteractionEnabled = true
        
        tbListOption.addGestureRecognizer(swipeLeft)
        
        let phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")
        self.language = DatabaseManager.shared.getLanguage(phoneNumber: phoneNumber!)
        
        setUserName()
    }
    
    func setUserName() {
        let user = Auth.auth().currentUser
        if (user?.phoneNumber == nil) {
            userName.text = Foundation.UserDefaults.standard.string(forKey: "userName")
        } else {
            userName.text = user?.phoneNumber
        }
    }
    
    @IBAction func btnClose(_ sender: Any) {
        if list.count == 3 {
            list = ["Youth", "VNExpress", "Favourite", "Seen", "Settings", "About App", "Contact us"]
            tbListOption.reloadData()
        } else {
            delegate!.close()
        }
    }
    
    @objc func swipeLeft(_ gesture: UISwipeGestureRecognizer) {
        delegate!.close()
    }
}

extension SideMenu: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MenuCell
        cell.listOption.text = list[indexPath.row].LocalizedString(str: language)
        return cell
    }
}

extension SideMenu: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectMenuItem(with: list[indexPath.row])
    }
}
