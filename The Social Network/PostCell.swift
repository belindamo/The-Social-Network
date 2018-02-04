//
//  PostCell.swift
//  The Social Network
//
//  Created by Belinda Mo on 9/3/17.
//  Copyright © 2017 Belinda Mo. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!

    var post: Post!
    var likesRef: DatabaseReference!

    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.bringSubview(toFront: likeImg)
        //programmatically add gesture recognizer to image bc there are multiple post cells
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.isUserInteractionEnabled = true
        likeImg.addGestureRecognizer(tap)
    }
    
    func configureCell(post: Post, img: UIImage? = nil) { // if img not passed in, it's nil
        self.post = post
        likesRef = DataService.ds.REF_CURRENT_USER.child("likes").child(post.postKey)
        
        self.caption.text = post.caption
        if let likes = post.likes {
            self.likesLbl.text = "\(likes)"
        }
        
        //where you download img
        if img != nil {
            self.postImg.image = img
        } else {
            let ref = Storage.storage().reference(forURL: post.imageUrl)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data,error) in
                if error != nil {
                    print("BMO: Can't download image from Firebase storage")
                } else {
                    print("BMO: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString) //save image to feedVC's image cache so that it's faster
                        }
                    }
                }
                
            })
            
            likesRef.observeSingleEvent(of: .value, with: {(snapshot) in
                if let _ = snapshot.value as? NSNull {
                    //empty heart bc no reference
                    self.likeImg.image = UIImage(named: "empty-heart")
                } else {
                    self.likeImg.image = UIImage(named: "filled-heart")
                    
                }
            })
        }
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        print("BMO: like button tapped. PLEASE FUCKING WORK")
        likesRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.removeValue()
            }
            
            
        })
    }
    
}
