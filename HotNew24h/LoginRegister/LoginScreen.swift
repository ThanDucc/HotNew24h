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
    let defaults = Foundation.UserDefaults.standard
    
    public static var indexYouthCate = 0
    public static var indexVNExCate = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // check if user logining -> go to HomeScreen
        logIn = Foundation.UserDefaults.standard.bool(forKey: "LOG_IN")
        
        if logIn {
            let mainScreen = self.storyboard?.instantiateViewController(withIdentifier: "mainScreen") as! MainViewController
            self.navigationController?.pushViewController(mainScreen, animated: true)
        }
        
        // Create database and tables
        DatabaseManager.shared.createDatabase()
        DatabaseManager.shared.createTables()
        
        let lang = Foundation.UserDefaults.standard.string(forKey: "LanguageAllApp")
        
        if lang == nil {
            self.language = "en"
            Foundation.UserDefaults.standard.set(self.language, forKey: "LanguageAllApp")
        } else {
            self.language = Foundation.UserDefaults.standard.string(forKey: "LanguageAllApp")!
        }
        self.setupUI()
        
        // add gesture to login with Facebook
        let fbTapGesture = UITapGestureRecognizer(target: self, action: #selector(logInFacebook(_:)))
        fbTapGesture.numberOfTapsRequired = 1
        fbTapGesture.numberOfTouchesRequired = 1
        viewFacebook.addGestureRecognizer(fbTapGesture)
        
        // add gesture to login with Google
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
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                self.signIn(credential: credential)
            }
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
            
            DispatchQueue.global().async {
                let check = DatabaseManager.shared.checkPhoneNumber(phoneNumber: (user?.uid)!)
                if !check {
                    Register().registerAccount(userId: (user?.uid)!, language: self.language)
                }
            }
            self.defaults.set((user?.uid)!, forKey: "userPhoneNumber")
            self.login()
            
        })
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
    
    // login with google to get email
    @objc func logInGoogle(_ gesture: UITapGestureRecognizer) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else {
                return
            }
            let email = signInResult?.user.profile?.email
            self.createUser(email: email!, completion: { success in
                DispatchQueue.global().async {
                    let check = DatabaseManager.shared.checkPhoneNumber(phoneNumber: email!)
                    if !check {
                        Register().registerAccount(userId: email!, language: self.language)
                    }
                }
                self.defaults.set(email, forKey: "userPhoneNumber")
                self.loginGoogle(email: email!)
            })
        }
    }
    
    // login in Firebase
    func loginGoogle(email: String) {
        Auth.auth().signIn(withEmail: email, password: "123456") { authResult, error in
            guard (error == nil) else {
                print("error to login with google")
                return
            }
            self.login()
        }
    }
    
    func createUser(email: String, completion: @escaping(Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: "123456") { authResult, error in
            guard error == nil else {
                completion(false)
                return
            }
            self.defaults.set(email, forKey: "email")
            completion(true)
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
    
    // check if phone number doesn't exist and verify sms code to login
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
                btnLogin.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.3841883486, alpha: 1)
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
                btnLogin.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.3841883486, alpha: 1)
            }
        }
    }
    
    // login
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
    
    // login and go to HomeScreen
    func login() {
        lbStatus.text = "Login successfully!".LocalizedString(str: self.language)
        Foundation.UserDefaults.standard.set(true, forKey: "LOG_IN")
                                            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let mainScreen = self.storyboard?.instantiateViewController(withIdentifier: "mainScreen") as! MainViewController
            self.navigationController?.pushViewController(mainScreen, animated: true)
        }
    }
    
    // change screen to RegisterScreen
    @IBAction func btnRegister(_ sender: Any) {
        let registerScreen = self.storyboard?.instantiateViewController(withIdentifier: "RegiterViewController") as! RegisterScreen
        self.navigationController?.pushViewController(registerScreen, animated: true)
    }
    
}

