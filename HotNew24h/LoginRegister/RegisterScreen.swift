//
//  RegisterScreen.swift
//  HotNew24h
//
//  Created by ThanDuc on 22/12/2022.
//

import UIKit
import FirebaseAuth

class RegisterScreen: UIViewController {

    @IBOutlet weak var lbRegisterTittle: UILabel!
    @IBOutlet weak var lbPhoneNumber: UILabel!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var lbSMSCode: UILabel!
    @IBOutlet weak var tfSMSCode: UITextField!
    @IBOutlet weak var btnEnter: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var btnHadAcc: UIButton!
    
    let defaults = Foundation.UserDefaults.standard
    var language = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get phone number to get languge to display UI
        let phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")
        if phoneNumber == nil {
            language = "en"
            self.setupUI()
        } else {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            let language = DatabaseManager.shared.getLanguage(phoneNumber: phoneNumber!)
            dispatchGroup.leave()
            dispatchGroup.notify(queue: .main, execute: {
                self.language = language
                self.setupUI()
            })
        }
    }
    
    func setupUI() {
        lbPhoneNumber.isHidden = true
        lbSMSCode.isHidden = true
        
        btnRegister.layer.cornerRadius = 5
        btnRegister.backgroundColor = UIColor.systemGray4
        
        btnEnter.isHidden = true
        
        lbRegisterTittle.text = lbRegisterTittle.text?.LocalizedString(str: language)
        lbPhoneNumber.text = lbPhoneNumber.text?.LocalizedString(str: language)
        tfPhoneNumber.placeholder = tfPhoneNumber.placeholder?.LocalizedString(str: language)
        lbSMSCode.text = lbSMSCode.text?.LocalizedString(str: language)
        tfSMSCode.placeholder = tfSMSCode.placeholder?.LocalizedString(str: language)
        btnRegister.setTitle(btnRegister.titleLabel?.text?.LocalizedString(str: language), for: .normal)
        btnHadAcc.setTitle(btnHadAcc.titleLabel?.text?.LocalizedString(str: language), for: .normal)
    }
    
    @IBAction func lbPhoneNumberHidden(_ sender: Any) {
        if (tfPhoneNumber.text == "") {
            lbPhoneNumber.isHidden = true
            btnRegister.backgroundColor = UIColor.systemGray4
            lbStatus.text = ""
            btnEnter.isHidden = true
        } else {
            btnEnter.isHidden = false
            lbPhoneNumber.isHidden = false
            if(!tfSMSCode.text!.isEmpty) {
                btnRegister.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.3841883486, alpha: 1)
            }
        }
    }
    
    @IBAction func lbSMSHidden(_ sender: Any) {
        if (tfSMSCode.text == "") {
            lbSMSCode.isHidden = true
            btnRegister.backgroundColor = UIColor.systemGray4
            lbStatus.text = ""
        } else {
            lbSMSCode.isHidden = false
            if(!tfPhoneNumber.text!.isEmpty) {
                btnRegister.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.3841883486, alpha: 1)
            }
        }
    }
    
    @IBAction func enter(_ sender: Any) {
        lbStatus.text = ""
        let phoneNumber = "\(tfPhoneNumber.text!)"
        if isValidPhone(phone: phoneNumber) {
            if !DatabaseManager.shared.checkPhoneNumber(phoneNumber: phoneNumber) {
                AuthManager.shared.startAuth(phoneNumber: phoneNumber, completion: { success in
                    guard success else {
                        self.lbStatus.text = "Your phone number is invalid!".LocalizedString(str: self.language)
                        return
                    }
                })
            } else {
                self.lbStatus.text = "Your phone number existed!".LocalizedString(str: self.language)
            }
        } else {
            lbStatus.text = "Your phone number is invalid!".LocalizedString(str: language)
        }
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        let code = tfSMSCode.text!
        if !tfPhoneNumber.text!.isEmpty && !tfSMSCode.text!.isEmpty {
            AuthManager.shared.verifyCode(smsCode: code, completion: { success in
                if !success {
                    self.lbStatus.text = "SMS code is incorrect!".LocalizedString(str: self.language)
                } else {
                    self.lbStatus.text = "Register successfully!".LocalizedString(str: self.language)
                    self.defaults.set(self.tfPhoneNumber.text!, forKey: "userPhoneNumber")
                    
                    Register().registerAccount(userId: self.tfPhoneNumber.text!)
                    Foundation.UserDefaults.standard.set(true, forKey: "LOG_IN")
                                                        
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        let mainScreen = self.storyboard?.instantiateViewController(withIdentifier: "mainScreen") as! MainViewController
                        self.navigationController?.pushViewController(mainScreen, animated: true)
                    }
                }
            })
        }
    }
    
    func isValidPhone(phone: String) -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phone)
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
