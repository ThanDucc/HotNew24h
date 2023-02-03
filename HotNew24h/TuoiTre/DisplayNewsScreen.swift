//
//  DisplayNewsScreen.swift
//  HotNew24h
//
//  Created by ThanDuc on 04/01/2023.
//

import UIKit
import WebKit

class DisplayNewsScreen: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var lbShare: UILabel!
    var news: News = News(title: "", pubDate: "", link: "", description: "", imgLink: "", htmlString: "")
    var language = ""
    var phoneNumber = ""
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var btnFavourite: UIButton!
    var delegate: ResetTable?
    @IBOutlet weak var imgShare: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.startAnimating()
        indicator.isHidden = false
        
        phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")!
        self.language = DatabaseManager.shared.getLanguage(phoneNumber: phoneNumber)
        
        lbShare.text = lbShare.text?.LocalizedString(str: language)
        
        if DatabaseManager.shared.checkFavourite(tittle: news.title, phoneNumber: phoneNumber) {
            btnFavourite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            btnFavourite.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        webView.navigationDelegate = self
        let urlRequest = URL(string: news.link)!
        let request = URLRequest(url: urlRequest)
        webView.load(request)
        
        indicator.stopAnimating()
        indicator.isHidden = true
        
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
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if let err = error as? URLError, err.code == .notConnectedToInternet {
            self.webView.loadHTMLString(news.htmlString, baseURL: nil)
            indicator.stopAnimating()
            indicator.isHidden = true
        }
    }
    
    @IBAction func btnFavouriteClick(_ sender: Any) {
        let tittle = news.title.replacingOccurrences(of: "'", with: "\\\\")
        if !DatabaseManager.shared.checkFavourite(tittle: tittle, phoneNumber: phoneNumber) {
            var htmlString = news.htmlString
            if htmlString.isEmpty {
                htmlString = try! String(contentsOf: URL(string: news.link)!)
            }
            DatabaseManager.shared.addToFavourite(phoneNumber: phoneNumber, title: tittle, pubDate: news.pubDate, description: news.description, imgLink: news.imgLink, htmlString: htmlString, link: news.link)
            self.btnFavourite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            DatabaseManager.shared.deleteFavouriteRow(tittle: tittle, phoneNumber: phoneNumber)
            self.btnFavourite.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }

}
