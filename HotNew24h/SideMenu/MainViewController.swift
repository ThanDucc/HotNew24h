//
//  ContainerViewController.swift
//  CustomSideMenuiOSExample
//
//  Created by John Codeos on 2/8/21.
//

import UIKit
import FirebaseAuth

class MainViewController: UIViewController {
    private var sideMenuViewController: SideMenu!
    private var sideMenuShadowView: UIView!
    private var sideMenuRevealWidth: CGFloat = (UIScreen.main.bounds.width * 3 / 4)
    private let paddingForRotation: CGFloat = 150
    private var isExpanded: Bool = false
    private var draggingIsEnabled: Bool = false
    private var panBaseLocation: CGFloat = 0.0

    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    private var revealSideMenuOnTop: Bool = true
    
    var gestureEnabled: Bool = true
    
    var sideMenuList: [String] = []
    public static var type: String = ""
    public static var nameSideMenu = "Youth"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSideMenu(completion: { success in
            if success {
                // Default Main View Controller
                self.sideMenuViewController.list = self.sideMenuList
                self.showViewController(viewController: UINavigationController.self, storyboardId: "news_screen")
                self.sideMenuViewController.tbListOption.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.sideMenuViewController.view.isHidden = false
                }
            }
        })
    
        // Shadow Background View
        self.sideMenuShadowView = UIView(frame: self.view.bounds)
        self.sideMenuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.sideMenuShadowView.backgroundColor = .black
        self.sideMenuShadowView.alpha = 0.0
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TapGestureRecognizer))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        self.sideMenuShadowView.addGestureRecognizer(tapGestureRecognizer)
        if self.revealSideMenuOnTop {
            view.insertSubview(self.sideMenuShadowView, at: 1)
        }

        // Side Menu
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.sideMenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuController") as? SideMenu
        self.sideMenuViewController.delegateMenuItem = self
        
        view.insertSubview(self.sideMenuViewController!.view, at: self.revealSideMenuOnTop ? 2 : 0)
        addChild(self.sideMenuViewController!)
        self.sideMenuViewController!.didMove(toParent: self)
        sideMenuViewController.view.isHidden = true

        // Side Menu AutoLayout
        self.sideMenuViewController.view.translatesAutoresizingMaskIntoConstraints = false

        if self.revealSideMenuOnTop {
            self.sideMenuTrailingConstraint = self.sideMenuViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -self.sideMenuRevealWidth - self.paddingForRotation)
            self.sideMenuTrailingConstraint.isActive = true
        }
        NSLayoutConstraint.activate([
            self.sideMenuViewController.view.widthAnchor.constraint(equalToConstant: self.sideMenuRevealWidth),
            self.sideMenuViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.sideMenuViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        // Side Menu Gestures
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)

    }
    
    func setUpSideMenu(completion: @escaping(Bool) -> Void) {
        let parseJson = ParseJson()
        parseJson.getData(completion: { success in
            if success {
                let newsData = parseJson.newsData
                for i in 0..<(newsData?.data.news.count)! {
                    self.sideMenuList.append((newsData?.data.news[i].name)!)
                }
                
                self.sideMenuList = self.sideMenuList + ["Favourite", "Seen", "Settings", "About App", "Contact us"]
                
                MainViewController.nameSideMenu = (newsData?.data.news[0].name)!
                completion(true)
            }
            else {
                completion(false)
            }
        })
    }

    func setNavBarAppearance(tintColor: UIColor, barColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = barColor
        appearance.titleTextAttributes = [.foregroundColor: tintColor]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = tintColor
    }

    // Keep the state of the side menu (expanded or collapse) in rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            if self.revealSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = self.isExpanded ? 0 : (-self.sideMenuRevealWidth - self.paddingForRotation)
            }
        }
    }

    func animateShadow(targetPosition: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            self.sideMenuShadowView.alpha = (targetPosition == 0) ? 0.6 : 0.0
        }
    }

    // Call this Button Action from the View Controller you want to Expand/Collapse when you tap a button
    @IBAction open func revealSideMenu() {
        close(bool: self.isExpanded ? false : true)
    }

    func sideMenuState(expanded: Bool) {
        if expanded {
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? 0 : self.sideMenuRevealWidth) { _ in
                self.isExpanded = true
            }
            // Animate Shadow (Fade In)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.6 }
        }
        else {
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? (-self.sideMenuRevealWidth - self.paddingForRotation) : 0) { _ in
                self.isExpanded = false
            }
            // Animate Shadow (Fade Out)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.0 }
        }
    }
    
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            if self.revealSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = targetPosition
                self.view.layoutIfNeeded()
            }
            else {
                self.view.subviews[1].frame.origin.x = targetPosition
            }
        }, completion: completion)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func changeLoginScreen() {
        LoginScreen.indexVNExCate = 0
        LoginScreen.indexYouthCate = 0
        MainViewController.type = ""
        let login = self.navigationController?.storyboard?.instantiateViewController(withIdentifier: "login") as! LoginScreen
        self.navigationController?.pushViewController(login, animated: true)
    }
}

extension MainViewController: MenuDelegate {
    
    func selectMenuItem(with item: String, bool: Bool) {
        if bool {
            switch item {
            case "Youth":
                MainViewController.type = "Youth"
                self.showViewController(viewController: UINavigationController.self, storyboardId: "news_screen")
                close(bool: false)
            case "VNExpress":
                MainViewController.type = "VNExpress"
                self.showViewController(viewController: UINavigationController.self, storyboardId: "news_screen")
                close(bool: false)
            case "Favourite":
                self.showViewController(viewController: UINavigationController.self, storyboardId: "favourite")
                close(bool: false)
            case "Seen":
                self.showViewController(viewController: UINavigationController.self, storyboardId: "seen")
                close(bool: false)
            case "Settings":
                self.sideMenuViewController.list = ["Language", "Delete account", "Log out"]
                self.sideMenuViewController.tbListOption.reloadData()
            case "Language":
                let viewControllerToPresent = self.storyboard?.instantiateViewController(withIdentifier: "language") as! Language
                viewControllerToPresent.delegateLang = self
                if let sheet = viewControllerToPresent.sheetPresentationController {
                    sheet.detents = [.medium()]
//                    sheet.preferredCornerRadius = 30.0
                }
                present(viewControllerToPresent, animated: true, completion: nil)
            case "Delete account":
                let viewControllerToPresent = self.storyboard?.instantiateViewController(withIdentifier: "deleteAcc") as! DeleteAcc
                viewControllerToPresent.delegateDelete = self
                if let sheet = viewControllerToPresent.sheetPresentationController {
                    sheet.detents = [.medium()]
                }
                present(viewControllerToPresent, animated: true, completion: nil)
            case "Log out":
                let viewControllerToPresent = self.storyboard?.instantiateViewController(withIdentifier: "deleteAcc") as! DeleteAcc
                viewControllerToPresent.delegateDelete = self
                viewControllerToPresent.delegateLogout = self
                viewControllerToPresent.tittle = "Log out"
                viewControllerToPresent.warning = "Are you sure to logout account?"
                if let sheet = viewControllerToPresent.sheetPresentationController {
                    sheet.detents = [.medium()]
                }
                present(viewControllerToPresent, animated: true, completion: nil)
            default:
                break
            }
        } else {
            close(bool: false)
        }
    }
    
    func close(bool: Bool) {
        // Collapse side menu with animation
        DispatchQueue.main.async {
            self.sideMenuState(expanded: bool)
        }
        self.sideMenuViewController.list = sideMenuList
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.sideMenuViewController.tbListOption.reloadData()
        })
    }

    func showViewController<T: UIViewController>(viewController: T.Type, storyboardId: String) -> () {
        // Remove the previous View
        for subview in view.subviews {
            if subview.tag == 99 {
                subview.removeFromSuperview()
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: storyboardId) as! T
        vc.view.tag = 99
        view.insertSubview(vc.view, at: self.revealSideMenuOnTop ? 0 : 1)
        addChild(vc)
        DispatchQueue.main.async {
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                vc.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                vc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                vc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        }
        if !self.revealSideMenuOnTop {
            if isExpanded {
                vc.view.frame.origin.x = self.sideMenuRevealWidth
            }
            if self.sideMenuShadowView != nil {
                vc.view.addSubview(self.sideMenuShadowView)
            }
        }
        vc.didMove(toParent: self)
    }
}

extension MainViewController: UIGestureRecognizerDelegate {
    @objc func TapGestureRecognizer(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if self.isExpanded {
                close(bool: false)
            }
        }
    }

    // Close side menu when you tap on the shadow background view
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self.sideMenuViewController.view))! {
            return false
        }
        return true
    }
    
    // Dragging Side Menu
    @objc private func handlePanGesture(sender: UIPanGestureRecognizer) {
        
        guard gestureEnabled == true else { return }

        let position: CGFloat = sender.translation(in: self.view).x
        let velocity: CGFloat = sender.velocity(in: self.view).x

        switch sender.state {
        case .began:

            // If the user tries to expand the menu more than the reveal width, then cancel the pan gesture
            if velocity > 0, self.isExpanded {
                sender.state = .cancelled
            }

            // If the user swipes right but the side menu hasn't expanded yet, enable dragging
            if velocity > 0, !self.isExpanded {
                self.draggingIsEnabled = true
            }
            // If user swipes left and the side menu is already expanded, enable dragging
            else if velocity < 0, self.isExpanded {
                self.draggingIsEnabled = true
            }

            if self.draggingIsEnabled {
                // If swipe is fast, Expand/Collapse the side menu with animation instead of dragging
                let velocityThreshold: CGFloat = 550
                if abs(velocity) > velocityThreshold {
                    close(bool: self.isExpanded ? false : true)
                    self.draggingIsEnabled = false
                    return
                }

                if self.revealSideMenuOnTop {
                    self.panBaseLocation = 0.0
                    if self.isExpanded {
                        self.panBaseLocation = self.sideMenuRevealWidth
                    }
                }
            }

        case .changed:

            // Expand/Collapse side menu while dragging
            if self.draggingIsEnabled {
                if self.revealSideMenuOnTop {
                    // Show/Hide shadow background view while dragging
                    let xLocation: CGFloat = self.panBaseLocation + position
                    let percentage = (xLocation * 150 / self.sideMenuRevealWidth) / self.sideMenuRevealWidth

                    let alpha = percentage >= 0.6 ? 0.6 : percentage
                    self.sideMenuShadowView.alpha = alpha

                    // Move side menu while dragging
                    if xLocation <= self.sideMenuRevealWidth {
                        self.sideMenuTrailingConstraint.constant = xLocation - self.sideMenuRevealWidth
                    }
                }
                else {
                    if let recogView = sender.view?.subviews[1] {
                        // Show/Hide shadow background view while dragging
                        let percentage = (recogView.frame.origin.x * 150 / self.sideMenuRevealWidth) / self.sideMenuRevealWidth

                        let alpha = percentage >= 0.6 ? 0.6 : percentage
                        self.sideMenuShadowView.alpha = alpha

                        // Move side menu while dragging
                        if recogView.frame.origin.x <= self.sideMenuRevealWidth, recogView.frame.origin.x >= 0 {
                            recogView.frame.origin.x = recogView.frame.origin.x + position
                            sender.setTranslation(CGPoint.zero, in: view)
                        }
                    }
                }
            }
        case .ended:
            self.draggingIsEnabled = false
            // If the side menu is half Open/Close, then Expand/Collapse with animation
            if self.revealSideMenuOnTop {
                let movedMoreThanHalf = self.sideMenuTrailingConstraint.constant > -(self.sideMenuRevealWidth * 0.5)
                close(bool: movedMoreThanHalf)
            }
            else {
                if let recogView = sender.view?.subviews[1] {
                    let movedMoreThanHalf = recogView.frame.origin.x > self.sideMenuRevealWidth * 0.5
                    close(bool: movedMoreThanHalf)
                }
            }
        default:
            break
        }
    }
}

extension UIViewController {
    
    // With this extension you can access the MainViewController from the child view controllers.
    func revealViewController() -> MainViewController? {
        var viewController: UIViewController? = self
        
        if viewController != nil && viewController is MainViewController {
            return viewController! as? MainViewController
        }
        while (!(viewController is MainViewController) && viewController?.parent != nil) {
            viewController = viewController?.parent
        }
        if viewController is MainViewController {
            return viewController as? MainViewController
        }
        return nil
    }
}

extension MainViewController: UpdateLanguge {
    func updateLangugeAll() {
        dismiss(animated: true, completion: nil)
        self.sideMenuViewController.getLanguage(completion: { success in
            self.sideMenuViewController.tbListOption.reloadData()
            self.sideMenuViewController.lbDev.text = self.sideMenuViewController.lbDev.text?.LocalizedString(str: self.sideMenuViewController.language)
        })
        NotificationCenter.default.post(name: Notification.Name("Language Changed"), object: nil)
    }
}

extension MainViewController: DeleteAccountClicked {
    func deleteAcc(status: Bool) {
        dismiss(animated: true, completion: nil)
        if status {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.changeLoginScreen()
            }
        }
    }
    
}

extension MainViewController: Logout {
    func logout(status: Bool) {
        dismiss(animated: true, completion: nil)
        if status {
            if Auth.auth().currentUser != nil {
                AuthManager.shared.logOut()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.changeLoginScreen()
            }
        }
    }
}
