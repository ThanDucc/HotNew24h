//
//  DisplayNewsScreen.swift
//  HotNew24h
//
//  Created by ThanDuc on 04/01/2023.
//

import UIKit
import WebKit

protocol FavouriteChange {
    func favouriteChange(index: Int)
}

class DisplayNewsScreen: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var lbShare: UILabel!
    var news: News = News(title: "", pubDate: "", link: "", description: "", imgLink: "", htmlString: "")
    private var language = ""
    private var phoneNumber = ""
    var imgLink = ""
    var index = 0
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var btnFavourite: UIButton!
    @IBOutlet weak var imgShare: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    
    var delegateFavouriteChange: FavouriteChange?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.revealViewController()?.gestureEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.revealViewController()?.gestureEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.startAnimating()
        indicator.isHidden = false
        
        phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")!
        
        self.language = Foundation.UserDefaults.standard.string(forKey: "LanguageAllApp")!
        self.btnBack.setTitle(self.btnBack.titleLabel?.text?.LocalizedString(str: language), for: .normal)
        self.lbShare.text = self.lbShare.text?.LocalizedString(str: language)
       
        DispatchQueue.global().async {
            let check: Bool = DatabaseManager.shared.checkFavourite(tittle: self.news.title, phoneNumber: self.phoneNumber)
            DispatchQueue.main.async {
                if check {
                    self.btnFavourite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                } else {
                    self.btnFavourite.setImage(UIImage(systemName: "heart"), for: .normal)
                }
            }
        }
        
        webView.navigationDelegate = self
        DispatchQueue.global().async {
            let urlRequest = URL(string: self.news.link)!
            let request = URLRequest(url: urlRequest)
            DispatchQueue.main.async {
                self.webView.load(request)
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
            }
        }
        
        imgShare.isUserInteractionEnabled = true
        
        let tapFbGesture = UITapGestureRecognizer(target: self, action: #selector(tapImageShare(_:)))
        
        tapFbGesture.numberOfTapsRequired = 1
        tapFbGesture.numberOfTouchesRequired = 1
        imgShare.addGestureRecognizer(tapFbGesture)
    }
    
    @objc func tapImageShare(_ gesture: UITapGestureRecognizer) {
        let link = URL(string: news.link)!
        let activityViewController = UIActivityViewController(activityItems: [link], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if let err = error as? URLError, err.code == .notConnectedToInternet {
            self.webView.loadHTMLString(news.htmlString, baseURL: nil)
            indicator.stopAnimating()
            indicator.isHidden = true
        }
    }
    
    @IBAction func btnFavouriteClick(_ sender: Any) {
        let tittle = news.title.replacingOccurrences(of: "'", with: "\\\\")
        
        var img: String = ""
        if self.imgLink.contains("https") {
            let url: URL = URL(string: self.imgLink)!
            let data: Data = try! Data(contentsOf: url)
            img = UIImage(data: data)?.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
        } else {
            img = self.imgLink
        }
        
        DispatchQueue.global().async {
            let check = DatabaseManager.shared.checkFavourite(tittle: tittle, phoneNumber: self.phoneNumber)
            if !check {
                var htmlString = self.news.htmlString
                if htmlString.isEmpty {
                    htmlString = try! String(contentsOf: URL(string: self.news.link)!)
                }
                DatabaseManager.shared.addToFavourite(phoneNumber: self.phoneNumber, title: tittle, pubDate: self.news.pubDate, description: self.news.description, imgLink: img, htmlString: htmlString, link: self.news.link)

                DispatchQueue.main.async {
                    self.btnFavourite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    NotificationCenter.default.post(name: Notification.Name("Favourite Changed"), object: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.btnFavourite.setImage(UIImage(systemName: "heart"), for: .normal)
                    self.deleteFavourite(phoneNumber: self.phoneNumber, tittle: tittle, completion: { success in
                        if success {
                            DispatchQueue.main.async {
                                self.btnFavourite.setImage(UIImage(systemName: "heart"), for: .normal)
                                NotificationCenter.default.post(name: Notification.Name("Favourite Changed"), object: nil)
                            }
                        }
                    })
                }
            }
        }

    }
    
    func deleteFavourite(phoneNumber: String, tittle: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            DatabaseManager.shared.deleteFavouriteRow(tittle: tittle, phoneNumber: phoneNumber)
            completion(true)
        }
    }

}
