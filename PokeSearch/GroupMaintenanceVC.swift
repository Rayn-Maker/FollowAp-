//
//  GroupMaintenanceVC.swift
//  PokeSearch
//
//  Created by Radiance Okuzor on 1/17/18.
//  Copyright © 2018 Radiance Okuzor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class GroupMaintenanceVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
        
       retrieveOrganizations()
        fetchCourses()
    }
    
    @IBOutlet weak var eventsdropdown: UIPickerView!
    @IBOutlet weak var soulAddTableView: UITableView!
    var churchArray = [Churches]()
    var organization = [OrgData]()
    var eventsIdToAdd = Churches()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organization.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "organizationCell2", for: indexPath)
        cell.textLabel?.text = self.organization[indexPath.row].OrgTitle
       
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // add to the selected group
        let ref = FIRDatabase.database().reference()
//        let key =  ref.child("Organizations").childByAutoId().key
        
        let prayers = [ "\(self.organization[indexPath.row].OrgId ?? "")" :"\(self.organization[indexPath.row].OrgId ?? "")"] // var inviteeID: String!
        
        
        let parameters = [ "ChurchName" : eventsIdToAdd.churchName,
                           "ChurchKey" : eventsIdToAdd.churchID,
                           "ZoneName" : eventsIdToAdd.churchZoneName,
                           "ZoneKey" : eventsIdToAdd.churchZoneId]
        
        let underOrg = ["\(self.organization[indexPath.row].OrgId ?? "")" : parameters]
        ref.child("Organizations").child(self.organization[indexPath.row].OrgId!).child("MyChurch").updateChildValues(underOrg)
        ref.child("Organizations").child(self.organization[indexPath.row].OrgId!).child("MyZone").updateChildValues(underOrg)
        ref.child("churches").child(eventsIdToAdd.churchID!).child("cells").updateChildValues(prayers)
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
        soulAddTableView.isHidden = false
        eventsIdToAdd.churchID = churchArray[row].churchID
        eventsIdToAdd.churchName = churchArray[row].churchName
        eventsIdToAdd.churchZoneName = churchArray[row].churchZoneName
        eventsIdToAdd.churchZoneId = churchArray[row].churchZoneId
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return churchArray[row].churchName
        
    }
    
    func retrieveOrganizations() {
        
        let ref = FIRDatabase.database().reference()
        ref.child("Organizations").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.value is NSNull {
                print("organiation folder is null")
            }
            else {
                let users = snapshot.value as! [String : AnyObject]
                
                self.organization.removeAll()
                
                for (_, value) in users {
                    
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                    let organizationToShow = OrgData()
                    if let creator = value["creator"] as? String, let creatorID = value["creatorID"] as? String, let organizationID = value["organizationID"] as? String, let organizationName = value["organizationName"] as? String, let dateString = value["date"] as? String, let date = dateFormatter.date(from: dateString)  {
                        organizationToShow.OrgCreatorName = creator
                        organizationToShow.OrgCreatorId = creatorID
                        organizationToShow.OrgId = organizationID
                        organizationToShow.OrgTitle = organizationName
                        organizationToShow.date = date
                        self.organization.insert(organizationToShow, at: 0)
                    }
                    
                }
                self.organization.sort(by: { $0.date.compare($1.date) == .orderedDescending })
               
                self.soulAddTableView.reloadData()
            }
            
        })
        ref.removeAllObservers()
    }
    
    func fetchCourses(){
        let ref = FIRDatabase.database().reference()
        ref.child("churches").queryOrderedByKey().observeSingleEvent(of: .value, with: { soulSnapShot in
            if soulSnapShot.value is NSNull {
                
                /// dont do anything
            } else {
                let zones = soulSnapShot.value as! [String:AnyObject]
                for (a,b) in zones {
                    var church = Churches()
                    
                    if let zoneName = b["zoneName"] as? String, let zoneKey = b["zoneID"]  as? String, let churchName = b["churchName"] as? String, let churchId = b["churchKey"]  as? String {
                        church.churchName = churchName
                        church.churchID = churchId
                        church.churchZoneId = zoneKey
                        church.churchZoneName = zoneName
                    }
                    self.churchArray.append(church)
                }
            }
             self.eventsdropdown.reloadAllComponents()
        })
        ref.removeAllObservers()
        eventsdropdown.reloadAllComponents()
    }
    
    @IBAction func homePressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}
