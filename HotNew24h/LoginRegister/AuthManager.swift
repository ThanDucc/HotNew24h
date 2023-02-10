//
//  AuthManager.swift
//  HotNew24h
//
//  Created by ThanDuc on 26/12/2022.
//

import Foundation
import FirebaseAuth
import FacebookLogin
import GoogleSignIn

class AuthManager {
    
    static let shared = AuthManager()
    private let auth = Auth.auth()
    private var verificationId: String?

    // verify phone number and send sms code
    public func startAuth(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil, completion: { verificationId, error in
            guard let verificationId = verificationId, error == nil else {
                completion(false)
                return
            }
            self.verificationId = verificationId
            completion(true)
        })
    }
    
    // check sms code and sign in with phone number
    public func verifyCode(smsCode: String, completion: @escaping (Bool) -> Void) {
        guard let verificationId = verificationId else {
            completion(false)
            return
        }
        let crential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: smsCode)
        
        auth.signIn(with: crential, completion: { result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }
            completion(true)
        })

    }
    
    // reauthentication by send sms code and delete account with phone number
    public func deleteAccountByPhoneNumber(smsCode: String, completion: @escaping (Bool) -> Void) {
        guard let verificationId = verificationId else {
            completion(false)
            return
        }
        let crential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: smsCode)
        
        let user: User = Auth.auth().currentUser!
        user.reauthenticate(with: crential) { result, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                user.delete(completion: { error in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(false)
                    } else {
                        print("Delete account successfully!")
                        Foundation.UserDefaults.standard.removeObject(forKey: "LOG_IN")
                        completion(true)
                    }
                })
            }
        }
        
    }
    
    public func deleteAccountByEmail(completion: @escaping (Bool) -> Void) {
        let user: User = Auth.auth().currentUser!
        let credential = EmailAuthProvider.credential(withEmail: (user.email)!, password: "123456")
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                user.delete(completion: { error in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(false)
                    } else {
                        Foundation.UserDefaults.standard.removeObject(forKey: "LOG_IN")
                        completion(true)
                    }
                })
            }
        }
    }
    
    
    // log out account in Firebase
    public func logOut() {
        do {
            LoginManager().logOut()
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
            Foundation.UserDefaults.standard.removeObject(forKey: "LOG_IN")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

}
