//
//  LeaderMaintenanceVC.swift
//  PokeSearch
//
//  Created by Radiance Okuzor on 1/18/18.
//  Copyright © 2018 Radiance Okuzor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class LeaderMaintenanceVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchCHurch()
        retrieveAllLeaders()
    }
    
    @IBOutlet weak var zonesDpdn: UIPickerView!
    @IBOutlet weak var soulAddTableView: UITableView!
    var churchArray = [Churches]()
    var eventsIdToAdd = Churches()
     var AllLeaders = [LeadersData]()
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AllLeaders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leadersMaintenance", for: indexPath)
        cell.textLabel?.text = self.AllLeaders[indexPath.row].fullName
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // add to the selected group
        let ref = FIRDatabase.database().reference()

        
        let undrUsers = ["MyChurch/\(self.eventsIdToAdd.churchID!)" : self.eventsIdToAdd.churchID!]
        let undrUsers2 = ["MyZones/\(self.eventsIdToAdd.churchZoneId!)" : self.eventsIdToAdd.churchZoneId!]
        let undrZones = ["Members/\(self.AllLeaders[indexPath.row].userID!)" : self.AllLeaders[indexPath.row].userID!]
        let undrChurches = ["Members/\(self.AllLeaders[indexPath.row].userID!)" : self.AllLeaders[indexPath.row].userID!]

//        self.ref.child("leaders").child(user.uid).setValue(userInfo)
        ref.child("leaders").child(self.AllLeaders[indexPath.row].userID!).updateChildValues(undrUsers)
        ref.child("leaders").child(self.AllLeaders[indexPath.row].userID!).updateChildValues(undrUsers2)
        ref.child("zones").child(self.eventsIdToAdd.churchZoneId!).updateChildValues(undrZones)
        ref.child("churches").child(self.eventsIdToAdd.churchID!).updateChildValues(undrChurches)
        ref.child("zones").child(self.eventsIdToAdd.churchZoneId!).child("churches").child(self.eventsIdToAdd.churchID!).updateChildValues(undrChurches)
        
//        let prayers = [ self.AllLeaders[indexPath.row].userID :"\(self.AllLeaders[indexPath.row].userID ?? "")"] // var inviteeID: String!
//        
//        
//        let parameters = [ "ChurchName" : eventsIdToAdd.churchName,
//                           "ChurchKey" : eventsIdToAdd.churchID,
//                           "ZoneName" : eventsIdToAdd.churchZoneName,
//                           "ZoneKey" : eventsIdToAdd.churchZoneId]
//        
//        let underOrg = ["\(self.eventsIdToAdd.churchID ?? "")" : parameters]
//        ref.child("leaders").child(self.AllLeaders[indexPath.row].userID!).child("MyChurch").updateChildValues(underOrg)
//        ref.child("churches").child(self.eventsIdToAdd.churchID!).child("Members").updateChildValues(prayers)
//        ref.child("zones").child(self.eventsIdToAdd.churchZoneId!).child("Members").updateChildValues(prayers)
        //            let indexPath = tableView.indexPathForSelectedRow
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.green
        // cell.selectedBackgroundView = backgroundView
        self.soulAddTableView.cellForRow(at: indexPath)?.selectedBackgroundView = backgroundView
        self.soulAddTableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "done"
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return  1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return churchArray.count
        
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        eventsdropdown.isHidden = true
//        soulAddTableView.isHidden = false
        eventsIdToAdd.churchID = churchArray[row].churchID
        eventsIdToAdd.churchName = churchArray[row].churchName
        eventsIdToAdd.churchZoneName = churchArray[row].churchZoneName
        eventsIdToAdd.churchZoneId = churchArray[row].churchZoneId
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return churchArray[row].churchName
        
    }
    

    
    var zoneArray = [Zones]()
    
    func retrieveAllLeaders() {
        let ref = FIRDatabase.database().reference()
        
        ref.child("leaders").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.value is NSNull {
                print("My Members folder is null")
            }
            else {
                let users = snapshot.value as! [String : AnyObject]
                self.AllLeaders.removeAll()
                for (_, value) in users {
                    if let uid = value["uid"] as? String {
                            var userToShow = LeadersData()
                            if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String, let email = value["email"] as? String, let password = value["password"] as? String, let cityState = value["cityState"] as? String {
                                userToShow.fullName = fullName
                                userToShow.imagePath = imagePath
                                userToShow.userID = uid
                                userToShow.cityState = cityState
                                userToShow.email = email
                                self.AllLeaders.append(userToShow)
                            }
                       
                    }
                }
                self.AllLeaders.sort(by: { $0.fullName < $1.fullName })
             
            }
            self.soulAddTableView.reloadData()
        })
        ref.removeAllObservers()
        soulAddTableView.reloadData()
        
    }

    func fetchCHurch() {
        let ref = FIRDatabase.database().reference()
        
        ref.child("churches").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.value is NSNull {
                print("My Members folder is null")
            }
            else {
                let users = snapshot.value as! [String : AnyObject]
                self.churchArray.removeAll()
                for (_, b) in users {
                    
                            var church = Churches()
                            if let zoneName = b["zoneName"] as? String, let zoneKey = b["zoneID"]  as? String, let churchName = b["churchName"] as? String, let churchId = b["churchKey"]  as? String {
                                church.churchName = churchName
                                church.churchID = churchId
                                church.churchZoneId = zoneKey
                                church.churchZoneName = zoneName
                            }
                        self.churchArray.append(church)
                }
               // self.AllLeaders.sort(by: { $0.fullName < $1.fullName })
                
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
