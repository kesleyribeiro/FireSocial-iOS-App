//
//  SignInVC.swift
//  FireSocial
//
//  Created by Kesley Ribeiro on 20/Apr/17.
//  Copyright © 2017 Kesley Ribeiro. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase

class SignInVC: UIViewController {

    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var myViewHeader: UIView!
    @IBOutlet weak var myViewFooter: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myView.layer.cornerRadius = 10
        myViewHeader.round(corners: [.topLeft, .topRight], radius: 10)
        myViewFooter.round(corners: [.bottomLeft, .bottomRight], radius: 10)
    }
    
    @IBAction func facebookBtn(_ sender: Any) {
    
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            
            if error != nil {
                print("[ERROR] Unable to authenticate with Facebook - \(String(describing: error))")
            } else if result?.isCancelled == true {
                print("[CANCELLED] User cancelled Facebook authentication")
            } else {
                print("[SUCCESS] Successfully authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuthenticate(credential)
            }
        }
    }
    
    func firebaseAuthenticate(_ credential: FIRAuthCredential) {
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("[ERROR] Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                print("[SUCCESS] Successfully authenticated with Firebase")
                
            }
        })
    }
    
}

extension UIView {

    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }    
}
