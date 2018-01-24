//
//  SignupViewController.swift
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

class SignupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate   {
    
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var cityState: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var comPwField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var zoneFIeld: UITextField!
    @IBOutlet weak var churchField: UITextField!
    @IBOutlet weak var churchesDpdn: UIPickerView!
    @IBOutlet weak var titleDpdn: UIPickerView!
    @IBOutlet weak var zonesDpdn: UIPickerView!
    
    var titleArray = [String]()
    var churchArray = [Churches]()
    var zoneArray = [Zones]()
    var churchData = Churches()
    var zoneData = Zones()
    var zoneData2 = Zones()
 
    
    let picker = UIImagePickerController()
    var userStorage: FIRStorageReference!
    var ref: FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
        let storage = FIRStorage.storage().reference(forURL: "gs://pokesearch-2b460.appspot.com")
        
        ref = FIRDatabase.database().reference()
        userStorage = storage.child("leaders")
        
        titleArray = ["Pastor", "Reverend" , "Deacon" , "Coordinator" ,"Brother" , "Sister" ]
        zoneData2.zoneName = "none"
        zoneArray.append(zoneData2)
        
        fetchZones()

    }


    @IBAction func selectImagePressed(_ sender: Any) {
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = image
            nextBtn.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        
        guard nameField.text != "", emailField.text != "", password.text != "", comPwField.text != "" else { return}
        
        if password.text == comPwField.text {
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: password.text!, completion: { (user, error) in
                
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                if let user = user {
                    
                    let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                    changeRequest.displayName = self.nameField.text!
                    changeRequest.commitChanges(completion: nil)
                    
                    let imageRef = self.userStorage.child("\(user.uid).jpg")
                    
                    let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
                    
                    let uploadTask = imageRef.put(data!, metadata: nil, completion: { (metadata, err) in
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                        
                        imageRef.downloadURL(completion: { (url, er) in
                            if er != nil {
                                print(er!.localizedDescription)
                            }
                            
                            
                            if let url = url {
                                
                                let userInfo: [String : Any] = ["uid" : user.uid,
                                                                "Points" : 0,
                                                                "full name" : self.nameField.text!,
                                                                "urlToImage" : url.absoluteString,
                                                                
                                                                "email" : self.emailField.text!,
                                                                "cityState" : self.cityState.text!,
                                                                "password" : self.password.text!]
                                
                                let churchInfo: [String:Any] = [user.uid:self.churchData.churchID!]
                                let zoneInfo: [String:Any] = [user.uid:self.zoneData.zoneKey!]
                                let undrUsers = ["MyChurch/\(self.churchData.churchID!)" : self.churchData.churchID]
                                let undrUsers2 = ["MyZones/\(self.zoneData.zoneKey!)" : self.zoneData.zoneKey]
                                let undrZones = ["Members/\(user.uid)" : user.uid]
                                let undrChurches = ["Members/\(user.uid)" : user.uid]
                            
                                self.ref.child("leaders").child(user.uid).setValue(userInfo)
                                self.ref.child("leaders").child(user.uid).updateChildValues(undrUsers)
                                self.ref.child("leaders").child(user.uid).updateChildValues(undrUsers2)
                                self.ref.child("zones").child(self.zoneData.zoneKey!).updateChildValues(undrZones)
                                self.ref.child("churches").child(self.churchData.churchID!).updateChildValues(undrChurches)
                            self.ref.child("zones").child(self.zoneData.zoneKey!).child("churches").child(self.churchData.churchID!).updateChildValues(undrChurches)
                            
                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userProfile")
                                
                                self.present(vc, animated: true, completion: nil)
                                
                            }
                            
                        })
                        
                    })
                    
                    uploadTask.resume()
                    
                }
                
            })
            
        } else {
            print("Password does not match")
        }
     
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == titleDpdn {
            return titleArray[row]
        }
        if pickerView == churchesDpdn {
            return churchArray[row].churchName
        }
        if pickerView == zonesDpdn {
            return zoneArray[row].zoneName
        } else {
            return ""
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == titleDpdn {
            return titleArray.count
        }
        if pickerView == churchesDpdn {
            return churchArray.count
        }
        if pickerView == zonesDpdn {
            return zoneArray.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == titleDpdn {
            titleField.text = titleArray[row]
            self.titleDpdn.isHidden = true
        }
        if pickerView == churchesDpdn {
            churchField.text = churchArray[row].churchName
            churchData.churchID = churchArray[row].churchID
            self.churchesDpdn.isHidden = true
        }
        if pickerView == zonesDpdn {
            zoneFIeld.text = zoneArray[row].zoneName
            churchField.text = ""
            // make a call to firebase with zone selected.
            self.zonesDpdn.isHidden = true
            if self.zoneArray[row].churchArray != nil {
                if self.zoneArray[row].churchArray!.count > 0 {
                    zoneData.zoneKey = self.zoneArray[row].zoneKey
                    churchArray = self.zoneArray[row].churchArray!
                    churchesDpdn.reloadAllComponents()
                } else
                {
                    let church = Churches()
                    church.churchName = "no church for this zone"
                    churchArray.append(church)
                    churchesDpdn.reloadAllComponents()
                }
            }
        }
        else
        {
            let church = Churches()
            church.churchName = "no church for this zone"
            churchArray.append(church)
            churchesDpdn.reloadAllComponents()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == titleField {
            self.churchesDpdn.isHidden = true
            self.zonesDpdn.isHidden = true
            self.titleDpdn.isHidden = false
        }
        if textField == churchField {
            self.churchesDpdn.isHidden = false
            self.zonesDpdn.isHidden = true
            self.titleDpdn.isHidden = true
        }
        if textField == zoneFIeld {
            self.churchesDpdn.isHidden = true
            self.zonesDpdn.isHidden = false
            self.titleDpdn.isHidden = true
        }
    }
    
    func fetchZones(){
        
        ref.child("zones").queryOrderedByKey().observeSingleEvent(of: .value, with: { soulSnapShot in
            if soulSnapShot.value is NSNull {
                
                /// dont do anything
            } else {
                let zones = soulSnapShot.value as! [String:AnyObject]
                for (a,b) in zones {
                    
                    var zone = Zones()
                    var zoneaarray = [Churches]()
                    
                    if let zoneName = b["zoneName"] as? String, let zoneKey = b["zoneKey"]  as? String, let churcharray = b["churches"] as? [String:AnyObject] {
                        zone.zoneName = zoneName
                        zone.zoneKey = zoneKey
                        for (c,d) in churcharray {
                            var church = Churches()
                            
                            if let churchName = d["churchName"] as? String, let churchKey = d["churchKey"] as? String {
                                church.churchName = churchName
                                church.churchID = churchKey
                                zoneaarray.append(church)
                                zone.churchArray?.append(church)
                            }
                        }
                        zone.churchArray = zoneaarray
                        self.zoneArray.append(zone)
                    }
                    
                }
                self.zonesDpdn.reloadAllComponents()
            }
            self.zonesDpdn.reloadAllComponents()
        })
      
        self.zonesDpdn.reloadAllComponents()
        ref.removeAllObservers()
    }
    


}
