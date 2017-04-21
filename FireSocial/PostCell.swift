//
//  PostCell.swift
//  FireSocial
//
//  Created by Kesley Ribeiro on 21/Apr/17.
//  Copyright © 2017 Kesley Ribeiro. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet var postView: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        postView.layer.cornerRadius = 5.0
        profileImg.layer.cornerRadius = profileImg.frame.width / 2
        postImg.layer.cornerRadius = 5.0
    }    
}
