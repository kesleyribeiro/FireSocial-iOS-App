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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var posts = [Post]()
    var postImagePicker: UIImagePickerController!

    @IBOutlet weak var tableFeed: UITableView!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var addImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        optionsView.layer.cornerRadius = 5.0
        addImage.layer.cornerRadius = 5.0
        addImage.clipsToBounds = true
        
        tableFeed.delegate = self
        tableFeed.dataSource = self
        
        postImagePicker = UIImagePickerController()
        postImagePicker.allowsEditing = true
        postImagePicker.delegate = self
        
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

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image
        } else {
            print("[POST] A valid image wasn't selected")
        }
        postImagePicker.dismiss(animated: true, completion: nil)
    }

    @IBAction func addPostImage(_ sender: Any) {
        present(postImagePicker, animated: true, completion: nil)
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
            cell.configureCell(post: post)
            return cell
        } else {
            return PostCell()
        }
    }

    @IBAction func signOutBtn(_ sender: Any) {

        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("[SUCCESS] ID removed from keychain: \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "showSignIn", sender: nil)
    }
}
