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
        
        self.language = DatabaseManager.shared.getLanguage(phoneNumber: phoneNumber!)

        switch language {
        case "en":
            english()
        default:
            vietnamese()
        }
        updateLanguage()
    }

    @IBAction func btnEnglishClicked(_ sender: Any) {
        switch language {
        case "vi":
            english()
            DatabaseManager.shared.updateLanguage(phoneNumber: phoneNumber!, language: "en")
            self.language = "en"
            updateLanguage()
            delegateLang?.updateLangugeAll()
        default:
            break   
        }
    }
    
    @IBAction func btnVietnameseClicked(_ sender: Any) {
        switch language {
        case "en":
            vietnamese()
            DatabaseManager.shared.updateLanguage(phoneNumber: phoneNumber!, language: "vi")
            self.language = "vi"
            updateLanguage()
            delegateLang?.updateLangugeAll()
        default:
            break
        }
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
    }
    
}
