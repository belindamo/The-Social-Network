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


class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!

    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache() //static = global. to retrieve images
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true //be able to edit image before picking it
        imagePicker.delegate = self
        
        //dataservice event listener. see if any value changed in posts
        // .value looks for basically anything that changes
        DataService.ds.REF_POSTS.observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] { //on load, hook up model data with firebase
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            
            self.tableView.reloadData()
        })

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, img: img) //if have image in cache
            } else {
                cell.configureCell(post: post) //if need to download image from firebase
            }
            return cell
        } else {
            return PostCell() //empty cell
        }
    }

    
    //when finished picking image, gets array of info back
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
        } else {
            print("BMO: Valid image not selected")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func signOutTapped(_ sender: UIImageView) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("BMO: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "signInVC", sender: nil)
    }



}
