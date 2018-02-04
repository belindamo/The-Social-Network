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
    @IBOutlet weak var captionField: UITextField!

    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache() //static = global. to retrieve images
    var imageSelected = false
    
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
            self.posts = []
            
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
            imageSelected = true
        } else {
            print("BMO: Valid image not selected")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        //guard statement lets you string a bunch of 'if let's together
        guard let caption = captionField.text, caption != "" else {
            print("BMO: Caption must be entered")
            return //if in here, means that something is fucked up somewhere
        }
        guard let img = imageAdd.image, imageSelected == true else {
            print("BMO: Image must be selected")
            return
        }
        
        
        //convert image into image data to send to firebase storage
        if let imgData = UIImageJPEGRepresentation(img, 0.2) { // 0.2 is compression
            let imgUid = NSUUID().uuidString //get a new id for img
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg" //defensive data
            
            DataService.ds.REF_POST_IMGS.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                
                if error != nil {
                    print("BMO: Unable to upload image to Firebase Storage")
                } else {
                    print("BMO: Successfully uploaded image to Firebase Storage")
                    if let downloadUrl = metadata?.downloadURL()?.absoluteString { //get raw string of download url. for storing in database
                        self.postToFirebase(imgUrl: downloadUrl)
                    }
                    
                }   
                
            }//pass imgData into imgUid
            
            self.tableView.reloadData()

        }
        
    }
    
    func postToFirebase(imgUrl: String) {
        
        let post: Dictionary<String, AnyObject> = [
        "caption": captionField.text! as AnyObject,
        "imageUrl" : imgUrl as AnyObject,
        "likes": 0 as AnyObject
        ]
        
        //childByAutoId creates a new unique identifier
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        //reset fields
        captionField.text = ""
        imageSelected = false //uiimagepicker
        imageAdd.image = UIImage(named: "add-image")
        
    }
    
    @IBAction func signOutTapped(_ sender: UIImageView) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("BMO: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "signInVC", sender: nil)
    }



}
