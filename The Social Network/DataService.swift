//
//  DataService.swift
//  The Social Network
//
//  Created by Belinda Mo on 9/8/17.
//  Copyright © 2017 Belinda Mo. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = Database.database().reference() //contains url of the group of our database. the base the-social-network-ceeec. Get this from GoogleService-Info.plist.
let STORAGE_BASE = Storage.storage().reference()

class DataService {
    
    static let ds = DataService() //creates singleton (single instance) of dataservice class. accessible from everywhere
    
    //DB references
    private var _REF_BASE = DB_BASE //note that private vars start with _
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    
    //storage references
    private var _REF_POST_IMGS = STORAGE_BASE.child("post-pics")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }

    var REF_POSTS: DatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_POST_IMGS: StorageReference {
        return _REF_POST_IMGS
    }
    
    //sends info to firebase to save
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData) //creates child object in users if it doesn't already exist, and updates its values
        //updateChildValues is very useful for both creating new or adding to existing
        
    }
    
}
