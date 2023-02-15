//
//  DeleteAcc.swift
//  HotNew24h
//
//  Created by ThanDuc on 18/01/2023.
//

import UIKit
import FirebaseAuth

protocol DeleteAccountClicked {
    func deleteAcc(status: Bool)
}

class DeleteAcc: UIViewController {

    @IBOutlet weak var lblDeleteAcc: UILabel!
    @IBOutlet weak var lblWarning: UILabel!
    @IBOutlet weak var tfSMSCode: UITextField!
    
    @IBOutlet weak var distance: NSLayoutConstraint!
    
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var bool = false
    var delegateDelete: DeleteAccountClicked?
    
    var language = ""
    let phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.isHidden = true

        DispatchQueue.global().async {
            let language = DatabaseManager.shared.getLanguage(phoneNumber: self.phoneNumber!)
            DispatchQueue.main.async {
                self.language = language
                self.lblWarning.text = self.lblWarning.text?.LocalizedString(str: language)
                self.lblDeleteAcc.text = self.lblDeleteAcc.text?.LocalizedString(str: language)
                self.tfSMSCode.placeholder = self.tfSMSCode.placeholder?.LocalizedString(str: language)
                self.btnYes.setTitle(self.btnYes.titleLabel?.text?.LocalizedString(str: language), for: .normal)
                self.btnCancel.setTitle(self.btnCancel.titleLabel?.text?.LocalizedString(str: language), for: .normal)
                self.lbStatus.text = self.lbStatus.text?.LocalizedString(str: language)
            }
        }

        tfSMSCode.isHidden = true
        distance.constant = 0
    }
    
    func sendSMS() {
        let phoneNumber = "\(self.phoneNumber ?? "")"

        AuthManager.shared.startAuth(phoneNumber: phoneNumber, completion: { success in
            guard success else {
                self.lbStatus.text = "Error to send SMS".LocalizedString(str: self.language)
                return
            }
            self.tfSMSCode.isHidden = false
            self.distance.constant = 35
        })
    }
    
    func deleteAcc() {
        DispatchQueue.global().async {
            DatabaseManager.shared.deleteUserRow(phoneNumber: self.phoneNumber!)
            DatabaseManager.shared.deleteFavouriteRow(phoneNumber: self.phoneNumber!)
            DatabaseManager.shared.deleteSeenRow(phoneNumber: self.phoneNumber!)
            DatabaseManager.shared.deleteCategory(phoneNumber: self.phoneNumber!)
            
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.lbStatus.text = "Delete account successfully!".LocalizedString(str: self.language)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                    self.delegateDelete?.deleteAcc(status: true)
                }
            }
        }
        
        Foundation.UserDefaults.standard.removeObject(forKey: "userPhoneNumber")
        Foundation.UserDefaults.standard.removeObject(forKey: "LOG_IN")
        
        LoginScreen.indexVNExCate = 0
        LoginScreen.indexYouthCate = 0
        MainViewController.type = ""
    }
    
    func deleteAccByPhoneNumber() {
        let smsCode = tfSMSCode.text
        AuthManager.shared.deleteAccountByPhoneNumber(smsCode: smsCode!, completion: { success in
            guard success else {
                self.lbStatus.text = "SMS is invalid!".LocalizedString(str: self.language)
                return
            }
            self.deleteAcc()
        })
    }
    
    func deleteAccByEmail() {
        AuthManager.shared.deleteAccountByEmail(completion: { success in
            guard success else {
                self.lbStatus.text = "Delete account failed".LocalizedString(str: self.language)
                return
            }
            self.deleteAcc()
        })
    }
    
    // SDK Android và iOS hiện không hỗ trợ tái xác thực.
    
    @IBAction func btnYesClicked(_ sender: Any) {
        let user = Auth.auth().currentUser
        if user?.phoneNumber != nil {
            if !bool {
                sendSMS()
                bool = true
            } else {
                indicator.startAnimating()
                indicator.isHidden = false
                deleteAccByPhoneNumber()
            }
        } else {
            indicator.startAnimating()
            indicator.isHidden = false
            deleteAccByEmail()
        }
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        self.delegateDelete?.deleteAcc(status: false)
    }
}
