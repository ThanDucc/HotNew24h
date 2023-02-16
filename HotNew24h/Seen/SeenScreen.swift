//
//  SeenScreen.swift
//  HotNew24h
//
//  Created by ThanDuc on 10/01/2023.
//

import UIKit

class SeenScreen: UIViewController {

    @IBOutlet weak var tbSeenList: UITableView!
    @IBOutlet weak var btnShowMenu: UIButton!
    @IBOutlet weak var lbTittle: UILabel!
    
    var list: [News] = []
    weak var delegateCate: CategoryDelegate?
    var phoneNumber = ""
    var isLoading = false
    var language = ""
    var page = 0
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ListTitleCell", bundle: nil)
        tbSeenList.register(nib, forCellReuseIdentifier: "Cell_2")
        
        let Nib = UINib(nibName: "LoadMoreCell", bundle: nil)
        tbSeenList.register(Nib, forCellReuseIdentifier: "loadmore")
        
        tbSeenList.delegate = self
        tbSeenList.dataSource = self
        
        phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")!
        getLanguage(completion: { success in
            self.lbTittle.text = "Seen".LocalizedString(str: self.language)
            self.getSeenList()
        })
        
        btnShowMenu.addTarget(revealViewController(), action: #selector(self.revealViewController()?.revealSideMenu), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationLanguageReceived), name: Notification.Name("Language Changed"), object: nil)
                
        btnShowMenu.tintAdjustmentMode = .normal
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationFavouriteReceived), name: Notification.Name("Favourite Changed"), object: nil)
    }
    
    @objc func notificationFavouriteReceived() {
        tbSeenList.reloadData()
    }
    
    @objc func notificationLanguageReceived() {
        getLanguage(completion: { success in
            if success {
                self.lbTittle.text = "Seen".LocalizedString(str: self.language)
            }
        })
    }
    
    func getLanguage(completion: @escaping(Bool) -> Void) {
        self.language = Foundation.UserDefaults.standard.string(forKey: "LanguageAllApp")!
        completion(true)
    }
    
    func getSeenList() {
        self.page = 0
        DispatchQueue.global().async {
            let list = DatabaseManager.shared.getSeenList(phoneNumber: self.phoneNumber, page: self.page)
            DispatchQueue.main.async {
                self.list = list
                self.count = self.list.count
                self.tbSeenList.reloadData()
            }
        }
    }
}

extension SeenScreen: UITableViewDelegate, UITableViewDataSource {
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
            
            cell.indicator.startAnimating()
            cell.indicator.isHidden = false
            
            let formatDate = DateFormatter()
            
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
            
            cell.imgLink = list[indexPath.row].imgLink
            cell.new = list[indexPath.row]
            
            cell.btnFavourite.isHidden = true
            cell.indicatorFavourite.startAnimating()
            
            let lbTitleNew = cell.lbTittleNew.text!
            DispatchQueue.global().async {
                let check: Bool = DatabaseManager.shared.checkFavourite(tittle: lbTitleNew, phoneNumber: self.phoneNumber)
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
        
//        addSeenList(news: news, bool: bool)
        self.navigationController?.pushViewController(displayNewsScreen, animated: false)
        tbSeenList.deselectRow(at: indexPath, animated: false)
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
                let listPlus = DatabaseManager.shared.getSeenList(phoneNumber: self.phoneNumber, page: self.page)
                self.count = listPlus.count
                self.list = self.list + listPlus
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.tbSeenList.reloadData()
                }
            }
        }
    }
    
}
