//
//  UserDetailsViewController.swift
//  tinder-mis
//
//  Created by Andrej Naumovski on 5/4/18.
//  Copyright © 2018 Andrej Naumovski. All rights reserved.
//

import UIKit
import Parse

class UserDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var userGenderSwitch: UISwitch!
    @IBOutlet weak var userInterestSwitch: UISwitch!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        errorMessage.isHidden = true
        
        let user = PFUser.current()
        
        let userGender = user?["gender"] as! String
        let interestedIn = user?["interestedIn"] as! String
        
        userGenderSwitch.isOn = userGender == "Female"
        userInterestSwitch.isOn = interestedIn == "Female"
        
        if let userPicture = user?["photo"] as? PFFile {
            userPicture.getDataInBackground { [weak self] (imageData, error) in
                if error != nil {
                    if let strongSelfReference = self {
                        strongSelfReference.displayErrorMessage(error: error)
                    }
                    return
                }
                
                if let strongSelfReference = self {
                    strongSelfReference.profilePicture.image = UIImage(data: imageData!)
                }
            }
        }
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
    
    @IBAction func onSaveChangesClick(_ sender: Any) {
        let userGender = userGenderSwitch.isOn ? "Female" : "Male"
        let interestedIn = userInterestSwitch.isOn ? "Female" : "Male"
        
        if let currentUser = PFUser.current() {
            currentUser["gender"] = userGender
            currentUser["interestedIn"] = interestedIn
            
            currentUser.saveInBackground { [weak self] (success, error) in
                if error != nil {
                    if let strongSelfReference = self {
                        strongSelfReference.displayErrorMessage(error: error)
                    }
                    return
                }
                
                if let strongSelfReference = self {
                    if let userImage = strongSelfReference.profilePicture.image {
                        if let userImageData = UIImagePNGRepresentation(userImage) {
                            currentUser["photo"] = PFFile(name: "photo.png", data: userImageData)
                            currentUser.saveInBackground { (success, error) in
                                if error != nil {
                                    strongSelfReference.displayErrorMessage(error: error)
                                    return
                                }
                                print("Photo successfully updated")
                                strongSelfReference.performSegue(withIdentifier: "userDetailsToSwipe", sender: nil)
                            }
                        }
                        
                        
                    }
                }
                
                print("Successfully saved")
            }
        }
    }
    
    @IBAction func onChangeProfilePictureClick(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.profilePicture.image = selectedImage
        self.dismiss(animated: true, completion: nil)
    }
    
    // This is just a workaround so you don't manually register lots of users
    func addWomenInDatabase() {
        let images = [
            "http://www.slate.com/content/dam/slate/blogs/xx_factor/2014/susan.jpg.CROP.promo-mediumlarge.jpg",
            "https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg?cs=srgb&dl=fashion-person-woman-733872.jpg&fm=jpg",
            "https://media.glamour.com/photos/5696d70301ed531c6f00b97d/master/w_1280,c_limit/sex-love-life-2015-05-woman-1-main.jpg",
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTBa1APrDGvNvB_u9tN2-DLSvFaotv5Z10CiU05f4h-upQA7P7yvw"
        ]
        
        var counter = 1
        
        for image in images {
            if let imageUrl = URL(string: image) {
                if let imageData = try? Data(contentsOf: imageUrl) {
                    let imageFile = PFFile(name: "profile.png", data: imageData)
                    
                    let newWomanUser = PFUser()
                    newWomanUser["photo"] = imageFile
                    newWomanUser.username = String(counter)
                    newWomanUser.password = "password123"
                    newWomanUser["gender"] = "Female"
                    newWomanUser["interestedIn"] = "Male"
                    
                    counter += 1;
                    
                    newWomanUser.signUpInBackground { (success, error) in
                        if success {
                            print("Success")
                            return
                        }
                        
                        print("Error")
                    }
                }
            }
        }
    }
}
