//
//  LoginScreen.swift
//  HotNew24h
//
//  Created by ThanDuc on 22/12/2022.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import GoogleSignIn

class LoginScreen: UIViewController {

    @IBOutlet weak var lbTittleApp: UILabel!
    @IBOutlet weak var lbPhoneNumber: UILabel!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var viewFacebook: UIView!
    @IBOutlet weak var viewGoogle: UIView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbOr: UILabel!
    @IBOutlet weak var lbRegis: UILabel!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnEnter: UIButton!
    @IBOutlet weak var lbSMSCode: UILabel!
    @IBOutlet weak var tfSMSCode: UITextField!
    
    var count = 0
    var language = ""
    var logIn = false
    var userEmail: String?
    var link: String?
    
    let defaults = Foundation.UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logIn = Foundation.UserDefaults.standard.bool(forKey: "LOG_IN")
        
        if logIn {
            let homeScreen = self.storyboard?.instantiateViewController(withIdentifier: "home") as! HomeScreen
            self.navigationController?.pushViewController(homeScreen, animated: true)
        }
        
        DatabaseManager.shared.createDatabase()
        DatabaseManager.shared.createTables()
        
        let phoneNumber = Foundation.UserDefaults.standard.string(forKey: "userPhoneNumber")
        if phoneNumber == nil {
            language = "en"
        } else {
            language = DatabaseManager.shared.getLanguage(phoneNumber: phoneNumber!)
        }

        setupUI()
        
        let fbTapGesture = UITapGestureRecognizer(target: self, action: #selector(logInFacebook(_:)))
        fbTapGesture.numberOfTapsRequired = 1
        fbTapGesture.numberOfTouchesRequired = 1
        viewFacebook.addGestureRecognizer(fbTapGesture)
        
        let ggTapGesture = UITapGestureRecognizer(target: self, action: #selector(logInGoogle(_:)))
        ggTapGesture.numberOfTapsRequired = 1
        ggTapGesture.numberOfTouchesRequired = 1
        viewGoogle.addGestureRecognizer(ggTapGesture)
    }
    
    @objc func logInFacebook(_ gesture: UITapGestureRecognizer) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            if let error = error {
                print("Encountered Erorr: \(error)")
            } else if let result = result, result.isCancelled {
                print("Cancelled")
            } else {
                self.signIntoFirebaseFb()
            }
        }
    }
    
    func getFacebookData() {
        if AccessToken.current != nil {
            GraphRequest(graphPath: "me", parameters: ["fields": "email, name"]).start {
                (connection, result, error) in
                if error == nil {
                    let dict = result as! [String: AnyObject] as NSDictionary
                    let name = dict.object(forKey: "name") as! String
                    print("Name: \(name)")
                } else {
                    print(error?.localizedDescription as Any)
                }
            }
        } else {
            print("Access Token is nil")
        }
    }
    
    func signIntoFirebaseFb() {
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        signIn(credential: credential)
    }
    
    @objc func logInGoogle(_ gesture: UITapGestureRecognizer) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else {
                return
            }
            
            self.userEmail = signInResult?.user.profile?.email
            
            let accessToken = signInResult?.user.accessToken.tokenString
            let idToken = signInResult?.user.idToken?.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken!, accessToken: accessToken!)
            self.signIn(credential: credential)
            
//            self.sendFirebaseEmailLink()
        }
    }
    
    func signIn(credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { result, error in
            guard result != nil, error == nil else {
                print(error!.localizedDescription as String)
                return
            }
            let user = Auth.auth().currentUser
            self.defaults.set(user?.displayName, forKey: "userName")
            Register().registerAccount(userId: (user?.uid)!)
            self.defaults.set((user?.uid)!, forKey: "userPhoneNumber")
            
            self.login()
            
        })
    }

    func sendFirebaseEmailLink() {
        let actionCodeSettings = ActionCodeSettings.init()
        let email = userEmail
        actionCodeSettings.url = URL.init(string: "https://hotnew24h.page.link/iGuj")

        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)

        Auth.auth().sendSignInLink(toEmail: email!, actionCodeSettings: actionCodeSettings) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            else {
                UserDefaults.standard.set(email, forKey: "Email")
                print("Email sent to user")
            }

            self.lbStatus.text = "Please check mail and click link!".LocalizedString(str: self.language)
        }
    }

    @objc func signInUserAfterEmailLinkClick() {
        if let link = UserDefaults.standard.value(forKey: "Link") as? String {
            self.link = link
        }
        Auth.auth().signIn(withEmail: userEmail!, link: link!) { (result, error) in
            if error == nil && result != nil {
                if (Auth.auth().currentUser?.isEmailVerified)! {
                    print("User verified with passwordless email")
                }
                else {
                    print("User NOT verified by passwordless email")
                }
            }
            else {
                print("Error with passwordless email verfification: \(error?.localizedDescription ?? "Strangely, no error avaialble.")")
            }
        }
    }
    
    func setupUI() {
        lbTittleApp.text = lbTittleApp.text?.LocalizedString(str: language)
        lbPhoneNumber.text = lbPhoneNumber.text?.LocalizedString(str: language)
        tfPhoneNumber.placeholder = tfPhoneNumber.placeholder?.LocalizedString(str: language)
        btnLogin.setTitle(btnLogin.titleLabel?.text?.LocalizedString(str: language), for: .normal)
        lbOr.text = lbOr.text?.LocalizedString(str: language)
        btnRegister.setTitle(btnRegister.titleLabel?.text?.LocalizedString(str: language), for: .normal)
        lbRegis.text = lbRegis.text?.LocalizedString(str: language)
        lbSMSCode.text = lbSMSCode.text?.LocalizedString(str: language)
        tfSMSCode.placeholder = tfSMSCode.placeholder?.LocalizedString(str: language)
        
        lbPhoneNumber.isHidden = true
        lbSMSCode.isHidden = true
        
        btnEnter.isHidden = true
        
        btnLogin.layer.cornerRadius = 5
        btnLogin.backgroundColor = UIColor.systemGray4
        
        viewFacebook.layer.borderWidth = 1
        viewFacebook.layer.borderColor = UIColor.systemGray5.cgColor
        viewFacebook.layer.cornerRadius = 5
        
        viewGoogle.layer.borderWidth = 1
        viewGoogle.layer.borderColor = UIColor.systemGray5.cgColor
        viewGoogle.layer.cornerRadius = 5
    }
    
    @IBAction func enter(_ sender: Any) {
        lbStatus.text = ""
        let phoneNumber = "\(tfPhoneNumber.text!)"
        if DatabaseManager.shared.checkPhoneNumber(phoneNumber: phoneNumber) {
            AuthManager.shared.startAuth(phoneNumber: phoneNumber, completion: { success in
                guard success else {
                    self.lbStatus.text = "Your phone number is invalid!".LocalizedString(str: self.language)
                    return
                }
            })
        } else {
            lbStatus.text = "Your phone number doesn't exist!".LocalizedString(str: self.language)
        }
        
    }
    
    @IBAction func lbPhoneNumberHidden(_ sender: Any) {
        if (tfPhoneNumber.text == "") {
            lbPhoneNumber.isHidden = true
            btnLogin.backgroundColor = UIColor.systemGray4
            lbStatus.text = ""
            btnEnter.isHidden = true
        } else {
            btnEnter.isHidden = false
            lbPhoneNumber.isHidden = false
            if(!tfSMSCode.text!.isEmpty) {
                btnLogin.backgroundColor = #colorLiteral(red: 0.9989940524, green: 0.2311825156, blue: 0.3164890409, alpha: 1)
            }
        }
        
    }
    
    @IBAction func lbSMSCodeHidden(_ sender: Any) {
        if (tfSMSCode.text == "") {
            lbSMSCode.isHidden = true
            btnLogin.backgroundColor = UIColor.systemGray4
            lbStatus.text = ""
        } else {
            lbSMSCode.isHidden = false
            if(!tfPhoneNumber.text!.isEmpty) {
                btnLogin.backgroundColor = #colorLiteral(red: 0.9989940524, green: 0.2311825156, blue: 0.3164890409, alpha: 1)
            }
        }
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        lbStatus.text = ""
        if !tfPhoneNumber.text!.isEmpty && !tfSMSCode.text!.isEmpty {
            let code = tfSMSCode.text!
            AuthManager.shared.verifyCode(smsCode: code, completion: { success in
                if !success {
                    self.lbStatus.text = "SMS code is incorrect!".LocalizedString(str: self.language)
                } else {
                    self.defaults.set(self.tfPhoneNumber.text!, forKey: "userPhoneNumber")
                    self.login()
                }
            })
        }
    }
    
    func login() {
        lbStatus.text = "Login successfully!".LocalizedString(str: self.language)
        Foundation.UserDefaults.standard.set(true, forKey: "LOG_IN")
                                            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let homeScreen = self.storyboard?.instantiateViewController(withIdentifier: "home") as! HomeScreen
            self.navigationController?.pushViewController(homeScreen, animated: true)
        }
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        let registerScreen = self.storyboard?.instantiateViewController(withIdentifier: "RegiterViewController") as! RegisterScreen
        self.navigationController?.pushViewController(registerScreen, animated: true)
    }
    
    @objc func tapCheckbox(_ gesture: UITapGestureRecognizer) {
        print("Clicked")
    }
    
}
