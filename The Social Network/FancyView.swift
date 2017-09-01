//
//  FancyView.swift
//  The Social Network
//
//  Created by Belinda Mo on 9/1/17.
//  Copyright © 2017 Belinda Mo. All rights reserved.
//  
//  custom views are essential to know for editing the
//  look of your app.
//

import UIKit

class FancyView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib() //necessary
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0 //how far it blurs out
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0) //how far the shadow goes
    }

}
