//
//  SignInVC.swift
//  The Social Network
//
//  Created by Belinda Mo on 9/1/17.
//  Copyright © 2017 Belinda Mo. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailFld: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("BMO: ID found in Keychain")
            performSegue(withIdentifier: "FeedVC", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func FacebookBtnPressed(_ sender: Any) {
        
        let fbLogin = FBSDKLoginManager()
        
        fbLogin.logIn(withReadPermissions: ["email"], from: self, handler: {(result, error) in
            if error != nil {
                print("BMO: Unable to authenticate with Facebook")
            } else if result?.isCancelled == true {
                print("BMO: User cancelled FB authentication")
            } else {
                print("BMO: User successfully authenticated FB")
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            self.fireBaseAuth(credential)
        })
    }
    
    func fireBaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("BMO: Unable to authenticate with Firebase - \(error)")
            } else {
                print("BMO: Successfully authenticated with FB")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }

    @IBAction func signInPressed(_ sender: Any) {
        if let email = emailFld.text, let pwd = pwdField.text {
            Auth.auth().signIn(withEmail: email, password: pwd, completion: {(user, error) in
                if error == nil {
                    print("BMO: Email authenticated with Firebase")
                } else {
                    Auth.auth().createUser(withEmail: email, password: pwd, completion: {(user, error) in
                        if error != nil {
                            print("BMO: Unable to authenticate  with Firebase using email: \(error)")
                        } else {
                            print("BMO: Successfully authenticated with Firebase and created new user")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
                
            })
        }
    }
    
    //after user authenticated by firebase
    func completeSignIn(id:String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("BMO: Data saved to keychain: \(keychainResult)")
        performSegue(withIdentifier: "FeedVC", sender: nil)
    }
}

