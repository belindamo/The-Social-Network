//
//  SignInVC.swift
//  The Social Network
//
//  Created by Belinda Mo on 9/1/17.
//  Copyright © 2017 Belinda Mo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class SignInVC: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

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
            }
        })
    }

}

