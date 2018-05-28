//
//  ViewController.swift
//  tinder-mis
//
//  Created by Andrej Naumovski on 5/4/18.
//  Copyright © 2018 Andrej Naumovski. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    @IBOutlet weak var swipeContainer: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(onElementDrag(gestureRecognizer:)))
        
        updateImage()
        swipeContainer.addGestureRecognizer(gesture)
    }
    
    @objc func onElementDrag(gestureRecognizer: UIPanGestureRecognizer) {
        print("Dragging")
        let slidePosition = gestureRecognizer.translation(in: view)
        
        swipeContainer.center = CGPoint(x: view.bounds.width / 2 + slidePosition.x, y: view.bounds.height / 2 + slidePosition.y)
        
        let distanceFromCenter = swipeContainer.center.x - view.bounds.width / 2
        
        let scaleCoefficient = 1 - abs(distanceFromCenter / (view.bounds.width))
        
        let scaleRotationTransform =
            CGAffineTransform(rotationAngle: distanceFromCenter / 200)
                .scaledBy(x: scaleCoefficient, y: scaleCoefficient)
        
        swipeContainer.transform = scaleRotationTransform
        
        if gestureRecognizer.state == .ended {
            if swipeContainer.center.x < (view.bounds.width / 2 - 100) {
                print("Not interested")
            }
            if swipeContainer.center.x > (view.bounds.width / 2 + 100) {
                print("Interested")
            }
            
            let scaleRotationReset =
                CGAffineTransform(rotationAngle: 0)
                    .scaledBy(x: 1, y: 1)
            
            swipeContainer.transform = scaleRotationReset
            swipeContainer.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        }
    }
    
    func updateImage() {
        if let query = PFUser.query() {
        
            query.whereKey("gender", equalTo: PFUser.current()?["interestedIn"] ?? "Female")
            query.whereKey("interestedIn", equalTo: PFUser.current()?["gender"] ?? "Male")
            
            query.limit = 1
            
            query.findObjectsInBackground { (objects, error) in
                if let users = objects {
                    for userObject in users {
                        if let user = userObject as? PFUser {
                            if let imageFile = user["photo"] as? PFFile {
                                imageFile.getDataInBackground { [weak self] (data, error) in
                                    if let imageData = data {
                                        if let strongSelf = self {
                                            strongSelf.swipeContainer.image = UIImage(data: imageData)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func onLogoutClick(_ sender: Any) {
        PFUser.logOut()
        performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    
    @IBAction func onEditDetailsClick(_ sender: Any) {
        performSegue(withIdentifier: "editDetails", sender: nil)
    }
}

