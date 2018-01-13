//
//  EventHomeVC.swift
//  InstagramLike
//
//  Created by Radiance Okuzor on 6/29/17.
//  Copyright © 2017 Vasil Nunev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class EventHomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate  {

    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var sendSoulBtn: UIButton!
    @IBOutlet weak var moveSouls: UIButton!
    @IBOutlet weak var orgNameTitle: UILabel!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == soulstableView {
             return soulArray.count ?? 0
        }
        if tableView == soulAddTableView {
            return soulArray.count
        }
       return soulArray.count
    }
    
    @IBOutlet weak var eventsdropdown: UIPickerView!
    @IBOutlet weak var soulstableView: UITableView!
    @IBOutlet weak var soulAddTableView: UITableView!
    
    var soulArray = [SoulData]()
    var eventInfo = EventData()
    var OrgStuf = OrgData()
    var eventArray = [EventData]()
    var eventsIdToAdd: String!
    var mySoulsKey = [String]()
    
    
    @IBOutlet weak var pageName: UILabel!
    
    var orgName: String!  // org folder
    var eventName: String!  // event Folder
    var eventID: String! // event id
    var orgID: String! // org's id
    var soulsID: String! // org's id

    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        ref = FIRDatabase.database().reference()
        
        pageName.text = eventInfo.eventName
        
        self.orgName = eventInfo.eventGroup
        orgNameTitle.text = orgName
        eventName = eventInfo.eventName
        
        eventID = eventInfo.eventId
        
        orgID = eventInfo.eventGroupId
        
         checkEvent()
        firsView()
       retrieveSouls()
        
        
    }
    
    func checkEvent() {
        if eventArray.count > 0 {
        for x in 0...eventArray.count - 1 {
            if eventArray[x].eventId == eventID {
                eventArray.remove(at: x)
                eventsdropdown.reloadAllComponents()
                break 
            }
        }
        }
    }
    
    
    func retrieveSouls() {
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("Organizations").child(self.orgID!).child("Events").child(self.eventID!).child("invites").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.value is NSNull {
                
            }
            else {
                let soulsKey = snapshot.value as! [String : AnyObject]
                self.soulArray.removeAll()
                self.mySoulsKey.removeAll()
                
                for (x,y) in soulsKey {
                    self.mySoulsKey.append(y as! String)
                }
                
                // use array to collect all the soul keys then go inside soul archive and compare key with soul key then if same get value.
                
                
                ref.child("souls").queryOrderedByKey().observeSingleEvent(of: .value, with: { soulSnapShot in
                    if soulSnapShot.value is NSNull {
                        
                        /// dont do anything
                    } else {
                        let allSoulsKey = soulSnapShot.value as! [String:AnyObject]
                        for (a,b) in allSoulsKey {
                            for each in self.mySoulsKey {
                                var soulToShow = SoulData()
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                                if each == a {
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
                            }
                        }
                    }
                    self.soulArray.sort(by: { $0.firstName.lowercased() < $1.firstName.lowercased() })
                    self.soulstableView.reloadData()
                    self.soulAddTableView.reloadData()
                    ref.removeAllObservers()
                    
                })
               
            }
        })
        ref.removeAllObservers()
        
    }
    
    
    func numberOfSections(in prayerTable: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == soulstableView {
           // let indexPath = tableView.indexPathForSelectedRow
            self.soulsID = self.soulArray[(indexPath.row)].soulID
            
            performSegue(withIdentifier: "eventToSoulData", sender: nil)
        }
        if tableView == soulAddTableView {
            // add to the selected group
            let ref = FIRDatabase.database().reference()
            let key =  ref.child("Organizations").child(orgName).child(eventName).child("invites").childByAutoId().key
                
            let prayers = [ key :"\(self.soulArray[indexPath.row].soulID ?? "")"] // var inviteeID: String!
   
            
        ref.child("Organizations").child(self.orgID!).child("Events").child(self.eventsIdToAdd!).child("invites").updateChildValues(prayers)
//            let indexPath = tableView.indexPathForSelectedRow
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.green
           // cell.selectedBackgroundView = backgroundView
            self.soulAddTableView.cellForRow(at: indexPath)?.selectedBackgroundView = backgroundView
            self.soulAddTableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "done"

        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == soulstableView {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "soulsCell", for: indexPath) as! SoulDataCell
            
            cell.soulName?.text = "\(self.soulArray[indexPath.row].firstName!) \(self.soulArray[indexPath.row].lastName!) "
            return cell
        }
        if tableView == soulAddTableView {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "soulToAddCell", for: indexPath)

            
            cell.textLabel?.text = "\(self.soulArray[indexPath.row].firstName!) \(self.soulArray[indexPath.row].lastName!) "
            return cell
        } else{
            let cell =  tableView.dequeueReusableCell(withIdentifier: "soulToAddCell", for: indexPath)
            
            
            cell.textLabel?.text = "\(self.soulArray[indexPath.row].firstName!) \(self.soulArray[indexPath.row].lastName!) "
            return cell
        }
      
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventToSoulData" {
            let vc = segue.destination as! SoulDataVC
            let indexPath = soulstableView.indexPathForSelectedRow
            vc.noteKeys.append(self.orgID)
            vc.noteKeys.append(self.eventID)
            vc.noteKeys.append(self.soulsID)
            vc.noteKeys.append(self.soulArray[(indexPath!.row)].firstName)
            vc.soulData = self.soulArray[(indexPath!.row)]

        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////// variables \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    
    
    var newSoulInvitee: String!
    var newSoulSoulID: String!
    var newSoulFirstName: String!
    var newSoulLastName: String!
    var newSoulAddress: String!
    var newSoulPhoneNumber: String!
    var newSoulEventContacted: String!
    var newSoulRace: String!
    var newSoulSex: String!
    var newSoulEmail: String!
    var newSoulSchool: String!
    
    var formerSoulInvitee: String!
    var formerSoulSoulID: String!
    var formerSoulFirstName: String!
    var formerSoulLastName: String!
    var formerSoulAddress: String!
    var formerSoulPhoneNumber: String!
    var formerSoulEventContacted: String!
    var formerSoulRace: String!
    var formerSoulSex: String!
    var formerSoulEmail: String!
    var formerSoulSchool: String!
    
    //////////////////////////////////////////// end vairables \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    
    ///////////////////////////// Soul To Add outlets  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    @IBOutlet weak var firstNameText: UITextField!
    
    @IBOutlet weak var lastNameText: UITextField!
    
    @IBOutlet weak var addressText: UITextField!
    
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var raceText: UITextField!
    
    @IBOutlet weak var sexText: UITextField!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var schoolText: UITextField!
    
    func hideNewSoulText(){
        firstNameText.isHidden = true
        lastNameText.isHidden = true
        addressText.isHidden = true
        phoneNumber.isHidden = true
        raceText.isHidden = true
        sexText.isHidden = true
        emailText.isHidden = true
        schoolText.isHidden = true
//        hiThereLbl.isHidden = true
    }
    func showNewSoulData(){
        firstNameText.isHidden = false
        lastNameText.isHidden = false
        addressText.isHidden = false
        phoneNumber.isHidden = false
        raceText.isHidden = false
        sexText.isHidden = false
        emailText.isHidden = false
        schoolText.isHidden = false
//        hiThereLbl.isHidden = false
    }
    
    
    ///////////////////////////// save outlets done  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    
    ///////////////////////////// Soul To show outlets  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var newSoulBtn: UIButton!
    

    
    func hideSoulProfile() {
        
//        formerSoulFirstNameLabel.isHidden = true
//        formerSoulLastNameLabel.isHidden = true
//        formerSoulEmailLabel.isHidden = true
//        formerSoulAddressLabel.isHidden = true
//        formerSoulSchoolLabel.isHidden = true
//        formerSoulSexLabel.isHidden = true
//        formerSoulRaceLabel.isHidden = true
//        formerSoulPhoneLabel.isHidden = true
        
    }
    
    func showSoulProfile() {
        
//        formerSoulFirstNameLabel.isHidden = false
//        formerSoulLastNameLabel.isHidden = false
//        formerSoulEmailLabel.isHidden = false
//        formerSoulAddressLabel.isHidden = false
//        formerSoulSchoolLabel.isHidden = false
//        formerSoulSexLabel.isHidden = false
//        formerSoulRaceLabel.isHidden = false
//        formerSoulPhoneLabel.isHidden = false
        saveBtn.isHidden = true
    }
    
    func firsView() {
        saveBtn.isHidden = true
        hideSoulProfile()
        hideNewSoulText()
        soulstableView.isHidden = false
        newSoulBtn.isHidden = false
        pageName.isHidden = false
        orgNameTitle.isHidden = false
        newSoulBtn.isHidden = false
//        hiThereLbl.isHidden = true
        cancelBtn.isHidden = true
        sendSoulBtn.isHidden = false
       moveSouls.isHidden = true
    }
    
    
    
    ///////////////////////////// Soul To Add outlets done  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    func connectLabelToSoul() {
        

//        formerSoulFirstNameLabel.text = formerSoulFirstName
//        formerSoulLastNameLabel.text = formerSoulLastName
//        formerSoulEmailLabel.text = formerSoulEmail
//        formerSoulAddressLabel.text = formerSoulAddress
//        formerSoulSchoolLabel.text = formerSoulSchool
//        formerSoulSexLabel.text = formerSoulSex
//        formerSoulRaceLabel.text = formerSoulRace
    }
    
    func labelsForNewSoul() {
        
//        formerSoulFirstNameLabel.text = "First Name"
//        formerSoulLastNameLabel.text = "Last Name"
//        formerSoulEmailLabel.text = "Email"
//        formerSoulAddressLabel.text = "Address"
//        formerSoulSchoolLabel.text = "School"
//        formerSoulSexLabel.text = "Sex"
//        formerSoulRaceLabel.text = "Race"
//        formerSoulPhoneLabel.text = "Phone #"
    }
    
    func cleanLabels() {
        
        firstNameText.text = ""
        lastNameText.text = ""
        emailText.text = ""
        addressText.text = ""
        schoolText.text = ""
        sexText.text = ""
        raceText.text = ""
        phoneNumber.text = ""
    }
    
    
    
    var SoulProfInfo = SoulData()
    
    
    var ref: FIRDatabaseReference!
    
    @IBAction func sendSoulPresed(_ sender: Any){
        
        self.sendSoulBtn.titleLabel!.text = "done"
        
        eventsdropdown.isHidden = false
        sendSoulBtn.isHidden = true
        moveSouls.isHidden = false
        
    }
    
    @IBAction func sendSouls(_ sender: Any){
        soulAddTableView.isHidden = true
        sendSoulBtn.isHidden = false 
         moveSouls.isHidden = true
    }
    
    @IBAction func savePressed(_ sender: Any) {
   
    var userName: String!
    userName = FIRAuth.auth()!.currentUser!.displayName!
    let uid = FIRAuth.auth()!.currentUser!.uid
    let ref = FIRDatabase.database().reference()
    let soulID = ref.child("Organizations").child(orgName).child(eventName).child("invites").childByAutoId().key
    let key = ref.child("Organizations").child(orgName).child(eventName).childByAutoId().key
    if self.firstNameText.text != "" && self.lastNameText.text != "" && (phoneNumber.text != "" || (phoneNumber.text?.characters.count)! < 10)  {
    let dateString = String(describing: Date())
    let soul = ["soulID" : soulID,
                "firstName" : firstNameText.text,
                "lastName" : lastNameText.text,
                "phoneNumber" : phoneNumber.text,
                "email" : emailText.text,
                "school" : self.schoolText.text!,
                "address" : self.addressText.text!,
                "eventContacted" : self.eventName,
                "sex" : self.sexText.text,
                "race" : raceText.text,
                "invitee" : userName,
                "inviteeID" : uid,
                "orgId" : self.orgID,
                "eventId" : self.eventID,
                "followCount" : 0,
                "IR" : 0.00,
                "response" : 0,
                "Date" : dateString] as [String : Any]
    
    let prayers = ["\(soulID)" : soul]
        let prayers2 = [key : soulID]
    
    ref.child("Organizations").child(self.orgID!).child("Events").child(self.eventID!).child("invites").updateChildValues(prayers2)
    ref.child("Organizations").child(self.orgID!).child("All_Invites").updateChildValues(prayers2)
    ref.child("souls").updateChildValues(prayers)
    ref.child("leaders").child(uid).child("myInvites").updateChildValues(prayers2)
    
        soulstableView.isHidden = false
        pageName.isHidden = false
        orgNameTitle.isHidden = false
        newSoulBtn.isHidden = false
        hideNewSoulText()
        saveBtn.isHidden = true
        cleanLabels()
        retrieveSouls()
        view.endEditing(true)
        firsView()
        soulstableView.isHidden = false
        pageName.isHidden = false
        orgNameTitle.isHidden = false
        newSoulBtn.isHidden = false
        hideNewSoulText()
        saveBtn.isHidden = true
        cleanLabels()
        retrieveSouls()
    
    } else if (phoneNumber.text?.characters.count)! < 10 || phoneNumber.text != ""{
        let alert = UIAlertController(title: "Wrong Phone Number", message: "Please Provide a valid 10 digit phone number starting with the area code", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    else {
        let alert = UIAlertController(title: "Missing Information", message: "Please Provide First Name, Last Name", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    }
    

    
    @IBAction func cancelPressed(_ sender: Any) {
        firsView()
        cleanLabels()
        view.endEditing(true)
    }
    
    

    @IBAction func newSoulPressed(_ sender: Any) {
        
        soulstableView.isHidden = true
        pageName.isHidden = true
        orgNameTitle.isHidden = true
        newSoulBtn.isHidden = true
        labelsForNewSoul()
        showSoulProfile()
        showNewSoulData()
        saveBtn.isHidden = false
        cancelBtn.isHidden = false
        sendSoulBtn.isHidden = true
    }
    
    @IBAction func refresh(_ sender: Any) {
        viewDidLoad()
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return  1
      
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
    return eventArray.count
        
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventsdropdown.isHidden = true
        soulAddTableView.isHidden = false
        eventsIdToAdd = eventArray[row].eventId
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
            return eventArray[row].eventName
       
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // delet soul at index path in events
        let ref = FIRDatabase.database().reference()
        ref.child("Organizations").child(self.orgID!).child("Events").child(self.eventID!).child("invites").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.value is NSNull {
                print("My Members folder is null")
            }
            else {
                if let eventMembers = snapshot.value as? [String : AnyObject] {
                    for (ke, value) in eventMembers {
                        if value as! String == self.soulArray[indexPath.row].soulID {
                            let alert = UIAlertController(title: "Remove Soul", message: "Are you sure you want to remove Soul from group? you will never have access to this souls data", preferredStyle: .alert)
                            let yes = UIAlertAction(title: "❌Yes Remove❌", style: .destructive, handler: { (_) in
                                ref.child("Organizations").child(self.orgID!).child("Events").child(self.eventID!).child("invites/\(ke)").removeValue(completionBlock: { (error) in
                                    
                                })
                                 ref.child("Organizations").child(self.orgID!).child("All_Invites/\(ke)").removeValue()
                                self.soulArray.remove(at: indexPath.row)
                                self.soulstableView.reloadData()
                            })
                            let no = UIAlertAction(title: "just kidding! let 'em stay", style: .default, handler: nil)
                            alert.addAction(yes)
                            alert.addAction(no)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        })
        
        
    }
    

    
}
