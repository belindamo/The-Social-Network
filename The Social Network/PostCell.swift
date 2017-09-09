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

    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(post: Post, img: UIImage? = nil) { // if img not passed in, it's nil
        self.post = post
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
            
        }
    }
}
