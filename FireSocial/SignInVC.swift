//
//  SignInVC.swift
//  FireSocial
//
//  Created by Kesley Ribeiro on 20/Apr/17.
//  Copyright © 2017 Kesley Ribeiro. All rights reserved.
//

import UIKit
import UITextField_Navigation
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import SwiftKeychainWrapper

extension SignInVC: UITextFieldNavigationDelegate {
    
    // explicitly protocol conforming declaration
    private func textFieldNavigationDidTapPreviousButton(_ textField: UITextField) {
        textField.previousTextField?.becomeFirstResponder()
    }
    
    private func textFieldNavigationDidTapNextButton(_ textField: UITextField) {
        textField.nextTextField?.becomeFirstResponder()
    }
    
    private func textFieldNavigationDidTapDoneButton(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}

class SignInVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var myViewHeader: UIView!
    @IBOutlet weak var myViewFooter: UIView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var pwdTxt: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myView.layer.cornerRadius = 10
        myViewHeader.round(corners: [.topLeft, .topRight], radius: 10)
        myViewFooter.round(corners: [.bottomLeft, .bottomRight], radius: 10)

        // Begin the button inactive
        signInBtn.isEnabled = false
        signInBtn.alpha = 0.3

        // Modifies the appearance of the TextFieldNavigationTooBar and TextFieldNavigationTooBarButtonItem
        UITextFieldNavigationToolbar.appearance().barStyle = .black
        UITextFieldNavigationToolbar.appearance().barTintColor = UIColor(red: 20/255, green: 151/255, blue: 153/255, alpha: 1)
        UITextFieldNavigationToolbarButtonItem.appearance().tintColor = UIColor.white

        // Create a notification when show the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(SignInVC.keyboardAppeared(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        // Create a notification when hidden the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(SignInVC.keyboardDisappeared(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        // Add target to execute function in textfield
        emailTxt.addTarget(self, action: #selector(SignInVC.textFieldDidChange(_:)), for: .editingChanged)
        pwdTxt.addTarget(self, action: #selector(SignInVC.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("[SUCCESS] ID found in keychain")
            performSegue(withIdentifier: "showFeed", sender: nil)
        }
    }
    
    // If some information in textfiel was modified
    func textFieldDidChange(_ textField : UITextView) {
        
        // If textfield is empty - inactivate Save button
        if emailTxt.text!.isEmpty || pwdTxt.text!.isEmpty || pwdTxt.text!.characters.count < 8 {
            
            signInBtn.isEnabled = false
            signInBtn.alpha = 0.3

        }// If textfield was modified - activate Save button
        else {
            signInBtn.isEnabled = true
            signInBtn.alpha = 1
        }
    }
    
    @IBAction func signInBtn(_ sender: Any) {
        
        if let email = emailTxt.text, let psw = pwdTxt.text {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: psw, completion: { (user, error) in
                if error == nil {
                    print("\n[SUCCESS] Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: psw, completion: { (user, error) in
                        if error != nil {
                            print("[ERROR] Unable to authenticate with Firebase using email - \(String(describing: error))")
                        } else {
                            print("[SUCCESS] Successfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }

    func firebaseAuthenticate(_ credential: FIRAuthCredential) {
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("[ERROR] Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                print("[SUCCESS] Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }

    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)

        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("[SUCCESS] Data saved to keychain: \(keychainResult)")
        performSegue(withIdentifier: "showFeed", sender: nil)
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
    
    // To received the notification when show the keyboard
    func keyboardAppeared(_ notificacao: Notification) {
        
        if (((notificacao as Notification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {

            // Update the position of the view
            self.view.frame.origin.y = 0
            self.mainView.frame.origin.y = 0
            self.myView.frame.origin.y = 0
            self.myViewHeader.frame.origin.y = 0
            self.myViewFooter.frame.origin.y = 0

            self.view.frame.origin.y -= 200
            self.mainView.frame.origin.y -= 200
            self.myView.frame.origin.y -= 200
            self.myViewHeader.frame.origin.y -= 200
            self.myViewFooter.frame.origin.y -= 200
        }
    }
    
    // To received the notification when hidden the keyboard
    func keyboardDisappeared(_ notificacao: Notification) {

        if (((notificacao as Notification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {

            // Update the position of the view
            self.view.frame.origin.y = 0
            self.mainView.frame.origin.y = 0
            self.myView.frame.origin.y = 0
            self.myViewHeader.frame.origin.y = 0
            self.myViewFooter.frame.origin.y = 0
        }
    }

    // Hidden keyboard when user touch in view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
