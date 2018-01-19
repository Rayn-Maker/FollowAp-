//
//  AdminVC.swift
//  PokeSearch
//
//  Created by Radiance Okuzor on 1/17/18.
//  Copyright © 2018 Radiance Okuzor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class AdminVC: UIViewController,  UIPickerViewDataSource, UIPickerViewDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        fetchZones()
    }

    @IBOutlet weak var zonesDpdn: UIPickerView!
    var zoneID: String?
    var zoneName: String?
    var zoneArray = [Zones]()
    var ref: FIRDatabaseReference!
    
    @IBAction func chooseZone(_ sender: Any) {
        //zonesDpdn.isHidden = false
        // create class/course
        
        let uid = FIRAuth.auth()?.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let eventKey = ref.child("zones").childByAutoId().key
        
        let alert = UIAlertController(title: "New Event", message: "What's Your Event Name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter event name here"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let post = UIAlertAction(title: "Create", style: .default) { _ in
            guard let text = alert.textFields?.first?.text else { return }
            if text != "" {
                print(text)
                
                let dateString = String(describing: Date())
                
                let parameters = ["className"    : eventKey,
                                  "classChurch"  : text,
                                  "classZone"    : uid,
                                 // "classPastor"  : Auth.auth().currentUser!.displayName!,
                                  "date"         : dateString]
                let event = ["\(eventKey)" : parameters]
                ref.child("churches").updateChildValues(event)
            }
        }
        alert.addAction(cancel)
        alert.addAction(post)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func createZone(_ sender: Any) {
        createZone()
        
    }
    
    
    @IBAction func createChurch(_ sender: Any) {
        
        createChurch()
    }
    
    func createZone(){
        
        let uid = FIRAuth.auth()?.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let eventKey = ref.child("zones").childByAutoId().key
        
        let alert = UIAlertController(title: "New Event", message: "What's Your Event Name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter event name here"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let post = UIAlertAction(title: "Create", style: .default) { _ in
            guard let text = alert.textFields?.first?.text else { return }
            if text != "" {
                print(text)
                
                let dateString = String(describing: Date())
                
                let parameters = ["zoneKey"    : eventKey,
                                  "zoneName"  : text,
                                  "zoneCreatorID"         : uid,
                                  "zoneCreatorName"      :FIRAuth.auth()?.currentUser?.displayName ,
                                  "date"              : dateString]
                let event = ["\(eventKey)" : parameters]
                ref.child("zones").updateChildValues(event)
            }
        }
        alert.addAction(cancel)
        alert.addAction(post)
        present(alert, animated: true, completion: nil)
    }
    
    func createChurch(){
        
        let uid = FIRAuth.auth()?.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let eventKey = ref.child("zones").childByAutoId().key
        
        let alert = UIAlertController(title: "New Event", message: "What's Your Event Name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter event name here"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let post = UIAlertAction(title: "Create", style: .default) { _ in
            guard let text = alert.textFields?.first?.text else { return }
            if text != "" {
                print(text)
                
                let dateString = String(describing: Date())
                
                let parameters = ["churchKey"    : eventKey,
                                  "churchName"  : text,
                                  "creatorID"         : uid,
                                  "creatorName"        : FIRAuth.auth()?.currentUser?.displayName ,
                                  "date"              : dateString,
                                  "zoneID" : self.zoneID,
                                  "zoneName": self.zoneName]
                let event = ["\(eventKey)" : parameters]
//                let undrZones = ["Churches/\(eventKey)" : eventKey]
                ref.child("zones").child(self.zoneID!).child("churches").updateChildValues(event)
                ref.child("churches").updateChildValues(event)
            }
        }
        alert.addAction(cancel)
        alert.addAction(post)
        present(alert, animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return zoneArray[row].zoneName
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return zoneArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        zoneID = zoneArray[row].zoneKey
        zoneName = zoneArray[row].zoneName
//        zonesDpdn.isHidden = true
    }
    
    func fetchZones(){
        ref.child("zones").queryOrderedByKey().observeSingleEvent(of: .value, with: { soulSnapShot in
            if soulSnapShot.value is NSNull {
                
                /// dont do anything
            } else {
                let zones = soulSnapShot.value as! [String:AnyObject]
                for (a,b) in zones {
                    
                    var zone = Zones()
                    
                    if let zoneName = b["zoneName"] as? String, let zoneKey = b["zoneKey"]  as? String {
                        zone.zoneName = zoneName
                        zone.zoneKey = zoneKey
                        
                        self.zoneArray.append(zone)
                    }
                }
            }
            self.zonesDpdn.reloadAllComponents()
        })
        ref.removeAllObservers()
        zonesDpdn.reloadAllComponents()
    }
    
    func fetchCourses(){
        ref.child("zones").queryOrderedByKey().observeSingleEvent(of: .value, with: { soulSnapShot in
            if soulSnapShot.value is NSNull {
                
                /// dont do anything
            } else {
                let zones = soulSnapShot.value as! [String:AnyObject]
                for (a,b) in zones {
                    
                    var zone = Zones()
                    
                    if let zoneName = b["zoneName"] as? String, let zoneKey = b["zoneKey"]  as? String {
                        zone.zoneName = zoneName
                        zone.zoneKey = zoneKey
                        
                        self.zoneArray.append(zone)
                    }
                }
            }
            self.zonesDpdn.reloadAllComponents()
        })
        ref.removeAllObservers()
        zonesDpdn.reloadAllComponents()
    }
    
    @IBAction func homePressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}

extension AdminVC: UITableViewDataSource, UITableViewDelegate,  UISearchBarDelegate  {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coursesTable", for: indexPath)
        cell.textLabel!.text = zoneArray[indexPath.row].creatorID
        return cell
    }
}
