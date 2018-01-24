//
//  MySoulsData.swift
//  PokeSearch
//
//  Created by Radiance Okuzor on 7/16/17.
//  Copyright © 2017 Radiance Okuzor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import MessageUI

class MySoulsData: UIViewController, UITableViewDelegate, UITableViewDataSource,  MFMessageComposeViewControllerDelegate  {
    
    
    ///////////////////////////// Soul Data Variables \\\\\\\\\\\\\\\\\\\\\\\\\\
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var phoneNumber: UITextView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var invitedByLabel: UILabel!
    @IBOutlet weak var eventMetLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var raceLabel: UILabel!
    /////////////////////////////// finish soul data variables \\\\\\\\\\\\\\\\\
    
    /////////////////////////// Objects To Hide \\\\\\\\\\\\\\\\\\\\\\\


    /////////////////////// finish objects to hide \\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    
    ////////////////////// Variables to recieve keys \\\\\\\\\\\\\\\\\\\\\\
    var noteKeys = [String]()
    var eventID: String! // event id
    var orgID: String! // org's id
    var mySoulData = [String]()
    var phonNumbers = String()
    
    /////////////////////// finish keys \\\\\\\\\\\\\\\\\\\\\\\\\\
    
    func connectLbls(){
    
            
            firstNameLabel.text = "Gender: " + mySoulData[8]
            lastNameLabel.text = "Last Name: " + mySoulData[1]
            phoneNumber.text =  mySoulData[2]
//            self.phonNumbers = mySoulData[2]
            emailLabel.text = "Email: " + mySoulData[3]
            invitedByLabel.text =  "Invitee: " + mySoulData[4]
            eventMetLabel.text = "Event Met: " + mySoulData[5]
            addressLabel.text =  "Adrress:" + mySoulData[6]
            schoolLabel.text =  "School/Job: " + mySoulData[6]
            genderLabel.text = "First Name: " + mySoulData[0]
            raceLabel.text = "Race: " + mySoulData[9]
 
    }
    
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count ?? 0
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var notesArray = [SoulNotes]()
    var soulsID = String()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        connectLbls()
        retrieveNotes()
    }
    
    
    func numberOfSections(in prayerTable: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "myFollowUpNotes", for: indexPath) as! SoulDataCell
        
        
        cell.mySoulNotes?.text = self.notesArray[indexPath.row].notes
        cell.mynoteTimeStamp.text = self.notesArray[indexPath.row].dateS
        
        return cell
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
        soulsID = self.mySoulData[10]
        let ref = FIRDatabase.database().reference()
        ref.child("souls").child(soulsID).child("Follow_Up_Notes").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.value is NSNull {
                print("soul notes is data is null foreal:\(self.soulsID)")
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
                    if let notes = value["Notes"] as? String, let notesKey = value["notesKey"] as? String,  let timeStamp = value["time"] as? String,  let author = value["Author"] as? String, let dateString = value["time"] as? String, let date = dateFormatter.date(from: dateString)   {
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
    

    
    @IBAction func refresh(_ sender: Any) {
        viewDidLoad()
    }

    @IBAction func backPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func call(_ sender: Any?){
        self.phonNumbers = mySoulData[2]
        self.phonNumbers = self.phonNumbers.replacingOccurrences(of: "-", with: "")
        self.phonNumbers = self.phonNumbers.replacingOccurrences(of: " ", with: "")
        self.phonNumbers = self.phonNumbers.replacingOccurrences(of: ")", with: "")
        self.phonNumbers = self.phonNumbers.replacingOccurrences(of: "(", with: "")
        self.phonNumbers = self.phonNumbers.replacingOccurrences(of: "+", with: "")
        
        if phonNumbers.count > 10 {
            self.phonNumbers.remove(at: phonNumbers.startIndex)
        }
        if phonNumbers.count > 10 {
            self.phonNumbers.remove(at: phonNumbers.startIndex)
        }
        
        if phonNumbers.count > 10 {
            String(self.phonNumbers.characters.dropLast())
        }
        let dd =  (self.phonNumbers as NSString).integerValue
        
        guard let number = URL(string: "tel://" + "\(dd ?? 8888888888)") else {
            
            let ref = FIRDatabase.database().reference()
            let dateString = String(describing: Date())
            let undrChurches = ["recent" : dateString]
            ref.child("souls").child(self.soulsID).updateChildValues(undrChurches)
            return }
        UIApplication.shared.open(number)
        
        let ref = FIRDatabase.database().reference()
        let dateString = String(describing: Date())
        let undrChurches = ["recent" : dateString]
        ref.child("souls").child(self.soulsID).updateChildValues(undrChurches)
        
    }
    
    @IBAction func sendMessage(_ sender: Any?) {
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = [mySoulData[2]]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        let ref = FIRDatabase.database().reference()
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
            sender.selectedSegmentIndex = 1
        } else if sender.selectedSegmentIndex == 1 {
           
            
        }
    }
    
}


