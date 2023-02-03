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
    
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    var bool = false
    var delegateDelete: DeleteAccountClicked?
    
    var language = ""
    let phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.language = DatabaseManager.shared.getLanguage(phoneNumber: phoneNumber!)
        lblWarning.text = lblWarning.text?.LocalizedString(str: language)
        lblDeleteAcc.text = lblDeleteAcc.text?.LocalizedString(str: language)
        tfSMSCode.placeholder = tfSMSCode.placeholder?.LocalizedString(str: language)
        btnYes.setTitle(btnYes.titleLabel?.text?.LocalizedString(str: language), for: .normal)
        btnCancel.setTitle(btnCancel.titleLabel?.text?.LocalizedString(str: language), for: .normal)
        lbStatus.text = lbStatus.text?.LocalizedString(str: language)
        
        tfSMSCode.isHidden = true
    }

    // SDK Android và iOS hiện không hỗ trợ tái xác thực.
    
    @IBAction func btnYesClicked(_ sender: Any) {
        if !bool {
            let phoneNumber = "\(self.phoneNumber ?? "")"

            AuthManager.shared.startAuth(phoneNumber: phoneNumber, completion: { success in
                guard success else {
                    print("Error to send SMS")
                    return
                }
            })
            tfSMSCode.isHidden = false
            bool = true
        } else {
            let smsCode = tfSMSCode.text

            AuthManager.shared.deleteAccount(smsCode: smsCode!, completion: { success in
                guard success else {
                    print("Error")
                    self.lbStatus.text = "SMS is invalid!".LocalizedString(str: self.language)
                    return
                }

                DatabaseManager.shared.deleteUserRow(phoneNumber: self.phoneNumber!)
                DatabaseManager.shared.deleteFavouriteRow(phoneNumber: self.phoneNumber!)
                DatabaseManager.shared.deleteSeenRow(phoneNumber: self.phoneNumber!)
                Foundation.UserDefaults.standard.removeObject(forKey: "userPhoneNumber")

                self.lbStatus.text = "Delete account successfully!".LocalizedString(str: self.language)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.delegateDelete?.deleteAcc(status: true)
                }
            })
        }

    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        self.delegateDelete?.deleteAcc(status: false)
    }
}
