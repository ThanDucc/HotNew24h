//
//  TuoiTreScreen.swift
//  HotNew24h
//
//  Created by ThanDuc on 04/01/2023.
//

import UIKit
import Foundation

protocol CategoryDelegate: AnyObject {
    func collectionViewSelectCell(index: Int)
    func tableViewSelectCell(news: News, bool: Bool)
}

protocol Index: AnyObject {
    func indexCategory(index: Int)
}

class TuoiTreScreen: UIViewController {
    var listTittle:[String] = []
    var listKeyURL:[String] = []
    
    var url = ""
    var screen = 0
    
    var list: [News] = []
    var language = ""
    var phoneNumber = ""
    
    var index: Int = 0
    
    @IBOutlet weak var cvCategory: UICollectionView!
    @IBOutlet weak var tbListTittle: UITableView!
    @IBOutlet weak var indicatior: UIActivityIndicatorView!
    
    let refreshControl = UIRefreshControl()
    
    weak var delegateCate: CategoryDelegate?
    weak var delegateIndex: Index?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")!
        self.language = DatabaseManager.shared.getLanguage(phoneNumber: phoneNumber)
        
        listTittle = DatabaseManager.shared.getListCategory(phoneNumber: phoneNumber)
        listKeyURL = DatabaseManager.shared.getListKeyUrl(phoneNumber: phoneNumber)

        listTittle.append("More")
        
        getAndDisplayData(index: index)

        cvCategory.dataSource = self
        cvCategory.delegate = self
        
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tbListTittle.addSubview(refreshControl)
        
        let nib = UINib(nibName: "ListTitleCell", bundle: nil)
        tbListTittle.register(nib, forCellReuseIdentifier: "Cell_2")
    }
    
    @objc func refresh(sender:AnyObject) {
        getAndDisplayData(index: index)
    }
    
    func getAndDisplayData(index: Int) {
        indicatior.startAnimating()
        indicatior.isHidden = false
        tbListTittle.dataSource = nil
        tbListTittle.delegate = nil
        tbListTittle.reloadData()
        
        switch screen {
        case 0:
            let xml = ParseXML()
            xml.getEpisode(urlString: url + listKeyURL[index] + ".rss", completion: { [self] success in
                if success {
                    self.update(list: xml.listNews)
                }
            })
            break
        default:
            let xml = ParseXML_VNExpress()
            xml.getEpisode(urlString: url + listKeyURL[index] + ".rss", completion: { [self] success in
                if success {
                    self.update(list: xml.listNews)
                }
            })
        }
    }
    
    func update(list: [News]) {
        DispatchQueue.main.async {
            self.list = list
            self.tbListTittle.dataSource = self
            self.tbListTittle.delegate = self
            self.tbListTittle.reloadData()
            self.indicatior.stopAnimating()
            self.indicatior.isHidden = true
            self.refreshControl.endRefreshing()
        }
    }
}

extension TuoiTreScreen: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell_2") as! ListNewsCell
        cell.delegate = self
        
        cell.lbTittleNew.text = list[indexPath.row].title
        cell.lbDesNew.text = list[indexPath.row].description
        
        let formatDate = DateFormatter()
        formatDate.dateFormat = "E, dd MMM yyyy HH:mm:ss"
        cell.lbDateTime.text = list[indexPath.row].pubDate
        
        if !list[indexPath.row].imgLink.isEmpty {
            let url: URL = URL(string: list[indexPath.row].imgLink)!
            let data: Data = try! Data(contentsOf: url)
            cell.imgNew.image = UIImage(data: data)
            cell.imgLink = UIImage(data: data)?.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
        }
    
        cell.new = list[indexPath.row]
        
        if DatabaseManager.shared.checkFavourite(tittle: cell.lbTittleNew.text!, phoneNumber: phoneNumber) {
            cell.btnFavourite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            cell.btnFavourite.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegateCate?.tableViewSelectCell(news: list[indexPath.row], bool: true)
        delegateIndex?.indexCategory(index: self.index)
    }
}
    
extension TuoiTreScreen: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listTittle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "COLLECTION", for: indexPath) as! CategoryTuoiTreCell
        if indexPath.row == index {
            cell.viewCell.backgroundColor = UIColor.red
        } else {
            cell.viewCell.backgroundColor = UIColor.systemTeal
        }
        cell.lbTittle.text = listTittle[indexPath.row].LocalizedString(str: language)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width/5.02, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != 10 {
            self.index = indexPath.row
        }
        self.cvCategory.reloadData()
        if indexPath.row != 10 {
            getAndDisplayData(index: indexPath.row)
        } else {
            delegateCate?.collectionViewSelectCell(index: indexPath.row)
        }
    }
    
}

extension TuoiTreScreen: ResetTable {
    func deleteFavourite(tittle: String) {
        DatabaseManager.shared.deleteFavouriteRow(tittle: tittle, phoneNumber: phoneNumber)
        tbListTittle.reloadData()
    }

}
