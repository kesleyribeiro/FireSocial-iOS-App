//
//  FeedVC.swift
//  FireSocial
//
//  Created by Kesley Ribeiro on 20/Apr/17.
//  Copyright © 2017 Kesley Ribeiro. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var posts = [Post]()
    
    @IBOutlet weak var tableFeed: UITableView!
    @IBOutlet var optionsView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        optionsView.layer.cornerRadius = 5.0        
        
        tableFeed.delegate = self
        tableFeed.dataSource = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    //print("[SNAP] \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableFeed.reloadData()
        })
    }

    @IBAction func signOutBtn(_ sender: Any) {
        
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("[SUCCESS] ID removed from keychain: \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "showSignIn", sender: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        print("[SUCCESS] \(post.caption)")

        return tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
    }
    
}
