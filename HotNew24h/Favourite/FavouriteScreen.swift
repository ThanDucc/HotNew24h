//
//  FavouriteScreen.swift
//  HotNew24h
//
//  Created by ThanDuc on 04/01/2023.
//

import UIKit

class FavouriteScreen: UIViewController {

    @IBOutlet weak var tbListFavourite: UITableView!
    @IBOutlet weak var btnShowMenu: UIButton!
    @IBOutlet weak var lbTittle: UILabel!
    var list: [News] = []
    weak var delegateCate: CategoryDelegate?
    private var phoneNumber = ""
    private var language = ""
    private var isLoading = false
    private var page = 0
    private var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ListTitleCell", bundle: nil)
        tbListFavourite.register(nib, forCellReuseIdentifier: "Cell_2")
        
        let Nib = UINib(nibName: "LoadMoreCell", bundle: nil)
        tbListFavourite.register(Nib, forCellReuseIdentifier: "loadmore")
        
        self.tbListFavourite.delegate = self
        self.tbListFavourite.dataSource = self
        
        phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")!
        getLanguage(completion: { success in
            self.lbTittle.text = "Favourite".LocalizedString(str: self.language)
            self.getFavouriteList()
        })
        
        btnShowMenu.addTarget(revealViewController(), action: #selector(self.revealViewController()?.revealSideMenu), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationLanguageReceived), name: Notification.Name("Language Changed"), object: nil)
        
        btnShowMenu.tintAdjustmentMode = .normal
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationFavouriteReceived), name: Notification.Name("Favourite Changed"), object: nil)
    }
    
    @objc func notificationFavouriteReceived() {
        self.getFavouriteList()
    }
    
    @objc func notificationLanguageReceived() {
        getLanguage(completion: { success in
            if success {
                self.lbTittle.text = "Favourite".LocalizedString(str: self.language)
            }
        })
    }
    
    func getLanguage(completion: @escaping(Bool) -> Void) {
        self.language = Foundation.UserDefaults.standard.string(forKey: "LanguageAllApp")!
        completion(true)
    }
    
    func getFavouriteList() {
        self.page = 0
        DispatchQueue.global().async {
            let list = DatabaseManager.shared.getFavouriteList(phoneNumber: self.phoneNumber, page: self.page)
            DispatchQueue.main.async {
                self.list = list
                self.count = self.list.count
                self.tbListFavourite.reloadData()
            }
        }
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
            
            cell.indicator.startAnimating()
            cell.indicator.isHidden = false
            
            formatDate.dateFormat = "E, dd MMM yyyy HH:mm:ss"
            cell.lbDateTime.text = list[indexPath.row].pubDate
            
            if !list[indexPath.row].imgLink.isEmpty {
                let dataDecoded: Data = Data(base64Encoded: list[indexPath.row].imgLink)!
                cell.imgNew.image = UIImage(data: dataDecoded)
            } else {
                cell.imgNew.image = UIImage(named: "default")
            }
            cell.indicator.stopAnimating()
            cell.indicator.isHidden = true
            
            cell.new = list[indexPath.row]

            cell.btnFavourite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            
            cell.screen = "Favourite"
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.white
            cell.selectedBackgroundView = backgroundView
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadmore", for: indexPath) as! LoadMoreCell
            cell.indicator.startAnimating()
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.white
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let displayNewsScreen = self.storyboard?.instantiateViewController(withIdentifier: "displaySC") as! DisplayNewsScreen
        displayNewsScreen.news = list[indexPath.row]
        displayNewsScreen.imgLink = list[indexPath.row].imgLink
        addSeenList(news: list[indexPath.row])
        
        self.navigationController?.pushViewController(displayNewsScreen, animated: false)
        tbListFavourite.deselectRow(at: indexPath, animated: false)

    }
    
    func addSeenList(news: News) {
        let tittle = news.title.replacingOccurrences(of: "'", with: "\\\\")
        
        DispatchQueue.global().async {
            let check = DatabaseManager.shared.checkSeen(tittle: news.title, phoneNumber: self.phoneNumber)
            if check {
                DatabaseManager.shared.deleteSeenRow(tittle: news.title, phoneNumber: self.phoneNumber)
                DatabaseManager.shared.addToSeen(phoneNumber: self.phoneNumber, title: tittle, pubDate: news.pubDate, description: news.description, imgLink: news.imgLink, htmlString: news.htmlString, link: news.link)
            } else {
                DatabaseManager.shared.addToSeen(phoneNumber: self.phoneNumber, title: tittle, pubDate: news.pubDate, description: news.description, imgLink: news.imgLink, htmlString: news.htmlString, link: news.link)
            }
        }
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
            DispatchQueue.global().async(execute: {
                DatabaseManager.shared.deleteFavouriteRow(tittle: tittle, phoneNumber: self.phoneNumber)
            })
            
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
