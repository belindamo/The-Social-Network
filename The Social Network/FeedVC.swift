//
//  FeedVC.swift
//  The Social Network
//
//  Created by Belinda Mo on 9/2/17.
//  Copyright © 2017 Belinda Mo. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //dataservice listener. see if any value changed in posts; .value 
        //looks for basically anything that changes
        DataService.ds.REF_POSTS.observe(.value, with: {(snapshot) in
            print(snapshot.value!)
        })

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
    }

    @IBAction func signOutTapped(_ sender: UIImageView) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("BMO: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "signInVC", sender: nil)
    }



}
