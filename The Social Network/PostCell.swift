//
//  PostCell.swift
//  The Social Network
//
//  Created by Belinda Mo on 9/3/17.
//  Copyright © 2017 Belinda Mo. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!

}
