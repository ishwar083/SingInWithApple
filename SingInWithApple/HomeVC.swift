//
//  HomeVC.swift
//  SingInWithApple
//
//  Created by mac-00014 on 10/12/19.
//  Copyright © 2019 Mind. All rights reserved.
//

import UIKit
import AuthenticationServices

class HomeVC: UIViewController {
    
    @IBOutlet weak private var lblUserId: UILabel!
    @IBOutlet weak private var lblfirstName: UILabel!
    @IBOutlet weak private var lblLastName: UILabel!
    @IBOutlet weak private var lblEmail: UILabel!
            
    static func Push() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC else {
            return
        }
        guard let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else {
            return
        }
        navigationController.pushViewController(viewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCredentialRevokedNotificationNotification()
        
        let userInfo = UserDefaults.standard.fetchUserInfo()
        lblUserId.text = userInfo["user_id"] as? String
        lblfirstName.text = userInfo["user_first_name"] as? String
        lblLastName.text = userInfo["user_last_name"] as? String
        lblEmail.text = userInfo["user_email"] as? String
    }
    
    
    func setupCredentialRevokedNotificationNotification() {
        
        // Register for revocation notification
        let center = NotificationCenter.default
        let name = ASAuthorizationAppleIDProvider.credentialRevokedNotification
        _ = center.addObserver(forName: name, object: nil, queue: nil) { [weak self] (Notification) in
            // Sign the user out, optionally guide them to sign in again
            guard let `self` = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnLogOutClicked(_ sender: UIButton) {
     
        UserDefaults.standard.removeUser()
        guard let navigationController = view.window?.rootViewController as? UINavigationController else {
            return
        }
        navigationController.popViewController(animated: true)
    }
}
