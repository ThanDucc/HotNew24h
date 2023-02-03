//
//  SortCategoryTuoiTre.swift
//  HotNew24h
//
//  Created by ThanDuc on 04/01/2023.
//

import UIKit
import Contacts

class SortCategoryTuoiTre: UIViewController {
    
    var list: [String] = []
    var listKeyUrl: [String] = []
    var phoneNumber = ""
    var language = ""
    
    @IBOutlet weak var tbListCategory: UITableView!
    
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnSort: UIButton!
    
    var hidden = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")!
        self.language = DatabaseManager.shared.getLanguage(phoneNumber: phoneNumber)
        
        list = DatabaseManager.shared.getListCategory(phoneNumber: phoneNumber)
        listKeyUrl = DatabaseManager.shared.getListKeyUrl(phoneNumber: phoneNumber)
        
        tbListCategory.delegate = self
        tbListCategory.dataSource = self
        
        tbListCategory.dragInteractionEnabled = true
        
        btnSort.setTitle(btnSort.titleLabel?.text?.LocalizedString(str: language), for: .normal)
        btnDone.setTitle(btnDone.titleLabel?.text?.LocalizedString(str: language), for: .normal)
    }
    
    @IBAction func btnDone(_ sender: Any) {
        tbListCategory.dragDelegate = nil
        tbListCategory.dropDelegate = nil
        hidden = true
        tbListCategory.reloadData()
        
        DatabaseManager.shared.updateCategory(phoneNumber: phoneNumber, category: getStringList(list: list), keyCategory: getStringList(list: listKeyUrl))
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSort(_ sender: Any) {
        tbListCategory.dragDelegate = self
        tbListCategory.dropDelegate = self
        hidden = false
        tbListCategory.reloadData()
    }
    
    func getStringList(list: [String]) -> String {
        var stringList = ""
        for i in 0..<list.count - 1 {
            stringList = stringList + list[i] + "|"
        }
        stringList += list[list.count-1]
        return stringList
    }
}

extension SortCategoryTuoiTre: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell_1") as! ListTittleCell
        cell.lbCategory.text = list[indexPath.row].LocalizedString(str: language)
        if hidden {
            cell.btnSort.isHidden = true
        } else {
            cell.btnSort.isHidden = false
            cell.btnSort.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item1 = list[sourceIndexPath.row]
        list.remove(at: sourceIndexPath.row)
        list.insert(item1, at:destinationIndexPath.row)

        let item2 = listKeyUrl[sourceIndexPath.row]
        listKeyUrl.remove(at: sourceIndexPath.row)
        listKeyUrl.insert(item2, at:destinationIndexPath.row)
    }
    
}

extension SortCategoryTuoiTre: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
}

extension SortCategoryTuoiTre: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {

        if session.localDragSession != nil { // Drag originated from the same app.
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }

}

