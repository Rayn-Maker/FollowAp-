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

class SoulDataVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        scrolView.contentSize.height = 350
        setUPSoulData()
        firsView()
        
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
    @IBOutlet weak var doneNotesBtn: UIButton!
    @IBOutlet weak var saveNewNotesBtn: UIButton!
    @IBOutlet weak var newNotesBtn: UIButton!
    @IBOutlet weak var soulNotes: UITextView!
    @IBOutlet weak var soulNotesTextInput: UITextView!
    
    @IBOutlet weak var doneWithNotesBtn: UIButton!
    @IBOutlet weak var phoneNumberIcon: UITextView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
//    @IBOutlet weak var addressBarBtn: UITextView!
    
    /////////////////////// finish objects to hide \\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    
    ////////////////////// Variables to recieve keys \\\\\\\\\\\\\\\\\\\\\\
     var noteKeys = [String]()
    var eventID: String! // event id
    var orgID: String! // org's id
    var soulData = SoulData()
    
    /////////////////////// finish keys \\\\\\\\\\\\\\\\\\\\\\\\\\
    
    func firsView() {
        
        tableView.isHidden = false
        newNotesBtn.isHidden = false
        saveNewNotesBtn.isHidden = true
        soulNotes.isHidden = true
        soulNotesTextInput.isHidden = true
        doneNotesBtn.isHidden = true
        cancelBtn.isHidden = true
        doneWithNotesBtn.isHidden = true
        view.endEditing(true)
    }/// Function To Show First View
    
    func showNotes() {
        tableView.isHidden = true
        soulNotes.isHidden = false
        doneNotesBtn.isHidden = false
        doneWithNotesBtn.isHidden = false
    } // Function TO Show Notes view
    
    func newNotes() {
        firsView()
        tableView.isHidden = true
        saveNewNotesBtn.isHidden = false
        newNotesBtn.isHidden = true
        soulNotesTextInput.text = ""
        soulNotesTextInput.isHidden = false
        cancelBtn.isHidden = false
    } // FUnction to show notes
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count ?? 0
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var notesArray = [SoulNotes]()
    var soulsID = String()
    
    
    
//    @IBOutlet weak var scrolView: UIScrollView!
    
    

    
    func setUPSoulData(){

       firstNameLabel.text = soulData.firstName
       lastNameLabel.text = soulData.lastName
       emailLabel.text = soulData.email
      invitedByLabel.text =  soulData.invitee
      eventMetLabel.text = soulData.eventContacted
      addressLabel.text =  soulData.address
      schoolLabel.text =  soulData.school
       genderLabel.text = soulData.sex
       raceLabel.text = soulData.race
        phoneNumberIcon.text = soulData.phoneNumber
       selectablePhoneNumb.text = soulData.phoneNumber
        addressLabel.text = "\(soulData.ir ?? 0)"
        
    }
    
    
    func numberOfSections(in prayerTable: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showNotes()
        soulNotes.text = self.notesArray[indexPath.row].notes
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
    
    @IBAction func newNotesPressed(_ sender: Any) {
        newNotes()
    }
    


    
    
    var SoulProfInfo = SoulData()
    
    
    var ref: FIRDatabaseReference!
    
    @IBAction func savePressed(_ sender: Any) {
        
        
        if self.soulNotesTextInput.text != "" {
            
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        let alert = UIAlertController(title: "Response", message: "Did They Respond", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default, handler: { (_) in
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
           
        })
        let no = UIAlertAction(title: "No", style: .destructive, handler: { (_) in
            // go in and update ir
           
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
        })
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
        
        var userName: String!
        
        view.endEditing(true)
        userName = FIRAuth.auth()!.currentUser!.displayName!
        
        let notesKey = ref.child("souls").child(soulsID).child("FollowUP_Notes").childByAutoId().key
        
        
            retrieveNotes()
            view.endEditing(true)
            firsView()
            let dateString = String(describing: Date())
            
           
            
            
            let note = ["notesKey" : notesKey,
                        "Notes" : soulNotesTextInput.text,
                        "Author" : userName,
                        "time" : dateString] as [String : Any]
            
            let prayers = ["\(notesKey)" : note]
            
            ref.child("souls").child(soulsID).child("Follow_Up_Notes").updateChildValues(prayers)
            
        }
            
        else {
            let alert = UIAlertController(title: "Missing Information", message: "Please Write Some Notes", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        firsView()
        retrieveNotes()
        view.endEditing(true)
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
    
    @IBAction func doneWithNotes(_ sender: Any) {
       

        firsView()
    }
    
    @IBAction func doneWithNotesBtnPressed(_ sender: Any) {
       
        firsView()
    }
    
    @IBAction func refresh(_ sender: Any) {
        viewDidLoad()
    }
    
    

}

