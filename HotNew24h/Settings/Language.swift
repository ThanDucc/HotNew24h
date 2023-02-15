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
        
        DispatchQueue.global().async {
            let language = DatabaseManager.shared.getLanguage(phoneNumber: self.phoneNumber!)
            DispatchQueue.main.async {
                self.language = language
                switch language {
                case "en":
                    self.english()
                default:
                    self.vietnamese()
                }
                self.updateLanguage()
            }
        }
    }

    @IBAction func btnEnglishClicked(_ sender: Any) {
        changeLanguage()
    }
    
    @IBAction func btnVietnameseClicked(_ sender: Any) {
        changeLanguage()
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
        DispatchQueue.global().async {
            DatabaseManager.shared.updateLanguage(phoneNumber: self.phoneNumber!, language: self.language)
            DispatchQueue.main.async {
                self.delegateLang?.updateLangugeAll()
            }
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
