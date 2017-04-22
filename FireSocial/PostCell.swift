//
//  PostCell.swift
//  FireSocial
//
//  Created by Kesley Ribeiro on 21/Apr/17.
//  Copyright © 2017 Kesley Ribeiro. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {

    var post: Post!
    var likesRef: FIRDatabaseReference!
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        profileImg.layer.cornerRadius = profileImg.frame.width / 2
        postImg.layer.cornerRadius = 5.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeSelected))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }
    
    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        if img != nil {
            self.postImg.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("[ERROR] Unable to download image from Firebase storage")
                } else {
                    print("[SUCCESS] Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }

        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "Heart-icon")
            } else {
                self.likeImg.image = UIImage(named: "Heart-selected-icon")
            }
        })
    }
    
    func likeSelected(sender: UITapGestureRecognizer) {

        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "Heart-selected-icon")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "Heart-icon")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
}
