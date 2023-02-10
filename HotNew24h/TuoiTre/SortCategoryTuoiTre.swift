//
//  SortCategoryTuoiTre.swift
//  HotNew24h
//
//  Created by ThanDuc on 04/01/2023.
//

import UIKit
import Contacts

protocol UpdateCategory {
    func update(nameCate: String)
}
class SortCategoryTuoiTre: UIViewController {
    
    var list: [String] = []
    var listHidden: [String] = []
    var phoneNumber = ""
    var language = ""
    var type = ""
    var nameCate = ""
    
    @IBOutlet weak var tbListCategory: UITableView!
    
    @IBOutlet weak var lbTittle: UILabel!
    @IBOutlet weak var btnDone: UIButton!
    
    var delegateSortCate: UpdateCategory?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbListCategory.dragDelegate = self
        tbListCategory.dropDelegate = self
        
        phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")!
        // get language
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        let language = DatabaseManager.shared.getLanguage(phoneNumber: phoneNumber)
        dispatchGroup.leave()
        dispatchGroup.notify(queue: .main, execute: {
            self.language = language
            self.lbTittle.text = "More".LocalizedString(str: language)
            self.btnDone.setTitle(self.btnDone.titleLabel?.text?.LocalizedString(str: language), for: .normal)
        })
        
        getListCategory()
        tbListCategory.dragInteractionEnabled = true
        
        btnDone.tintAdjustmentMode = .normal
    }
    
    // get list category
    func getListCategory() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        let category: [Category] = DatabaseManager.shared.getListCategory(phoneNumber: phoneNumber, type: type)
        dispatchGroup.leave()
        dispatchGroup.notify(queue: .main, execute: { [self] in
            for i in 0..<category.count {
                self.list.append(category[i].name)
                self.listHidden.append(category[i].isHidden)
            }
            tbListCategory.delegate = self
            tbListCategory.dataSource = self
        })
    }
    
    // back to home screen and update position of categories
    @IBAction func btnDone(_ sender: Any) {
        if listHidden.contains("false") {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            for i in 0..<self.list.count {
                DatabaseManager.shared.updateCategory(phoneNumber: self.phoneNumber, position: i, name: self.list[i], type: self.type)
                DatabaseManager.shared.updateCategory(phoneNumber: self.phoneNumber, isHidden: self.listHidden[i], name: self.list[i], type: self.type)
            }
            dispatchGroup.leave()
            dispatchGroup.notify(queue: .main, execute: {
                self.delegateSortCate?.update(nameCate: self.nameCate)
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            let alert = UIAlertController(title: "Warning".LocalizedString(str: language), message: "You must not hide all categories!".LocalizedString(str: language), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.revealViewController()?.gestureEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.revealViewController()?.gestureEnabled = true
    }
}

extension SortCategoryTuoiTre: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell_1") as! ListTittleCell
        cell.lbCategory.text = list[indexPath.row].LocalizedString(str: language)
        cell.indexOfRow = indexPath.row
        if listHidden[indexPath.row] == "false" {
            cell.btnHidden.setImage(UIImage(systemName: "pin.fill"), for: .normal)
        } else {
            cell.btnHidden.setImage(UIImage(systemName: "pin.slash.fill"), for: .normal)
        }
        cell.delegateHideCate = self
        return cell
    }
    
    // sort and swap position
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item1 = list[sourceIndexPath.row]
        list.remove(at: sourceIndexPath.row)
        list.insert(item1, at:destinationIndexPath.row)
        
        let item2 = listHidden[sourceIndexPath.row]
        listHidden.remove(at: sourceIndexPath.row)
        listHidden.insert(item2, at:destinationIndexPath.row)
        
        tbListCategory.reloadData()
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

extension SortCategoryTuoiTre: ClickToHideCate {
    
    func clickHideCate(indexOfRow: Int) {
        if listHidden[indexOfRow] == "false" {
            listHidden[indexOfRow] = "true"
        } else {
            listHidden[indexOfRow] = "false"
        }
        tbListCategory.reloadData()
    }
}
    
