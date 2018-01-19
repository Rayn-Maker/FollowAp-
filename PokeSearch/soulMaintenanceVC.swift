//
//  soulMaintenanceVC.swift
//  PokeSearch
//
//  Created by Radiance Okuzor on 1/19/18.
//  Copyright © 2018 Radiance Okuzor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class soulMaintenanceVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
     
        retrieveAllLeaders()
        fetchAlLSouls()
    }

    @IBOutlet weak var zonesDpdn: UIPickerView!
    @IBOutlet weak var soulAddTableView: UITableView!
    var churchArray = [Churches]()
    var leaderToget = LeadersData()
    var soulArray = [SoulData]()
    var AllLeaders = [LeadersData]()

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soulArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "soulMaintenance", for: indexPath)
        cell.textLabel?.text = self.soulArray[indexPath.row].firstName + self.soulArray[indexPath.row].lastName
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // add to the selected group
        let ref = FIRDatabase.database().reference()
        

        
        let prayers2 = [soulArray[indexPath.row].soulID : soulArray[indexPath.row].soulID]
        
        ref.child("leaders").child(leaderToget.userID).child("myInvites").updateChildValues(prayers2)
        

        
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
        
        return AllLeaders.count
        
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        eventsdropdown.isHidden = true
        //        soulAddTableView.isHidden = false
        leaderToget.userID = AllLeaders[row].userID
        leaderToget.fullName = AllLeaders[row].fullName
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return AllLeaders[row].fullName
        
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
            self.zonesDpdn.reloadAllComponents()
        })
        ref.removeAllObservers()
    
        
    }
    
    func fetchAlLSouls() {
        let ref = FIRDatabase.database().reference()
        
        ref.child("souls").queryOrderedByKey().observeSingleEvent(of: .value, with: { soulSnapShot in
            if soulSnapShot.value is NSNull {
                
                /// dont do anything
            } else {
                let allSoulsKey = soulSnapShot.value as! [String:AnyObject]
                for (a,b) in allSoulsKey {
                    var soulToShow = SoulData()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                    if let invitee = b["invitee"] as? String, let soulID = b["soulID"] as? String,  let firstName = b["firstName"] as? String,  let lastName = b["lastName"] as? String,  let phoneNumber = b["phoneNumber"] as? String,  let email = b["email"] as? String,  let school = b["school"] as? String,  let address = b["address"] as? String,  let eventContacted = b["eventContacted"] as? String,  let race = b["race"] as? String,  let sex = b["sex"] as? String ,  let orgId = b["orgId"] as? String,  let eventId = b["eventId"] as? String,  let ir = b["IR"] as? Double, let dateString = b["Date"] as? String, let date = dateFormatter.date(from: dateString)  {
                        soulToShow.invitee = invitee
                        soulToShow.soulID = soulID
                        soulToShow.firstName = firstName
                        soulToShow.lastName = lastName
                        soulToShow.address = address
                        soulToShow.phoneNumber = phoneNumber
                        soulToShow.eventContacted = eventContacted
                        soulToShow.race = race
                        soulToShow.sex = sex
                        soulToShow.email = email
                        soulToShow.school = school
                        soulToShow.eventID = eventId
                        soulToShow.OrgID = orgId
                        soulToShow.date = date
                        soulToShow.ir = ir
                        self.soulArray.append(soulToShow)
                    }
                }
                 self.soulArray.sort(by: { $0.firstName < $1.firstName })
                 self.soulAddTableView.reloadData()
            }
        })
        ref.removeAllObservers()
       
        
    }
    
    @IBAction func homePressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}
