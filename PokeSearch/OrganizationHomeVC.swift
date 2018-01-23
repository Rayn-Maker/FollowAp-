//
//  OrganizationHomeVC.swift
//  PokeSearch
//
//  Created by Radiance Okuzor on 12/11/17.
//  Copyright © 2017 Radiance Okuzor. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth
import MessageUI

class OrganizationHomeVC: UIViewController, MFMailComposeViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        setupVCData()
        orgCreatorLbl.text = orgVCData.OrgCreatorName
        pageTitle.text = orgVCData.OrgTitle
        searchBar.returnKeyType = UIReturnKeyType.search
        retrieveEvents()
        retrieveMyLeaders()
        retrieveAllLeaders()
        //retrievePendingLeaders()
        fetchAlLSouls()
        retrieveSouls()
        formatEmailMessage()
    }
  
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var orgCreatorLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var currentLeadersTableView: UITableView!
    @IBOutlet weak var leaderRequestTableView: UITableView!
    @IBOutlet weak var leaderSearchTableView: UITableView!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var delTableView: UITableView!
    @IBOutlet weak var soulListTableView: UITableView!
    @IBOutlet weak var eventsdropdown: UIPickerView!
    
    @IBOutlet weak var toggleBtn: UISearchBar!
    var eventArray = [EventData]()
    var AllLeaders = [LeadersData]()
    var pendingLeadersArray = [LeadersData]()
    var AllLeadersFiltered = [LeadersData]()
    var myLeaders = [LeadersData]()
    var iamUser = [String]()
    var allSoulAr = [SoulData]()
    var inSearching = false
    var orgVCData = OrgData()
    var soulArray = [SoulData]()
    var soulArrayInOrder = [SoulData]()
    var mySoulsKey = [String]()
    let ref = FIRDatabase.database().reference()
    var emailString = String()
    var emailFile = String()
    var eventsIdToAdd: String!
    
    func setupVCData(){
       orgVCData.OrgId = iamUser[0]
        orgVCData.OrgTitle = iamUser[1]
        orgVCData.OrgCreatorName = iamUser[2]
        orgVCData.OrgCreatorId = iamUser[3]
    }
    
    func retrieveEvents() {
        
        let ref = FIRDatabase.database().reference()
        ref.child("Organizations").child(self.orgVCData.OrgId!).child("Events").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            
            if snapshot.value is NSNull {
                print("***** Null Events Folder there's a \(self.orgVCData.OrgId!) path *******")
            }
            else {
                
                let users = snapshot.value as! [String : AnyObject]
                
                self.eventArray.removeAll()
                
                for (_, value) in users {
                  
                    var attendanceArray = [Attendance]()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                    let eventToPost = EventData()
                    if let author = value["creator"] as? String, let eventID = value["EventID"] as? String,  let eventTitle = value["EventName"] as? String, let creatorID = value["creatorID"] as? String, let dateString = value["date"] as? String, let date = dateFormatter.date(from: dateString) {
                        eventToPost.eventCreatorName = author
                        eventToPost.eventId = eventID
                        eventToPost.eventCreatorId = creatorID
                        eventToPost.eventName = eventTitle
                        eventToPost.date = date
//                        self.eventArray.insert(eventToPost, at: 0)
               
                    if let attendance = value["Attendance"] as? [String : AnyObject] {
                        let dateFormatters = DateFormatter()
                        dateFormatters.dateFormat = "yyyy-MM-dd"
                        var attendanceTotake = Attendance()
                        
                        for (_,c) in attendance {
                            
                            if let b = c as? [String : AnyObject] {
                                for (_,f) in b {
                                    let came = f["came"] as? String ; let name = f["name"] as? String ; let dateStrings = f["date"] as? String; let date = dateFormatters.date(from: dateStrings!) ; let id = f["soulId"] as? String
                                    
                                    attendanceTotake.came = came
                                    attendanceTotake.date = date
                                    attendanceTotake.dateS = dateStrings
                                    attendanceTotake.name = name
                                    attendanceArray.append(attendanceTotake)
                                }
                               
                            }
                           
                          
                        }
                        //
                    }
                    attendanceArray.sort(by: { $0.date.compare($1.date) == .orderedDescending })
                    eventToPost.attendanceArray = attendanceArray
                    self.eventArray.append(eventToPost)
                 }
                }
            }
            self.eventArray.sort(by: { $0.date.compare($1.date) == .orderedDescending })
            self.eventsTableView.reloadData()
            self.eventsdropdown.reloadAllComponents()
            
        })
        ref.removeAllObservers()
        
    }

    
    func fetchAlLSouls() {
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
                        
                        
                        
                        self.allSoulAr.append(soulToShow)
                    }
                }
            }
        })
        ref.removeAllObservers()
        self.delTableView.reloadData()
        
    }
    
    func creatNewGroup(){
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let eventKey = ref.child("Organizations").child(self.orgVCData.OrgId!).childByAutoId().key
        
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
                
                let parameters = ["EventID"    : eventKey,
                                  "EventName"  : text,
                                  "creatorID"         : uid,
                                  "creator"           : FIRAuth.auth()!.currentUser!.displayName!,
                                  "date"              : dateString]
                let event = ["\(eventKey)" : parameters]
                ref.child("Organizations").child(self.orgVCData.OrgId!).child("Events").updateChildValues(event)
                self.retrieveEvents()
            }
        }
        alert.addAction(cancel)
        alert.addAction(post)
        present(alert, animated: true, completion: nil)
     }
      
    func retrieveMyLeaders() {
        let ref = FIRDatabase.database().reference()
        ref.child("Organizations").child(self.orgVCData.OrgId!).child("Members").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.value is NSNull {
                print("My Members folder is null")
            }
            else {
                let membersId = snapshot.value as! [String : AnyObject]
                self.myLeaders.removeAll()
                for (_, values) in membersId {
                    
                    ref.child("leaders").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                        
                        if snapshot.value is NSNull {
                            print("My Members folder is null")
                        }
                        else {
                            let leaders = snapshot.value as! [String : AnyObject]
                            // self.myUser.removeAll()
                            for (_, value) in leaders {
                                
                                if values as? String == value["uid"] as? String {
                                    if let uid = value["uid"] as? String {
                                        if uid != FIRAuth.auth()!.currentUser!.uid {
                                            var userToShow = LeadersData()
                                            if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String, let email = value["email"] as? String, let cityState = value["cityState"] as? String {
                                                userToShow.fullName = fullName
                                                userToShow.imagePath = imagePath
                                                userToShow.userID = uid
                                                userToShow.cityState = cityState
                                                userToShow.email = email
                                                self.myLeaders.append(userToShow)
                                            }
                                        }  //
                                    }
                                }
                            }
                            self.myLeaders.sort(by: { $0.fullName < $1.fullName })
                            self.currentLeadersTableView.reloadData()
                        }
                    })
                    ref.removeAllObservers()
                    
                }
                self.currentLeadersTableView.reloadData()
                
            }
            
        })
        
        ref.removeAllObservers()
    }
    
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
                        if uid != FIRAuth.auth()!.currentUser!.uid {
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
                }
                self.AllLeaders.sort(by: { $0.fullName < $1.fullName })
                self.checkFollowing2()
                self.leaderSearchTableView.reloadData()
            }
        })
        ref.removeAllObservers()
        
    }
    
    /// Currently out of order but function is in great standing.
    func retrievePendingLeaders(){
       
        let ref = FIRDatabase.database().reference()
        ref.child("Organizations").child(self.orgVCData.OrgId!).child("Members Request").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.value is NSNull {
                print("My Members folder is null")
            }
            else {
                let membersId = snapshot.value as! [String : AnyObject]
                self.pendingLeadersArray.removeAll()
                for (_, values) in membersId {
                    
                    ref.child("leaders").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                        
                        if snapshot.value is NSNull {
                            print("My Members folder is null")
                        }
                        else {
                            let leaders = snapshot.value as! [String : AnyObject]
                            // self.myUser.removeAll()
                            for (_, value) in leaders {
                                
                                if values as? String == value["uid"] as? String {
                                    if let uid = value["uid"] as? String {
                                        if uid != FIRAuth.auth()!.currentUser!.uid {
                                            var userToShow = LeadersData()
                                            if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String, let email = value["email"] as? String, let cityState = value["cityState"] as? String {
                                                userToShow.fullName = fullName
                                                userToShow.imagePath = imagePath
                                                userToShow.userID = uid
                                                userToShow.cityState = cityState
                                                userToShow.email = email
                                                self.pendingLeadersArray.append(userToShow)
                                            }
                                        }  //
                                    }
                                }
                            }
                            self.pendingLeadersArray.sort(by: { $0.fullName < $1.fullName })
                            self.leaderRequestTableView.reloadData()
                        }
                    })
                    ref.removeAllObservers()
                    
                }
                self.leaderRequestTableView.reloadData()
                
            }
            
        })
        ref.removeAllObservers()
        
    }
    
    func retrieveSouls() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        ref.child("Organizations").child(self.orgVCData.OrgId!).child("All_Invites").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
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
                                var reorder = SoulData()
                                if each == a {
                                    if let invitee = b["invitee"] as? String, let soulID = b["soulID"] as? String,  let firstName = b["firstName"] as? String,  let lastName = b["lastName"] as? String,  let phoneNumber = b["phoneNumber"] as? String,  let email = b["email"] as? String,  let school = b["school"] as? String,  let address = b["address"] as? String,  let eventContacted = b["eventContacted"] as? String,  let race = b["race"] as? String,  let sex = b["sex"] as? String ,  let orgId = b["orgId"] as? String,  let eventId = b["eventId"] as? String,  let ir = b["IR"] as? Double {
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
                                        soulToShow.ir = ir
                                        
                                    }
                                    let dateFormatterss = DateFormatter()
                                    dateFormatterss.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                                    if let recentString = b["recent"] as? String, let datess = dateFormatterss.date(from: recentString)  {
                                        
                                        
                                        soulToShow.recent = datess
                                    } else {
                                       
                                        let dateFormattersss = DateFormatter()
                                        let dateFormatPringsss = DateFormatter()
                                        dateFormattersss.dateFormat = "yyyy-MM-dd "
                                        dateFormatPringsss.dateFormat = "MMM dd,yyyy hh:mm"
                                        let dateStringsss = "12-1-1"
                                        let datesss = dateFormattersss.date(from: dateStringsss)
                                        
                                        
                                        soulToShow.recent = datesss
                                    }
                                    
                                    var notesToShow = SoulNotes()
                                    if let fnotes = b["Follow_Up_Notes"] as? [String:AnyObject] {
                                        for (c,d) in fnotes {
                                            let dateFormatter = DateFormatter()
                                            let dateFormatPring = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                                            dateFormatPring.dateFormat = "MMM dd,yyyy hh:mm a"
                                            if let notes = d["Notes"] as? String, let notesKey = d["notesKey"] as? String,  let author = d["Author"] as? String, let dateString = d["time"] as? String, let date = dateFormatter.date(from: dateString)   {
                                                dateFormatPring.string(from: date)
                                                notesToShow.notes = notes
                                                notesToShow.author = author
                                                notesToShow.date = date
                                                notesToShow.dateS = dateFormatPring.string(from: date)
                                                notesToShow.notesKey = notesKey
                                                soulToShow.followUpNotes.append(notesToShow)
                                            }
                                            ////////////////////////////////////////////////////////////////
                                        }
                                    }
                                    
                                    soulToShow.followUpNotes.sort(by: { $0.date < $1.date })
                                    
                                    if soulToShow.followUpNotes.count > 0 {
                                        reorder.soulReorder = soulToShow.followUpNotes[0].date
                                    }
                                        if reorder.soulReorder == nil {
                                            let dateFormatter = DateFormatter()
                                            let dateFormatPring = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                                            dateFormatPring.dateFormat = "MMM dd,yyyy"
                                            let dateString = "12-1-1"
                                            let dates = dateFormatter.date(from: dateString)
                                            reorder.soulReorder = dates
                                        }
                                        soulToShow.soulReorder = reorder.soulReorder
                                    
                                    
                                     self.soulArray.append(soulToShow)
                                    
                                    if self.soulArray[self.soulArray.count-1].soulReorder == nil {
                                        let dateFormatter = DateFormatter()
                                        let dateFormatPring = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd "
                                        dateFormatPring.dateFormat = "MMM dd,yyyy"
                                        let dateString = "12-1-1"
                                        let dates = dateFormatter.date(from: dateString)
                                        
                                        self.soulArray[self.soulArray.count-1].soulReorder  = dates
                                    }
                                    
                                   
                                }
                            }
                        }
                        
                        self.soulArrayInOrder = self.soulArray
                        self.soulArrayInOrder.sort(by: { $0.firstName < $1.firstName })
                        self.soulArray.sort(by: { $0.recent.compare($1.recent) == .orderedDescending })
                        self.formatEmailMessage()
                        self.soulListTableView.reloadData()
                        self.leaderRequestTableView.reloadData()
                    }
                    
                })
                ref.removeAllObservers()
            }
        })
        ref.removeAllObservers()
        
//        self.soulArray.sort(by: { $0.firstName < $1.firstName })
        self.soulListTableView.reloadData()
    }
    
    
    @IBAction func urgencyToggle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
           eventsTableView.isHidden = false
           currentLeadersTableView.isHidden = true
            leaderRequestTableView.isHidden = true
             soulListTableView.isHidden = true 
            leaderSearchTableView.isHidden = true
        } else if sender.selectedSegmentIndex == 1 {
            // add new event
            creatNewGroup()
            sender.selectedSegmentIndex = 0
            eventsTableView.isHidden = false
            currentLeadersTableView.isHidden = true
            leaderRequestTableView.isHidden = true
            leaderSearchTableView.isHidden = true
             soulListTableView.isHidden = true
        } else if sender.selectedSegmentIndex == 2 {
            eventsTableView.isHidden = true
            currentLeadersTableView.isHidden = false
            leaderRequestTableView.isHidden = true
             soulListTableView.isHidden = true
            leaderSearchTableView.isHidden = true
        } else if sender.selectedSegmentIndex == 3 {
            
            eventsdropdown.isHidden = false
            eventsTableView.isHidden = true
            currentLeadersTableView.isHidden = true
            soulListTableView.isHidden = true
            leaderRequestTableView.isHidden = false
            leaderSearchTableView.isHidden = true
            
            /*
             if orgVCData.OrgCreatorId == FIRAuth.auth()?.currentUser?.uid{
            eventsTableView.isHidden = true
            currentLeadersTableView.isHidden = true
            soulListTableView.isHidden = true
            leaderRequestTableView.isHidden = false
            leaderSearchTableView.isHidden = true
             } else {
                let alert = UIAlertController(title: "Sorry ", message: "🕺Cant Touch This🕺", preferredStyle: .alert)
                
                let cancel = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
            } */
        } else if sender.selectedSegmentIndex == 4 {
            if orgVCData.OrgCreatorId == FIRAuth.auth()?.currentUser?.uid{
                eventsTableView.isHidden = true
                currentLeadersTableView.isHidden = true
                soulListTableView.isHidden = true
                leaderRequestTableView.isHidden = true
                leaderSearchTableView.isHidden = false
                searchBar.isHidden = false
                sender.selectedSegmentIndex = 0
            } else {
                let alert = UIAlertController(title: "Sorry ", message: "🕺Cant Touch This🕺", preferredStyle: .alert)
                
                let cancel = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
            }
            
        } else if sender.selectedSegmentIndex == 5 {
            soulListTableView.isHidden = false
            eventsTableView.isHidden = true
            currentLeadersTableView.isHidden = true
            leaderRequestTableView.isHidden = true
            leaderSearchTableView.isHidden = true
        }
    }
    

    
    @IBAction func refresh(_ sender: Any) {
        viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OrgListToEventTitle" {
            let vc = segue.destination as! EventHomeVC
            let indexPath = eventsTableView.indexPathForSelectedRow
            
           vc.eventInfo.eventCreatorId = eventArray[(indexPath?.row)!].eventCreatorId
            vc.eventInfo.eventCreatorName = eventArray[(indexPath?.row)!].eventCreatorName
            vc.eventInfo.eventId = eventArray[(indexPath?.row)!].eventId
            vc.eventInfo.eventName = eventArray[(indexPath?.row)!].eventName
            if eventArray[((indexPath?.row))!].attendanceArray.count > 0 {
                vc.eventInfo.attendanceArray = eventArray[((indexPath?.row))!].attendanceArray
            }
            vc.eventInfo.eventGroupId = orgVCData.OrgId
            vc.eventInfo.eventGroup = orgVCData.OrgTitle
            vc.eventArray = self.eventArray
        }
    }


}


extension OrganizationHomeVC: UITableViewDataSource , UITableViewDelegate,  UISearchBarDelegate  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == eventsTableView){
            return eventArray.count ?? 0
        }else if (tableView == leaderSearchTableView){
            if (inSearching){
                return AllLeadersFiltered.count ?? 0
            } else {
                return 0
            }
        } else if (tableView == leaderRequestTableView){
            return soulArrayInOrder.count
        } else if tableView == delTableView {
            return allSoulAr.count
        } else if tableView == soulListTableView {
            return soulArray.count 
        }
        else {
            return myLeaders.count
        }
        
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == eventsTableView){
            var cell =  tableView.dequeueReusableCell(withIdentifier: "eventsCell", for: indexPath) as! EventCell
            
           cell.eventName.text = self.eventArray[indexPath.row].eventName
            cell.eventCreator.text = self.eventArray[indexPath.row].eventCreatorName
         
            return cell
        }else if (tableView == leaderSearchTableView){
            var cell1 =  tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as! LeaderCell
            
            if (inSearching){
                cell1.leadersNameSB.text = self.AllLeadersFiltered[indexPath.row].fullName + "\n~" + self.AllLeadersFiltered[indexPath.row].email
                cell1.leadersEmailSB.text = self.AllLeadersFiltered[indexPath.row].foll
                checkMembership(indexPath: indexPath)
            } else {
//                cell1.leadersNameSB.text = self.AllLeaders[indexPath.row].fullName
//                cell1.leadersEmailSB.text = self.AllLeaders[indexPath.row].email
//                checkMembership(indexPath: indexPath)
            }
            
            return cell1
        } else if tableView == currentLeadersTableView { 
            var cell =  tableView.dequeueReusableCell(withIdentifier: "currentLeadersCell", for: indexPath) as! LeaderCell
            
            cell.myLeadersName.text = self.myLeaders[indexPath.row].fullName
            cell.myLeadersEmail.text = self.myLeaders[indexPath.row].email
            //checkMembership(indexPath: indexPath)
            return cell
        } else if tableView == delTableView {
            var cell =  tableView.dequeueReusableCell(withIdentifier: "delCell", for: indexPath)
            cell.textLabel?.text = self.allSoulAr[indexPath.row].firstName
            return cell
        } else if tableView == soulListTableView {
            var cell =  tableView.dequeueReusableCell(withIdentifier: "organizationSoulCell", for: indexPath)
            cell.textLabel?.text = soulArray[indexPath.row].firstName + " " + soulArray[indexPath.row].lastName
            return cell
        } else {
            var cell =  tableView.dequeueReusableCell(withIdentifier: "pendingLeaders", for: indexPath) as! LeaderCell
            cell.pendingLeaderName.text = self.soulArrayInOrder[indexPath.row].firstName + " " +  self.soulArrayInOrder[indexPath.row].lastName
            cell.pendingLeaderEmail.text = self.soulArrayInOrder[indexPath.row].invitee
            return cell 
        }
    }

    

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == nil || searchBar.text == "" {
            
            inSearching = false
            leaderSearchTableView.reloadData()
            
        } else {
            
            inSearching = true
            var lower = searchBar.text!
            lower =  lower.lowercased()
            AllLeadersFiltered.removeAll()
            for x in 0...AllLeaders.count - 1 {
                if lower == AllLeaders[x].email.lowercased() {
                    AllLeadersFiltered = [AllLeaders[x]]//organization.filter({$0.OrgId?.range(of: lower) != nil})
                    
                    leaderSearchTableView.reloadData()
                }
            }

            
        }
    }
    
    
    
    func checkMembership(indexPath: IndexPath) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("Organizations").child(self.orgVCData.OrgId!).child("Members").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if (self.inSearching) {
                if let following = snapshot.value as? [String : AnyObject] {
                    for (_, value) in following {
                        if value as! String == self.AllLeadersFiltered[indexPath.row].userID {
                           // self.leaderSearchTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                        }
                    }
                }
            } else {
                if let following = snapshot.value as? [String : AnyObject] {
                    for (_, value) in following {
                        if value as! String == self.AllLeadersFiltered[indexPath.row].userID {
                           // self.leaderSearchTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                        }
                    }
                }
            }
        })
        ref.removeAllObservers()
        
    }
    
    func checkFollowing2() {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        
        ref.child("Organizations").child(self.orgVCData.OrgId!).child("Members").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject] {
                
                for x in 0...self.AllLeaders.count - 1 {
                    for (_, value) in following {
                        if self.AllLeaders[x].userID == value as! String {
                            self.AllLeaders[x].foll = "Organization Member\nClick To Remove"
                            break
                        }
                    }
                }
                
                for x in  0...self.AllLeaders.count - 1{
                    if self.AllLeaders[x].foll == nil {
                        self.AllLeaders[x].foll = "Free Agent\nClick To Add"
                    }
                }
                
            }
        })
        ref.removeAllObservers()
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (tableView == eventsTableView){
            performSegue(withIdentifier: "OrgListToEventTitle", sender: self)
        }else if (tableView == leaderSearchTableView) {
            if (inSearching){
                // show pop here
                let uid = FIRAuth.auth()!.currentUser!.uid
                let ref = FIRDatabase.database().reference()
                let key = ref.child("leaders").childByAutoId().key
                
                var isFollower = false
                
                ref.child("Organizations").child(self.orgVCData.OrgId!).child("Members").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                    
                    if snapshot.value is NSNull {
                        print("My Members folder is null")
                    }
                    else {
                        if let orgMembrs = snapshot.value as? [String : AnyObject] {
                            for (ke, value) in orgMembrs {
                              if value as! String == self.AllLeadersFiltered[indexPath.row].userID {
                                let alert = UIAlertController(title: "Remove Leader", message: "Are you sure you want to remove leader from group? Leader will no longer have access to this groups data", preferredStyle: .alert)
                                let yes = UIAlertAction(title: "❌Yes Remove❌", style: .destructive, handler: { (_) in
                                    isFollower = true
                                    
                                    ref.child("Organizations").child(self.orgVCData.OrgId!).child("Members/\(ke)").removeValue()
                                    ref.child("leaders").child(self.AllLeadersFiltered[indexPath.row].userID).child("My Organizations/\(ke)").removeValue()
                                    
                                    self.leaderSearchTableView.cellForRow(at: indexPath)?.accessoryType = .none
                                    self.retrieveMyLeaders()
                                    })
                                let no = UIAlertAction(title: "just kidding! let 'em stay", style: .default, handler: nil)
                                alert.addAction(yes)
                                alert.addAction(no)
                                self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    if !isFollower {
                        let alert = UIAlertController(title: "Add Leader", message: "Do you trust this person 🤷🏽‍♂️", preferredStyle: .alert)
                        let yes = UIAlertAction(title: "Yes add to my Organization🕺", style: .default, handler: { (_) in
                          let following = ["Members/\(key)" : self.AllLeadersFiltered[indexPath.row].userID]
                          let followers = ["My Organizations/\(key)" : self.orgVCData.OrgId!]
                        
                          ref.child("leaders").child(self.AllLeadersFiltered[indexPath.row].userID).updateChildValues(followers)
                          ref.child("Organizations").child(self.orgVCData.OrgId!).updateChildValues(following)
                        
                          self.leaderSearchTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                          self.retrieveMyLeaders()
                        })
                        let no = UIAlertAction(title: "❌Nope! dont add this person❌", style: .destructive, handler: nil)
                        alert.addAction(yes)
                        alert.addAction(no)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
                ref.removeAllObservers()
                // end pop up
            } else {
                let uid = FIRAuth.auth()!.currentUser!.uid
                let ref = FIRDatabase.database().reference()
                let key = ref.child("leaders").childByAutoId().key
                
                var isFollower = false
                
                ref.child("Organizations").child(self.orgVCData.OrgId!).child("Members").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                    
                    if snapshot.value is NSNull {
                        print("My Members folder is null")
                    }
                    else {
                        if let orgMembrs = snapshot.value as? [String : AnyObject] {
                            for (ke, value) in orgMembrs {
                                if value as! String == self.AllLeadersFiltered[indexPath.row].userID {
                                    isFollower = true
                                    
                                    ref.child("Organizations").child(self.orgVCData.OrgId!).child("Members/\(ke)").removeValue()
                                    ref.child("leaders").child(self.AllLeadersFiltered[indexPath.row].userID).child("My Organizations/\(ke)").removeValue()
                                    
                                    self.leaderSearchTableView.cellForRow(at: indexPath)?.accessoryType = .none
                                    self.retrieveMyLeaders()
                                }
                            }
                        }
                    }
                    if !isFollower {
                        let following = ["Members/\(key)" : self.AllLeadersFiltered[indexPath.row].userID]
                        let followers = ["My Organizations/\(key)" : self.orgVCData.OrgId!]
                        
                        ref.child("leaders").child(self.AllLeadersFiltered[indexPath.row].userID).updateChildValues(followers)
                        ref.child("Organizations").child(self.orgVCData.OrgId!).updateChildValues(following)
                        
                        self.leaderSearchTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                        self.retrieveMyLeaders()
                    }
                })
                ref.removeAllObservers()
                
            }
        } else if tableView == leaderRequestTableView {
            
            // add to the selected group
            let ref = FIRDatabase.database().reference()
            
            let prayers = [ "\(self.soulArrayInOrder[indexPath.row].soulID ?? "")" :"\(self.soulArrayInOrder[indexPath.row].soulID ?? "")"] // var inviteeID: String!
            
            
            ref.child("Organizations").child(self.orgVCData.OrgId!).child("Events").child(self.eventsIdToAdd!).child("invites").updateChildValues(prayers)
            //            let indexPath = tableView.indexPathForSelectedRow
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.green
            // cell.selectedBackgroundView = backgroundView
            self.leaderRequestTableView.cellForRow(at: indexPath)?.selectedBackgroundView = backgroundView
            
            
            /*
            let uid = FIRAuth.auth()!.currentUser!.uid
            let ref = FIRDatabase.database().reference()
            let key = ref.child("leaders").childByAutoId().key
            
            var isFollower = false
            
            ref.child("Organizations").child(self.orgVCData.OrgId!).child("Members Request").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                
                if snapshot.value is NSNull {
                    print("My Members folder is null")
                }
                else {
                    if let orgMembrs = snapshot.value as? [String : AnyObject] {
                        for (ke, value) in orgMembrs {
                            if value as! String == self.pendingLeadersArray[indexPath.row].userID {
                                isFollower = true
                                let following = ["Members/\(key)" : self.pendingLeadersArray[indexPath.row].userID]
                                let followers = ["My Organizations/\(key)" : self.orgVCData.OrgId]
                                
                                ref.child("leaders").child(self.pendingLeadersArray[indexPath.row].userID).updateChildValues(followers)
                                ref.child("Organizations").child(self.orgVCData.OrgId!).updateChildValues(following)
                                
                                self.leaderSearchTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark

                                
                                ref.child("Organizations").child(self.orgVCData.OrgId!).child("Members Request/\(ke)").removeValue()
                                ref.child("leaders").child(self.pendingLeadersArray[indexPath.row].userID).child("My Organizations Requests/\(ke)").removeValue()
                                
                                self.leaderSearchTableView.cellForRow(at: indexPath)?.accessoryType = .none
                                self.retrieveMyLeaders()
                                self.pendingLeadersArray.removeAll()
                                self.leaderRequestTableView.reloadData()
                                self.retrieveAllLeaders()
                                self.retrievePendingLeaders()

                            }
                        }
                    }
                }

            })
            ref.removeAllObservers()
          */
        } else {
            //
        }
        if tableView == delTableView {
            
            let key =  self.ref.child("Organizations").child(orgVCData.OrgTitle).child("Events").child("tamu id here ").child("invites").childByAutoId().key
            
            let prayers = [ key :"\(self.allSoulAr[indexPath.row].soulID ?? "")"] // var inviteeID: String!
            
            
            self.ref.child("Organizations").child(orgVCData.OrgId!).child("Events").child("-L0faQ1Xfa6etv5_H6Hr").child("invites").updateChildValues(prayers)
            self.ref.child("Organizations").child(orgVCData.OrgId!).child("All_Invites").updateChildValues(prayers)
            
        }
        
        if tableView == soulListTableView {
            // show soul info
            
            var strng = String()
            strng = soulArray[indexPath.row].firstName
            strng += soulArray[indexPath.row].lastName
            strng += "\nPhone Number: "
            strng += soulArray[indexPath.row].phoneNumber
            strng += " \nEmail: "
            strng += soulArray[indexPath.row].email
            strng += " \nInvited By: "
            strng += soulArray[indexPath.row].invitee
            strng += "\nRace: "
            strng += soulArray[indexPath.row].race
            strng += "\nSex: "
            strng += soulArray[indexPath.row].sex
            strng += " \nSchool/Job: "
            strng += soulArray[indexPath.row].school
            strng += " \nEvent Contacted: "
            strng += soulArray[indexPath.row].eventContacted
            strng += " \nInterest Rate: "
            strng += "\(soulArray[indexPath.row].ir ?? 0) "
            strng += " \n\n---Interest Rate Reading---\n"
            if (soulArray[indexPath.row].ir  < 0.20){
                strng += "0.00 - 0.20 = Member attendance in critical zone, change follow up leader and put in prayer point"
            } else if (soulArray[indexPath.row].ir  > 0.21) && (soulArray[indexPath.row].ir  < 0.40) {
                strng += "0.21 - 0.40 = Member attendance in warning zone. Increase follow up on member and closely watch leader"
            } else if (soulArray[indexPath.row].ir  > 0.41) && (soulArray[indexPath.row].ir  < 0.60) {
                strng += "0.41 - 0.60 = Member attendance in mild zone. Involve member in more church activities"
            }else if (soulArray[indexPath.row].ir  > 0.61) && (soulArray[indexPath.row].ir  < 0.80){
                strng +=  "0.61 - 0.80 = Member attendance is good do some personal follow up on member."
            } else {
                strng += "0.80 - 1.00 = Member attendance is great give to leader in training"
            }
            
            strng += "\n\n--- Folow Up Notes ---\n"
            var notes = String()
            
            var tim = String()
            
            if soulArray[indexPath.row].followUpNotes.count > 0 {
                for x in 0...soulArray[indexPath.row].followUpNotes.count - 1 {
                    tim = soulArray[indexPath.row].followUpNotes[0].dateS
                    notes += soulArray[indexPath.row].followUpNotes[x].notes
                    notes += "\n"
                }
            } else {
                tim = "None yet "
                notes = "None yet "
            }
            strng += "Last Followed up on: " + tim + "\n"
            strng += "📝Notes:\n"
            strng += notes
            
            
            let alert = UIAlertController(title: soulArray[indexPath.row].firstName, message: strng, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    func formatEmailMessage(){
        self.emailString = "----Souls For \(orgVCData.OrgTitle ?? "")----\n "
        if soulArrayInOrder.count > 0 {
        for x in 0...soulArrayInOrder.count - 1 {
            self.emailString += "\nSoul \(x+1) \n"
            self.emailString += "\t Full Name: "
            self.emailString += soulArrayInOrder[x].firstName + " " + soulArrayInOrder[x].lastName
            self.emailString += "\n\t Phone Number: "
            self.emailString += soulArrayInOrder[x].phoneNumber
            self.emailString += "\n\t Email: "
            self.emailString += soulArrayInOrder[x].email
            self.emailString += "\n\t Event Met: "
            self.emailString += soulArrayInOrder[x].eventContacted
            self.emailString += "\n\t Invitee: "
            self.emailString += soulArrayInOrder[x].invitee
            self.emailString += "\n\t Race: "
            self.emailString += soulArrayInOrder[x].race
            self.emailString += "\n\t Gender: "
            self.emailString += soulArrayInOrder[x].sex
            self.emailString += "\n\t Interest Rate: "
            self.emailString += "\(soulArrayInOrder[x].ir ?? 0.0)\n"
        }
        
        self.emailString += "=== You have \(soulArrayInOrder.count) Total amount of souls in this cell"
            self.saveFile()
        } else {
            //self.emailString += "Sorry this group has no souls yet"
        }
    }
    
    ///// Send Message of All Soul Data
    @IBAction func sendEmail(_ sender: Any) {
        let mail = configureMailViewCOntroller()
        if MFMailComposeViewController.canSendMail() {
            self.present(mail, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    func configureMailViewCOntroller() -> MFMailComposeViewController {
        let mailControllerVC = MFMailComposeViewController()
        mailControllerVC.mailComposeDelegate = self
        
        mailControllerVC.setToRecipients([])
        mailControllerVC.setSubject("\(orgVCData.OrgTitle ?? " ") Souls")
        mailControllerVC.setMessageBody("\(emailFile)", isHTML: false)
        return mailControllerVC
    }
    
    func showMailError(){
        let sendMailError = UIAlertController(title: "error", message: "Mail not sent", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "ok", style: .default, handler: nil)
        sendMailError.addAction(dismiss)
        self.present(sendMailError, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func saveFile(){
        // Save data to file
        let fileName = "Test2"
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        //        print("FilePath: \(fileURL.path)")
        
        let writeString = "\(emailString )"
        do {
            // Write to the file
            try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            //            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
        
        var readString = "" // Used to store the file contents
        do {
            // Read the file contents
            emailFile = try String(contentsOf: fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        print("File Text: \(emailFile)")
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return  1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return eventArray.count
        
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventsdropdown.isHidden = true
        
        if eventArray.count > 0 {
            self.pageTitle.text = eventArray[row].eventName
            self.orgCreatorLbl.text = "Copy to"
            eventsIdToAdd = eventArray[row].eventId
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        return eventArray[row].eventName
        
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
}

    

