//
//  LoginVC.swift
//  SingInWithApple
//
//  Created by mac-00014 on 10/12/19.
//  Copyright © 2019 Mind. All rights reserved.
//

import UIKit
import AuthenticationServices

class LoginVC: UIViewController {

    @IBOutlet weak private var loginProviderStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpProviderLoginView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performExistingAccountSetupFlows()
        
    }
    
    
    // Add “Sign In with Apple” button to your login view
    func setUpProviderLoginView() {
        
        let isDarkTheme = view.traitCollection.userInterfaceStyle == .dark
        let style: ASAuthorizationAppleIDButton.Style = isDarkTheme ? .white : .black
        
        // Create and Setup Apple ID Authorization Button
        let authorizationButton = ASAuthorizationAppleIDButton(type: .default, style: style)
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationButtonPress),
                         for: .touchUpInside)
        
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
    }
    
    
    private func performExistingAccountSetupFlows() {
        
        let requests = [ASAuthorizationAppleIDProvider().createRequest(), ASAuthorizationPasswordProvider().createRequest()]
                
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc private func handleAuthorizationButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func CheckCredentialState(_ currentUserId : String){
        
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: currentUserId ) { (credentialState, error) in
            
            switch(credentialState){
            case .authorized:
                HomeVC.Push()
                
            case .revoked:
               print("Apple ID Credential revoked, handle unlink")
                
            case .notFound:
                print("Credential not found, show login UI")
                
            default: break
            }
        }
    }
}


extension LoginVC : ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // Create an account in your system.
                       
            let userID = credential.user
            let userName = credential.fullName?.description ?? "N/A"
            let userFirstName = credential.fullName?.givenName ?? "N/A"
            let userLastName =   credential.fullName?.familyName ?? "N/A"
            let userEmail = credential.email ?? "N/A"
            let realUserStatus = credential.realUserStatus.rawValue
            
            print("User Id - \(userID)")
            print("User Name - \(userName)")
            print("User First Name - \(userFirstName)")
            print("User Last Name - \(userLastName)")
            print("User Email - \(userEmail)")
            print("Real User Status - \(realUserStatus)")
            
            var userIdentityToken = "N/A"
            
            if let identityToken = credential.identityToken,
                let identityTokenString = String(data: identityToken, encoding: .utf8) {
                print("Identity Token \(identityTokenString)")
                userIdentityToken = identityTokenString
            }
                        
            let userInfo :[String : Any] = ["user_id":userID,
                                            "user_name":userName,
                                            "user_first_name":userFirstName,
                                            "user_last_name":userLastName,
                                            "user_email":userEmail,
                                            "real_user_status":realUserStatus,
                                            "user_identity_token":userIdentityToken]
            
            UserDefaults.standard.saveUserInfo(userInfo)
            HomeVC.Push()
                        
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {

            let username = passwordCredential.user
            let password = passwordCredential.password
            self.CheckCredentialState(username)
        }
    }
}

extension LoginVC : ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension LoginVC  {
    
    fileprivate func initHomeVC(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC else {
            return
        }        
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
}
