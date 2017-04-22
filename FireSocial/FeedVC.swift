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
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    @IBOutlet weak var tableFeed: UITableView!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var captionField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableFeed.delegate = self
        tableFeed.dataSource = self

        optionsView.layer.cornerRadius = 5.0
        addImage.layer.cornerRadius = 5.0
        addImage.clipsToBounds = true
        
        postImagePicker = UIImagePickerController()
        postImagePicker.allowsEditing = true
        postImagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            
            self.posts = [] // This is the new line

            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("[SNAP] \(snap)")
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableFeed.reloadData()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image
            imageSelected = true
        } else {
            print("[POST] A valid image wasn't selected")
        }
        postImagePicker.dismiss(animated: true, completion: nil)
    }

    @IBAction func addPostImage(_ sender: Any) {
        present(postImagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postBtm(_ sender: Any) {
        
        guard let caption = captionField.text, caption != "" else {
            print("[SUCCESS] Caption must be entered")
            return
        }
        
        guard let img = addImage.image, imageSelected == true else {
            print("[SUCCESS] An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGE.child(imgUid).put(imgData, metadata: metadata) {(metadata, error) in
            
                if error != nil {
                    print("[ERROR] Unable to upload image to Firebase storage")
                } else {
                    print("[SUCCESS] Successfully uploaded image to Firebase storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    
                    if let url = downloadUrl {
                        self.postToFirebase(imgUrl: url)
                    }
                }
            }
        }
    }

    func postToFirebase(imgUrl: String) {

        let post: Dictionary<String, AnyObject> = [
            "caption": captionField.text! as AnyObject,
            "imageUrl": imgUrl as AnyObject,
            "likes": 0 as AnyObject
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        addImage.image = UIImage(named: "Camera-icon")
        
        tableFeed.reloadData()
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
                cell.configureCell(post: post, img: img)
            } else {
                cell.configureCell(post: post)
            }
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
