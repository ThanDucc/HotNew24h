//
//  SideMenu.swift
//  HotNew24h
//
//  Created by ThanDuc on 28/12/2022.
//

import UIKit
import FirebaseAuth

protocol MenuDelegate: AnyObject {
    func selectMenuItem(with item: String, bool: Bool)
    func close(bool: Bool)
}

class SideMenu: UIViewController {

    @IBOutlet weak var lbDev: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tbListOption: UITableView!
    weak var delegateMenuItem: MenuDelegate?
    var language = ""
    @IBOutlet weak var btnClose: UIButton!
    
    var list:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "MenuCell2", bundle: nil)
        tbListOption.register(nib, forCellReuseIdentifier: "Cell")
        
        // add left gesture to close menu
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeft.direction = .left
        swipeLeft.view?.isUserInteractionEnabled = true
        tbListOption.addGestureRecognizer(swipeLeft)
        
        // get phone number to get language to display UI
        getLanguage(completion: { success in
            self.tbListOption.delegate = self
            self.tbListOption.dataSource = self
            self.lbDev.text = self.lbDev.text?.LocalizedString(str: self.language)
        })
        setUserName()
        btnClose.tintAdjustmentMode = .normal
    }
    
    func getLanguage(completion: @escaping(Bool) -> Void) {
        self.language = Foundation.UserDefaults.standard.string(forKey: "LanguageAllApp")!
        completion(true)
    }
    
    // display username
    func setUserName() {
        let user = Auth.auth().currentUser
        if user?.phoneNumber == nil {
            if user?.email == nil {
                userName.text = Foundation.UserDefaults.standard.string(forKey: "userName")
            } else {
                userName.text = user?.email
            }
        } else {
            userName.text = user?.phoneNumber
        }
    }
    
    @IBAction func btnClose(_ sender: Any) {
        if list.count == 3 {
            list = []
            self.list = MainViewController.listNewspapers + ["Favourite", "Seen", "Settings", "About App", "Contact us"]
            self.tbListOption.reloadData()
        } else {
            delegateMenuItem!.close(bool: false)
        }
    }
    
    @objc func swipeLeft(_ gesture: UISwipeGestureRecognizer) {
        delegateMenuItem!.close(bool: false)
    }
}

extension SideMenu: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MenuCell
        cell.listOption.text = list[indexPath.row].LocalizedString(str: language)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    // when to click item in menu, send title of item to home screen
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if list[indexPath.row] != MainViewController.nameSideMenu {
            if list[indexPath.row] != "Settings" && list[indexPath.row] != "Language" && list[indexPath.row] != "Delete account" && list[indexPath.row] != "Log out" {
                MainViewController.nameSideMenu = list[indexPath.row]
            }
            delegateMenuItem?.selectMenuItem(with: list[indexPath.row], bool: true)
        } else {
            if list[indexPath.row] == "Settings" || list[indexPath.row] == "Language" || list[indexPath.row] == "Delete account" || list[indexPath.row] == "Log out" {
                delegateMenuItem?.selectMenuItem(with: list[indexPath.row], bool: true)
            } else {
                delegateMenuItem?.selectMenuItem(with: list[indexPath.row], bool: false)
            }
        }
        tbListOption.deselectRow(at: indexPath, animated: false)
    }
}


