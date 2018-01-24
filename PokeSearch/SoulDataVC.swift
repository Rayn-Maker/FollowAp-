//
//  SoulDataVC.swift
//  PokeSearch
//
//  Created by Radiance Okuzor on 7/13/17.
//  Copyright © 2017 Radiance Okuzor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import MessageUI

class SoulDataVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        scrolView.contentSize.height = 350
        setUPSoulData()
//        firsView()
        
        orgID = noteKeys[0]
        eventID = noteKeys[1]
        soulsID = noteKeys[2]
        firstNameLabel.text = noteKeys[3]
        retrieveNotes()
  
    }
    
    
    ///////////////////////////// Soul Data Variables \\\\\\\\\\\\\\\\\\\\\\\\\\
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UITextView!
    @IBOutlet weak var invitedByLabel: UILabel!
    @IBOutlet weak var eventMetLabel: UILabel!
    @IBOutlet weak var addressLabel: UITextView!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var raceLabel: UILabel!
    
    @IBOutlet weak var selectablePhoneNumb: UITextView!
    
    /////////////////////////////// finish soul data variables \\\\\\\\\\\\\\\\\

    /////////////////////////// Objects To Hide \\\\\\\\\\\\\\\\\\\\\\\



    
//    @IBOutlet weak var addressBarBtn: UITextView!
    
    /////////////////////// finish objects to hide \\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    
    ////////////////////// Variables to recieve keys \\\\\\\\\\\\\\\\\\\\\\
     var noteKeys = [String]()
    var eventID: String! // event id
    var orgID: String! // org's id
    var soulData = SoulData()
    
    /////////////////////// finish keys \\\\\\\\\\\\\\\\\\\\\\\\\\


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count ?? 0
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var notesArray = [SoulNotes]()
    var soulsID = String()
    var phonNumber = String()

    
    

    
    func setUPSoulData(){

        firstNameLabel.text = "First Name: " + soulData.firstName
        lastNameLabel.text = "Last Name: " + soulData.lastName
        emailLabel.text = "Email: " + soulData.email
        invitedByLabel.text =  "Invitee: " + soulData.invitee
        eventMetLabel.text = "Event Met: " + soulData.eventContacted
        addressLabel.text =  "Adrress:" + soulData.address
        schoolLabel.text =  "School/Job: " + soulData.school
        genderLabel.text = "Gender: " + soulData.sex
        raceLabel.text = "Race: " + soulData.race
        selectablePhoneNumb.text = soulData.phoneNumber
        addressLabel.text = "I.R.: " + "\(soulData.ir ?? 0)"
        
    }
    
    
    func numberOfSections(in prayerTable: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        showNotes()
       // soulNotes.text = self.notesArray[indexPath.row].notes
        let alert = UIAlertController(title: " ", message: self.notesArray[indexPath.row].notes, preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "followUpNotes", for: indexPath) as! SoulDataCell
        
        
        cell.soulNotes.text = self.notesArray[indexPath.row].notes
      
        cell.noteTimeStamp.text = self.notesArray[indexPath.row].dateS

        return cell
    }
    
    func truncate(length: Int = 10, trailing: String = "…", string: String) -> String {
        if string.characters.count > length {
            return String(string.characters.prefix(length))
        } else {
            return string
        }
    }
    
    
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }


    
    
    var SoulProfInfo = SoulData()
    
    
    var ref: FIRDatabaseReference!
    
     func newNote() {
            
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        let alert = UIAlertController(title: "Response", message: "Did They Respond", preferredStyle: .alert)
        alert.addTextField { (textField) in
                textField.placeholder = "Enter Note Summary here."
            }
        let yes = UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            var userName: String!
            guard var text = alert.textFields?.first?.text else { return }
            userName = FIRAuth.auth()!.currentUser!.displayName!
            let notesKey = ref.child("souls").child(self.soulsID).child("FollowUP_Notes").childByAutoId().key
            
            // go in and updat ir
            
            ref.child("souls").child(self.soulsID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.value is NSNull {
                    // create file and fill
                } else {
                    if let soul = snapshot.value as? [String : AnyObject] {
                        var irr = soul["response"] as! Int
                        irr += 1
                        
                        var folcount = soul["followCount"] as! Int
                        var iRate = Double()
                        folcount += +1
                        
                       iRate = Double(irr) / Double(folcount)
                    
                        iRate = Double(round(100*iRate)/100)
                        let updateResponse = ["response" : irr]
                        let updateFcount = ["followCount" : folcount]
                        let updateIR = ["IR" : iRate]
                        ref.child("souls").child(self.soulsID).updateChildValues(updateResponse)
                        ref.child("souls").child(self.soulsID).updateChildValues(updateFcount)
                        ref.child("souls").child(self.soulsID).updateChildValues(updateIR)
                        
                      
                        
                      self.view.endEditing(true)
                        
                    }
                }
                
            }) //
            let dateString = String(describing: Date())
            
            let note = ["notesKey" : notesKey,
                        "Notes" : text,
                        "Author" : userName,
                        "time" : dateString] as [String : Any]
            
            let prayers = ["\(notesKey)" : note]
            
            text += "Notes By \(userName)"
            
            ref.child("souls").child(self.soulsID).child("Follow_Up_Notes").updateChildValues(prayers)
           
        })
        let no = UIAlertAction(title: "No", style: .destructive, handler: { (_) in
            var userName: String!
            guard var text = alert.textFields?.first?.text else { return }
            userName = FIRAuth.auth()!.currentUser!.displayName!
            
            let notesKey = ref.child("souls").child(self.soulsID).child("FollowUP_Notes").childByAutoId().key
           
            ref.child("souls").child(self.soulsID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.value is NSNull {
                    // create file and fill
                } else {
                    if let soul = snapshot.value as? [String : AnyObject] {
                        var irr = soul["response"] as! Int
                        var folcount = soul["followCount"] as! Int
                        var iRate = Double()
                        folcount += +1
                        
                        iRate = Double(irr) / Double(folcount)
                        
                        iRate = Double(round(100*iRate)/100)
                        
                        let updateResponse = ["response" : irr]
                        let updateFcount = ["followCount" : folcount]
                        let updateIR = ["IR" : iRate]
                        
                        let updateDict = ["response" : irr,
                                          "followCount" : folcount,
                                          "IR" : iRate] as [String : Any]
                        
          
                        
                        ref.child("souls").child(self.soulsID).updateChildValues(updateResponse)
                        ref.child("souls").child(self.soulsID).updateChildValues(updateFcount)
                        ref.child("souls").child(self.soulsID).updateChildValues(updateIR)
                    
                        self.view.endEditing(true)
                    }
                }
                
            }) //
            let dateString = String(describing: Date())
            
            let note = ["notesKey" : notesKey,
                        "Notes" : text,
                        "Author" : userName,
                        "time" : dateString] as [String : Any]
            
            let prayers = ["\(notesKey)" : note]
            
            text += "Notes By \(userName)"
            
            ref.child("souls").child(self.soulsID).child("Follow_Up_Notes").updateChildValues(prayers)
        })
        
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
       
            retrieveNotes()
           
    }


    
    // Retrieve Follow Up Notes
    
    func retrieveNotes() {
        
        let ref = FIRDatabase.database().reference()
        ref.child("souls").child(soulsID).child("Follow_Up_Notes").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.value is NSNull {
               
            }
            else {
                
                print("soulsData is not null data:\(self.soulsID)")
                let souls = snapshot.value as! [String : AnyObject]
                self.notesArray.removeAll()
                
                for (_, value) in souls {
                    let dateFormatter = DateFormatter()
                    let dateFormatPring = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                    dateFormatPring.dateFormat = "MMM dd,yyyy hh:mm"
                    
                    var notesToShow = SoulNotes()
                    if let notes = value["Notes"] as? String, let notesKey = value["notesKey"] as? String,  let dateString = value["time"] as? String,  let author = value["Author"] as? String , let date = dateFormatter.date(from: dateString) {
                        dateFormatPring.string(from: date)
                        notesToShow.notes = notes
                        notesToShow.author = author
                        notesToShow.date = date
                        notesToShow.dateS = dateFormatPring.string(from: date)
                        notesToShow.notesKey = notesKey
                        self.notesArray.insert(notesToShow, at: 0)
                    }
                }
                
                 self.notesArray.sort(by: { $0.date.compare($1.date) == .orderedDescending })
                self.tableView.reloadData()
            }
        })
        ref.removeAllObservers()
        
    }
    
    func attendance() {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        let alert = UIAlertController(title: "Attendance", message: "Did they attend the meeting", preferredStyle: .alert)

        let yes = UIAlertAction(title: "Yes", style: .default, handler: { (_) in
          
            let notesKey = ref.child("souls").child(self.soulsID).child("FollowUP_Notes").childByAutoId().key
        
            let dateString = String(describing: Date())
            
            let strAr = dateString.components(separatedBy: " ")
            let note = ["came" : "yes",
                        "date" : strAr[0],
                        "eventName" :  self.soulData.eventContacted,
                        "eventID" : self.soulData.eventID] as [String : Any]
            let note2 = ["came" : "yes",
                         "date" : strAr[0],
                         "name" : self.soulData.firstName + " " + self.soulData.lastName,
                         "soulId" : self.soulData.soulID] as [String : Any]
            
            let prayers = ["\(strAr[0])" : note]
            let prayers2 = ["\(self.soulsID)" : note2]
            
            ref.child("souls").child(self.soulsID).child("Attendance").updateChildValues(prayers)
            ref.child("Organizations").child(self.orgID).child("Events").child(self.eventID).child("Attendance").child(strAr[0]).updateChildValues(prayers2)
            
        })
        let no = UIAlertAction(title: "No", style: .default, handler: { (_) in
            
            let notesKey = ref.child("souls").child(self.soulsID).child("FollowUP_Notes").childByAutoId().key
            let dateString = String(describing: Date())
            
            let strAr = dateString.components(separatedBy: " ")
            
            let note = ["came" : "no",
                        "date" : strAr[0],
                        "eventName" :  self.soulData.eventContacted,
                        "eventID" : self.soulData.eventID] as [String : Any]
            let note2 = ["came" : "no",
                         "date" : strAr[0],
                         "name" : self.soulData.firstName + " " + self.soulData.lastName,
                         "soulId" : self.soulData.soulID] as [String : Any]
            
            let prayers = ["\(strAr[0])" : note]
            let prayers2 = ["\(self.soulsID)" : note2]
            
            ref.child("souls").child(self.soulsID).child("Attendance").updateChildValues(prayers)
            ref.child("Organizations").child(self.orgID).child("Events").child(self.eventID).child("Attendance").child(strAr[0]).updateChildValues(prayers2)
            
        })
        
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
        
        retrieveNotes()
        
    }

    
    @IBAction func call(_ sender: Any?){
        let ref = FIRDatabase.database().reference()
        let dateString = String(describing: Date())
        let undrChurches = ["recent" : dateString]
        ref.child("souls").child(self.soulsID).updateChildValues(undrChurches)
        self.phonNumber = self.soulData.phoneNumber
        self.phonNumber = self.phonNumber.replacingOccurrences(of: "-", with: "")
        self.phonNumber = self.phonNumber.replacingOccurrences(of: " ", with: "")
        self.phonNumber = self.phonNumber.replacingOccurrences(of: ")", with: "")
        self.phonNumber = self.phonNumber.replacingOccurrences(of: "(", with: "")
        self.phonNumber = self.phonNumber.replacingOccurrences(of: "+", with: "")
        
        if phonNumber.count > 10 {
            phonNumber.removeFirst(1)
        }
        let dd =  (self.phonNumber as NSString).integerValue
        
        guard let number = URL(string: "tel://" + "\(dd )") else {
            return
            // set an aler
            
        }
        UIApplication.shared.open(number)
      
        
    }
    
    @IBAction func sendMessage(_ sender: Any?) {
        let ref = FIRDatabase.database().reference()
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = [soulData.phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        let dateString = String(describing: Date())
        let undrChurches = ["recent" : dateString]
        ref.child("souls").child(self.soulsID).updateChildValues(undrChurches)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
 
    
    @IBAction func urgencyToggle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
           // ui alert and create new note.
            newNote()
            sender.isSelected = false
        } else if sender.selectedSegmentIndex == 1 {
            attendance()
            sender.isSelected = false 
        }
    }
    
    

}

