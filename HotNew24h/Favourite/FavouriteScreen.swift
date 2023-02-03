//
//  FavouriteScreen.swift
//  HotNew24h
//
//  Created by ThanDuc on 04/01/2023.
//

import UIKit

class FavouriteScreen: UIViewController {

    @IBOutlet weak var tbListFavourite: UITableView!
    var list: [News] = []
    weak var delegateCate: CategoryDelegate?
    var phoneNumber = ""
    var language = ""
    var isLoading = false
    var page = 0
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ListTitleCell", bundle: nil)
        tbListFavourite.register(nib, forCellReuseIdentifier: "Cell_2")
        
        let Nib = UINib(nibName: "LoadMoreCell", bundle: nil)
        tbListFavourite.register(Nib, forCellReuseIdentifier: "loadmore")
        
        phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")!
        language = DatabaseManager.shared.getLanguage(phoneNumber: phoneNumber)
        
        list = DatabaseManager.shared.getFavouriteList(phoneNumber: phoneNumber, page: page)
        count = list.count

        tbListFavourite.delegate = self
        tbListFavourite.dataSource = self
        tbListFavourite.reloadData()
    }
    
}

extension FavouriteScreen: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return list.count
        } else if section == 1 {
            if count < 10 {
                return 0
            } else {
                return 1
            }
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell_2") as! ListNewsCell
            
            cell.lbTittleNew.text = list[indexPath.row].title.replacingOccurrences(of: "\\\\", with: "'")
            cell.lbDesNew.text = list[indexPath.row].description
            
            let formatDate = DateFormatter()
            cell.delegate = self
            
            formatDate.dateFormat = "E, dd MMM yyyy HH:mm:ss"
            cell.lbDateTime.text = list[indexPath.row].pubDate
            
            let dataDecoded: Data = Data(base64Encoded: list[indexPath.row].imgLink)!
            cell.imgNew.image = UIImage(data: dataDecoded)
            
            if DatabaseManager.shared.checkFavourite(tittle: cell.lbTittleNew.text!, phoneNumber: phoneNumber) {
                cell.btnFavourite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            } else {
                cell.btnFavourite.setImage(UIImage(systemName: "heart"), for: .normal)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadmore", for: indexPath) as! LoadMoreCell
            cell.indicator.startAnimating()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegateCate?.tableViewSelectCell(news: list[indexPath.row], bool: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == list.count - 2, !isLoading {
            loadMoreData()
        }
    }
    
    func loadMoreData() {
        if !isLoading {
            isLoading = true
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
                self.page = self.page + 10
                let listPlus = DatabaseManager.shared.getFavouriteList(phoneNumber: self.phoneNumber, page: self.page)
                self.count = listPlus.count
                self.list = self.list + listPlus
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.tbListFavourite.reloadData()
                }
            }
        }
    }
}
  
extension FavouriteScreen: ResetTable {

    func deleteFavourite(tittle: String) {
        let alert = UIAlertController(title: "Warning".LocalizedString(str: language), message: "Are you sure to delete this new from favourite?".LocalizedString(str: language), preferredStyle: .alert)
        
        let alertActionCancel = UIAlertAction(title: "Cancel".LocalizedString(str: language), style: .default, handler: { _ in })

        let alertActionOK = UIAlertAction(title: "Yes".LocalizedString(str: language), style: .destructive, handler: { _ in
            DatabaseManager.shared.deleteFavouriteRow(tittle: tittle, phoneNumber: self.phoneNumber)
            var index = 0
            for i in 0..<self.list.count {
                if self.list[i].title == tittle {
                    index = i
                    break
                }
            }
            self.list.remove(at: index)
            self.tbListFavourite.reloadData()
        })
        
        alert.addAction(alertActionCancel)
        alert.addAction(alertActionOK)
        
        self.present(alert, animated: true, completion: nil)
    }

}
