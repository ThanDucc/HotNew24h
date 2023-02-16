//
//  Language.swift
//  HotNew24h
//
//  Created by ThanDuc on 11/01/2023.
//

import UIKit
import FacebookLogin

protocol UpdateLanguge {
    func updateLangugeAll()
}

class Language: UIViewController {
    
    var language = ""
    let phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")
    
    @IBOutlet weak var btnVietnamese: UIButton!
    @IBOutlet weak var btnEnglish: UIButton!
    @IBOutlet weak var lbEnglish: UILabel!
    @IBOutlet weak var lbVietnamese: UILabel!
    @IBOutlet weak var lbLanguage: UILabel!
    
    var delegateLang: UpdateLanguge?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.language = Foundation.UserDefaults.standard.string(forKey: "LanguageAllApp")!
        switch language {
        case "en":
            self.english()
        default:
            self.vietnamese()
        }
        self.updateLanguage()
    }

    @IBAction func btnEnglishClicked(_ sender: Any) {
        if self.language == "vi" {
            changeLanguage()
        }
    }
    
    @IBAction func btnVietnameseClicked(_ sender: Any) {
        if self.language == "en" {
            changeLanguage()
        }
    }
    
    func changeLanguage() {
        switch self.language {
        case "vi":
            english()
            self.language = "en"
        default:
            vietnamese()
            self.language = "vi"
        }
        updateLanguage()
        self.delegateLang?.updateLangugeAll()
    }
    
    func english() {
        btnEnglish.setImage(UIImage(systemName: "record.circle.fill"), for: .normal)
        btnVietnamese.setImage(UIImage(systemName: "circle"), for: .normal)
    }
    
    func vietnamese() {
        btnVietnamese.setImage(UIImage(systemName: "record.circle.fill"), for: .normal)
        btnEnglish.setImage(UIImage(systemName: "circle"), for: .normal)
    }
    
    func updateLanguage() {
        lbVietnamese.text = lbVietnamese.text?.LocalizedString(str: language)
        lbEnglish.text = lbEnglish.text?.LocalizedString(str: language)
        lbLanguage.text = lbLanguage.text?.LocalizedString(str: language)
        Foundation.UserDefaults.standard.set(language, forKey: "LanguageAllApp")
    }
    
}
