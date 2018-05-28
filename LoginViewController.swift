//
//  LoginViewController.swift
//  tinder-mis
//
//  Created by Andrej Naumovski on 5/4/18.
//  Copyright © 2018 Andrej Naumovski. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var largeButton: UIButton!
    @IBOutlet weak var smallButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    var isSignUpMode = false
    
    lazy var loginAction: (() -> ()) = {
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        PFUser.logInWithUsername(inBackground: username!, password: password!, block: { [weak self] (user, error) in
            if error != nil {
                if let strongSelf = self {
                    strongSelf.displayErrorMessage(error: error)
                }
                return
            }
            
            print("Successfully logged in")
            if let strongSelf = self {
                strongSelf.errorMessage.isHidden = true
                
                if user?["gender"] != nil {
                    strongSelf.performSegue(withIdentifier: "loginToSwipe", sender: nil)
                }
                
                strongSelf.performSegue(withIdentifier: "loginToUserDetails", sender: nil)
            }
        })
    }
    
    lazy var signUpAction: (() -> ()) = {
        let newUser = PFUser()
        
        newUser.username = self.usernameField.text
        newUser.password = self.passwordField.text
        newUser["gender"] = "Male"
        newUser["interestedIn"] = "Female"
        
        newUser.signUpInBackground { (success, error) in
            if error != nil {
                self.displayErrorMessage(error: error)
                return
            }
            print("Successfully registered")
            self.errorMessage.isHidden = true
        }
    }
    
    var onLargeButtonClickAction: (() -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.onLargeButtonClickAction = loginAction
        self.errorMessage.isHidden = true
    }
    
    func displayErrorMessage(error: Error?) {
        var errorMessage = "Action failed, please try again"
        if let newError = error as NSError? {
            if let responseErrorMessage = newError.userInfo["error"] as? String {
                errorMessage = responseErrorMessage
            }
        }
        
        self.errorMessage.text = errorMessage
        self.errorMessage.isHidden = false
    }

    @IBAction func onLargeButtonClick(_ sender: Any) {
        if let action = onLargeButtonClickAction {
            action()
        }
    }
    
    
    @IBAction func onSmallButtonClick(_ sender: Any) {
        if isSignUpMode {
            largeButton.setTitle("Log in", for: .normal)
            smallButton.setTitle("Sign up", for: .normal)
            self.onLargeButtonClickAction = loginAction
        } else {
            largeButton.setTitle("Sign up", for: .normal)
            smallButton.setTitle("Log in", for: .normal)
            self.onLargeButtonClickAction = signUpAction
        }
        isSignUpMode = !isSignUpMode
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            if PFUser.current()?["gender"] != nil {
                performSegue(withIdentifier: "loginToSwipe", sender: nil)
            }
            performSegue(withIdentifier: "loginToUserDetails", sender: nil)
        }
    }
}
