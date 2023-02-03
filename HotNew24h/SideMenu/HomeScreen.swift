//
//  HomeScreen.swift
//  HotNew24h
//
//  Created by ThanDuc on 28/12/2022.
//

import UIKit
import FirebaseAuth

private struct Constant {
    static let widthNotificationView = UIScreen.main.bounds.width * 3 / 4
}

class HomeScreen: UIViewController {
    
    @IBOutlet weak var lbTittle: UILabel!
    @IBOutlet weak var viewForChange: UIView!
    @IBOutlet private var blurMenuView: UIView!
    @IBOutlet private var openMenuButton: UIButton!
    @IBOutlet private var menuViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private var menuView: UIView!
    
    @IBOutlet weak var btnBack: UIButton!
    
    var screen: Int = 4
    var language = ""
    var item = ""
    var phoneNumber = ""
    var index = 0
    
    private var isOpenMenu = false
    private var beginPoint: CGFloat = 0
    private var difference: CGFloat = 0

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        menuView.isHidden = true
        menuViewTrailingConstraint.constant = -Constant.widthNotificationView
        blurMenuView.isHidden = true
        
        phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")!
        self.language = DatabaseManager.shared.getLanguage(phoneNumber: phoneNumber)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        lbTittle.text = "Home".LocalizedString(str: language)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipeRight.direction = .right
        swipeRight.view?.isUserInteractionEnabled = true
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeft.direction = .left
        swipeLeft.view?.isUserInteractionEnabled = true
        
        viewForChange.addGestureRecognizer(swipeLeft)
        viewForChange.addGestureRecognizer(swipeRight)
        
        btnBack.isHidden = true
        
        lbTittle.text = "Youth".LocalizedString(str: language)
        removeSubView()
        screen = 0
        changeYouthScreen(screen: 0, index: 0)
    
    }

    private func setUpUI(list: [String]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let menuController = storyboard.instantiateViewController(identifier: "MenuController") as? SideMenu else {
            return
        }

        menuController.delegate = self
        menuController.view.frame = menuView.bounds
        menuController.list = list
        menuView.addSubview(menuController.view)
        addChild(menuController)
        menuController.didMove(toParent: self)
    }
    
    @IBAction private func openMenuButtonTapped(_ sender: Any) {
        displayMenu()
    }
    
    func displayMenu() {
        setUpUI(list: ["Youth", "VNExpress", "Favourite", "Seen", "Settings", "About App", "Contact us"])
        menuView.isHidden = false
        isOpenMenu.toggle()
        blurMenuView.alpha = isOpenMenu ? 0.5 : 0
        blurMenuView.isHidden = !isOpenMenu
        UIView.animate(withDuration: 0.2) {
            self.menuViewTrailingConstraint.constant = self.isOpenMenu ? 0 : -(UIScreen.main.bounds.width * 3 / 4)
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        removeSubView()
        btnBack.isHidden = true
        
        switch screen {
        case 0:
            changeYouthScreen(screen: 0, index: self.index)
        case 1:
            changeYouthScreen(screen: 1, index: self.index)
        case 2:
            changeFavouriteScreen()
        case 3:
            changeSeenScreen()
        default:
            changeYouthScreen(screen: 0, index: 0)
        }
    }
    
    @objc func swipeRight(_ gesture: UISwipeGestureRecognizer) {
        displayMenu()
    }
    
    @objc func swipeLeft(_ gesture: UISwipeGestureRecognizer) {
        displayNotification(isShown: false)
    }
    
    func removeSubView() {
        for subView in viewForChange.subviews {
            subView.removeFromSuperview()
        }
    }
    
}

extension HomeScreen {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isOpenMenu {
            if difference == 0, let touch = touches.first {
                let location = touch.location(in: blurMenuView)
                if !menuView.frame.contains(location) {
                    displayNotification(isShown: false)
                }
            }
        }
        difference = 0
    }
    
    private func displayNotification(isShown: Bool) {
        blurMenuView.alpha = isShown ? 0.5 : 0
        blurMenuView.isHidden = !isShown
        UIView.animate(withDuration: 0.2) {
            self.menuViewTrailingConstraint.constant = isShown ? 0 : -Constant.widthNotificationView
            self.view.layoutIfNeeded()
        }
        isOpenMenu = isShown
    }
    
    func addSeenList(news: News, bool: Bool) {
        var htmlString = ""
        if bool {
            let url: URL = URL(string: news.imgLink)!
            let data: Data = try! Data(contentsOf: url)
            news.imgLink = UIImage(data: data)?.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
            htmlString = try! String(contentsOf: URL(string: news.link)!)
        } else {
            htmlString = news.htmlString
        }
            
        let tittle = news.title.replacingOccurrences(of: "'", with: "\\\\")
        if DatabaseManager.shared.checkSeen(tittle: news.title, phoneNumber: phoneNumber) {
            DatabaseManager.shared.deleteSeenRow(tittle: news.title, phoneNumber: phoneNumber)
        }
        
        let phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")!
        DatabaseManager.shared.addToSeen(phoneNumber: phoneNumber, title: tittle, pubDate: news.pubDate, description: news.description, imgLink: news.imgLink, htmlString: htmlString, link: news.link)
    }
    
    func changeYouthScreen(screen: Int, index: Int) {
        let tuoitreScreen = self.storyboard?.instantiateViewController(withIdentifier: "tuoitre") as! TuoiTreScreen
        switch screen {
        case 0:
            tuoitreScreen.url = "https://tuoitre.vn/rss/"
        default:
            tuoitreScreen.url = "https://vnexpress.net/rss/"
        }
        tuoitreScreen.index = index
        tuoitreScreen.screen = screen
        viewForChange.addSubview(tuoitreScreen.view)
        
        tuoitreScreen.delegateCate = self
        tuoitreScreen.delegateIndex = self
        
        tuoitreScreen.view.frame = viewForChange.bounds
        addChild(tuoitreScreen)
        tuoitreScreen.didMove(toParent: self)
    }
    
    func changeFavouriteScreen() {
        let favouriteScreen = self.storyboard?.instantiateViewController(withIdentifier: "favourite") as! FavouriteScreen
        favouriteScreen.delegateCate = self
        viewForChange.addSubview(favouriteScreen.view)
        favouriteScreen.view.frame = viewForChange.bounds
        addChild(favouriteScreen)
        favouriteScreen.didMove(toParent: self)
    }
    
    func changeSeenScreen() {
        let seenScreen = self.storyboard?.instantiateViewController(withIdentifier: "seen") as! SeenScreen
        seenScreen.delegateCate = self
        viewForChange.addSubview(seenScreen.view)
        seenScreen.view.frame = viewForChange.bounds
        addChild(seenScreen)
        seenScreen.didMove(toParent: self)
    }
    
    func changeLoginScreen() {
        let login = self.navigationController?.storyboard?.instantiateViewController(withIdentifier: "login") as! LoginScreen
        self.navigationController?.pushViewController(login, animated: true)
    }
    
    func showLanguageSetting() {
        let viewControllerToPresent = self.storyboard?.instantiateViewController(withIdentifier: "language") as! Language
        viewControllerToPresent.delegateLang = self
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.preferredCornerRadius = 30.0
        }
        present(viewControllerToPresent, animated: true, completion: nil)
    }
    
    func showDeleteAccount() {
        let viewControllerToPresent = self.storyboard?.instantiateViewController(withIdentifier: "deleteAcc") as! DeleteAcc
        viewControllerToPresent.delegateDelete = self
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.preferredCornerRadius = 30.0
        }
        present(viewControllerToPresent, animated: true, completion: nil)
    }
}

extension HomeScreen: MenuDelegate {
    func selectMenuItem(with item: String) {
        self.item = item
        btnBack.isHidden = true
        
        switch item {
        case "Youth":
            lbTittle.text = item.LocalizedString(str: language)
            removeSubView()
            screen = 0
            changeYouthScreen(screen: 0, index: 0)
            close()
        case "VNExpress":
            lbTittle.text = item.LocalizedString(str: language)
            removeSubView()
            screen = 1
            changeYouthScreen(screen: 1, index: 0)
            close()
        case "Favourite":
            lbTittle.text = item.LocalizedString(str: language)
            removeSubView()
            screen = 2
            changeFavouriteScreen()
            close()
        case "Seen":
            lbTittle.text = item.LocalizedString(str: language)
            removeSubView()
            screen = 3
            changeSeenScreen()
            close()
        case "Settings":
            setUpUI(list: ["Language", "Delete account", "Log out"])
        case "Delete account":
            showDeleteAccount()
        case "Language":
            showLanguageSetting()
        case "Log out":
            changeLoginScreen()
            if Auth.auth().currentUser != nil {
                AuthManager.shared.logOut()
            }
        default:
            lbTittle.text = item.LocalizedString(str: language)
            removeSubView()
            close()
            screen = 0
        }
    }
    
    func close() {
        displayNotification(isShown: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for subView in self.menuView.subviews {
                subView.removeFromSuperview()
            }
        }
    }
}

extension HomeScreen: CategoryDelegate {
    
    func tableViewSelectCell(news: News, bool: Bool) {
        removeSubView()
        let displayNewsScreen = self.storyboard?.instantiateViewController(withIdentifier: "displaySC") as! DisplayNewsScreen
        displayNewsScreen.news = news

        addSeenList(news: news, bool: bool)
        viewForChange.addSubview(displayNewsScreen.view)
        
        btnBack.isHidden = false

        displayNewsScreen.view.frame = viewForChange.bounds
        addChild(displayNewsScreen)
        displayNewsScreen.didMove(toParent: self)
    }
    
    func collectionViewSelectCell(index: Int) {
        if index == 10 {
            let sortCateScreen = self.storyboard?.instantiateViewController(withIdentifier: "sortCate") as! SortCategoryTuoiTre
            self.navigationController?.pushViewController(sortCateScreen, animated: true)
        }
    }
}

extension HomeScreen: UpdateLanguge {
    func updateLangugeAll() {
        self.language = DatabaseManager.shared.getLanguage(phoneNumber: phoneNumber)
        lbTittle.text = lbTittle.text?.LocalizedString(str: language)
        setUpUI(list: ["Language", "Delete account", "Log out"])
        switch screen {
        case 0:
            changeYouthScreen(screen: 0, index: 0)
        case 1:
            changeYouthScreen(screen: 1, index: 0)
        case 2:
            changeFavouriteScreen()
        case 3:
            changeSeenScreen()
        default:
            removeSubView()
        }
    }
}

extension HomeScreen: Index {
    func indexCategory(index: Int) {
        self.index = index
    }
}

extension HomeScreen: DeleteAccountClicked {
    func deleteAcc(status: Bool) {
        dismiss(animated: true, completion: nil)
        if status {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.changeLoginScreen()
            }
        }
    }
    
}
