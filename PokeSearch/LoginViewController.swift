//
//  LoginViewController.swift
//  InstagramLike
//
//  Created by Vasil Nunev on 27/11/2016.
//  Copyright © 2016 Vasil Nunev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    

    
    @IBAction func loginPressed(_ sender: Any) {
        
        guard emailField.text != "", pwField.text != "" else {return}
        
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: pwField.text!, completion: { (user, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            
            if let user = user {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userProfile")
                
                self.present(vc, animated: true, completion: nil)
                let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDel.logUser()
            }
        })

    }
    
}
