//
//  TuoiTreScreen.swift
//  HotNew24h
//
//  Created by ThanDuc on 04/01/2023.
//

import UIKit
import Foundation

protocol CategoryDelegate: AnyObject {
    func clickMore()
    func tableViewSelectCell(news: News, bool: Bool)
}

class TuoiTreScreen: UIViewController {
    var listTittle:[String] = []
    var listURL:[String] = []
    var type: String = "Youth"
    let YOUTH = "Youth"
    let VNEXPRESS = "VNExpress"
    
    var list: [News] = []
    var language = ""
    var phoneNumber = ""
    
    var index: Int = 0
    
    @IBOutlet weak var cvCategory: UICollectionView!
    @IBOutlet weak var tbListTittle: UITableView!
    @IBOutlet weak var indicatior: UIActivityIndicatorView!
    @IBOutlet weak var lbTittle: UILabel!
    @IBOutlet weak var btnShowMenu: UIButton!
    
    let refreshControl = UIRefreshControl()
    
    weak var delegateCate: CategoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if MainViewController.type != "" {
            type = MainViewController.type
        }
        
        phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")!
        getLanguage(completion: { success in
            if success {
                self.getListCategory(completion: { success in
                    DispatchQueue.main.async {
                        self.getAndDisplayData(index: self.index, indicatorHidden: true)
                        self.cvCategory.scrollToItem(at:IndexPath(item: self.index, section: 0), at: .centeredHorizontally, animated: false)
                    }
                })
                if self.type == self.YOUTH {
                    self.lbTittle.text = "Youth".LocalizedString(str: self.language)
                    self.index = LoginScreen.indexYouthCate
                } else if self.type == self.VNEXPRESS {
                    self.lbTittle.text = "VNExpress".LocalizedString(str: self.language)
                    self.index = LoginScreen.indexVNExCate
                }
            }
        })
        
        self.tbListTittle.dataSource = self
        self.tbListTittle.delegate = self
        
        let nib = UINib(nibName: "ListTitleCell", bundle: nil)
        tbListTittle.register(nib, forCellReuseIdentifier: "Cell_2")
        
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tbListTittle.addSubview(refreshControl)
        
        btnShowMenu.addTarget(revealViewController(), action: #selector(self.revealViewController()?.revealSideMenu), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived), name: Notification.Name("Language Changed"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationFavouriteReceived), name: Notification.Name("Favourite Changed"), object: nil)
    }
    
    @objc func notificationFavouriteReceived() {
        tbListTittle.reloadData()
    }
    
    @objc func notificationReceived() {
        getLanguage(completion: { success in
            if success {
                self.cvCategory.reloadData()
                self.lbTittle.text = self.lbTittle.text!.LocalizedString(str: self.language)
            }
        })
    }
    
    // pull to refresh data
    @objc func refresh(sender: AnyObject) {
        self.indicatior.stopAnimating()
        self.indicatior.isHidden = true
        getAndDisplayData(index: index, indicatorHidden: false)
    }
    
    func getLanguage(completion: @escaping(Bool) -> Void) {
        // get language
        DispatchQueue.global().async {
            let language = DatabaseManager.shared.getLanguage(phoneNumber: self.phoneNumber)
            DispatchQueue.main.async {
                self.language = language
                completion(true)
            }
        }
    }
    
    // get list category
    func getListCategory(completion: @escaping(Bool) -> Void) {
        listTittle = []
        listURL = []
        
        DispatchQueue.global().async {
            let category: [CategoryDatabase] = DatabaseManager.shared.getListCategory(phoneNumber: self.phoneNumber, type: self.type)
            for i in 0..<category.count {
                if category[i].isHidden == "false" {
                    self.listTittle.append(category[i].name)
                    self.listURL.append(category[i].linkCategory)
                }
            }
            self.listTittle.append("More")
            DispatchQueue.main.async {
                self.cvCategory.dataSource = self
                self.cvCategory.delegate = self
                self.cvCategory.reloadData()
                completion(true)
            }
        }
    }
    
    // when user click a category, we get the index and display table with index
    func getAndDisplayData(index: Int, indicatorHidden: Bool) {
        if indicatorHidden {
            indicatior.startAnimating()
            indicatior.isHidden = false
        }
        list = []
        tbListTittle.reloadData()
        
        DispatchQueue.global().async {
            switch self.type {
            case "Youth":
                let xml = ParseXML()
                xml.getEpisode(urlString: self.listURL[index], completion: { [self] success in
                    if success {
                        self.update(list: xml.listNews)
                    }
                })
                break
            default:
                let xml = ParseXML_VNExpress()
                xml.getEpisode(urlString: self.listURL[index], completion: { [self] success in
                    if success {
                        self.update(list: xml.listNews)
                    }
                })
            }
        }
        
    }
    
    func update(list: [News]) {
        DispatchQueue.main.async {
            self.list = list
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
    
    // display a new include: title, description, image, date time
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell_2") as! ListNewsCell
        
        cell.lbTittleNew.text = list[indexPath.row].title
        cell.lbDesNew.text = list[indexPath.row].description
        
        let formatDate = DateFormatter()
        formatDate.dateFormat = "E, dd MMM yyyy HH:mm:ss"
        cell.lbDateTime.text = list[indexPath.row].pubDate
        
        cell.imgNew.image = nil
        cell.indicator.startAnimating()
        cell.indicator.isHidden = false
        
        if !list[indexPath.row].imgLink.isEmpty {
            DispatchQueue.global().async {
                let url: URL = URL(string: self.list[indexPath.row].imgLink)!
                var data: Data?
                do {
                    data = try Data(contentsOf: url)
                } catch {
                    print("Error load image")
                }
                DispatchQueue.main.async {
                    cell.indicator.stopAnimating()
                    cell.indicator.isHidden = true
                    if data != nil {
                        cell.imgNew.image = UIImage(data: data!)
                        cell.imgLink = UIImage(data: data!)?.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
                    }
                }
            }
        }
    
        cell.new = list[indexPath.row]
        cell.btnFavourite.isHidden = true
        cell.indicatorFavourite.startAnimating()
        
        let lbTittleNew = cell.lbTittleNew.text!
        
        DispatchQueue.global().async {
            let check: Bool = DatabaseManager.shared.checkFavourite(tittle: lbTittleNew, phoneNumber: self.phoneNumber)
            DispatchQueue.main.async {
                cell.indicatorFavourite.stopAnimating()
                cell.btnFavourite.isHidden = false
                if check {
                    cell.btnFavourite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                } else {
                    cell.btnFavourite.setImage(UIImage(systemName: "heart"), for: .normal)
                }
            }
        }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let displayNewsScreen = self.storyboard?.instantiateViewController(withIdentifier: "displaySC") as! DisplayNewsScreen
        displayNewsScreen.news = list[indexPath.row]
        
        if !list[indexPath.row].imgLink.isEmpty {
            DispatchQueue.global().async {
                let url: URL = URL(string: self.list[indexPath.row].imgLink)!
                var data: Data?
                do {
                    data = try Data(contentsOf: url)
                } catch {
                    print("Error load image")
                }
                DispatchQueue.main.async {
                    if data != nil {
                        displayNewsScreen.imgLink = UIImage(data: data!)?.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
                        self.navigationController?.pushViewController(displayNewsScreen, animated: false)
                    }
                }
            }
        }
        addSeenList(news: list[indexPath.row])
        tbListTittle.deselectRow(at: indexPath, animated: false)
    }
    
    func addSeenList(news: News) {
        var imgLink: String = ""
        if news.imgLink.contains("https") {
            let url: URL = URL(string: news.imgLink)!
            let data: Data = try! Data(contentsOf: url)
            imgLink = UIImage(data: data)?.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
        }
        
        var htmlString = ""
        htmlString = try! String(contentsOf: URL(string: news.link)!) 

        let tittle = news.title.replacingOccurrences(of: "'", with: "\\\\")
        
        DispatchQueue.global().async {
            let check = DatabaseManager.shared.checkSeen(tittle: news.title, phoneNumber: self.phoneNumber)
            if check {
                DatabaseManager.shared.deleteSeenRow(tittle: news.title, phoneNumber: self.phoneNumber)
                DatabaseManager.shared.addToSeen(phoneNumber: self.phoneNumber, title: tittle, pubDate: news.pubDate, description: news.description, imgLink: imgLink, htmlString: htmlString, link: news.link)
            } else {
                DatabaseManager.shared.addToSeen(phoneNumber: self.phoneNumber, title: tittle, pubDate: news.pubDate, description: news.description, imgLink: imgLink, htmlString: htmlString, link: news.link)
            }
        }
    }
    
}
    
extension TuoiTreScreen: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listTittle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "COLLECTION", for: indexPath) as! CategoryTuoiTreCell
        
        // if category clicked, change the background color of category
        if indexPath.row == index {
            cell.viewCell.backgroundColor = #colorLiteral(red: 1, green: 0.4552601329, blue: 0, alpha: 1)
        } else {
            cell.viewCell.backgroundColor = #colorLiteral(red: 0, green: 0.5949241789, blue: 1, alpha: 1)
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
    
    // check if category clicked != more, assign index = indexPath.row
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != (listTittle.count - 1) {
            self.index = indexPath.row
        }
        self.cvCategory.reloadData()
        
        if self.type == self.YOUTH {
            LoginScreen.indexYouthCate = self.index
        } else if self.type == self.VNEXPRESS {
            LoginScreen.indexVNExCate = self.index
        }
        
        // if category != more, display data by index
        if indexPath.row != (listTittle.count - 1) {
            getAndDisplayData(index: indexPath.row, indicatorHidden: true)
        } else {
            // case click more, display sort Category screen
            let sortCateScreen = self.storyboard?.instantiateViewController(withIdentifier: "sortCate") as! SortCategoryTuoiTre
            sortCateScreen.type = type
            sortCateScreen.delegateSortCate = self
            sortCateScreen.nameCate = listTittle[index]
            self.navigationController?.pushViewController(sortCateScreen, animated: true)
        }
    }
    
}

extension TuoiTreScreen: UpdateCategory {
    
    func update(nameCate: String) {
        getListCategory(completion: { [self] success in
            if let newIndex = self.listTittle.firstIndex(of: nameCate) {
                self.index = newIndex
            } else {
                self.index = 0
                self.getAndDisplayData(index: self.index, indicatorHidden: true)
            }
            self.cvCategory.reloadData()
            self.cvCategory.scrollToItem(at:IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
        })
    }
}
