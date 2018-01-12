//
//  JoingOrgVC2.swift
//  PokeSearch
//
//  Created by Radiance Okuzor on 12/11/17.
//  Copyright © 2017 Radiance Okuzor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class JoingOrgVC2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchBar.returnKeyType = UIReturnKeyType.search

        retrieveOrganizations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        retrieveOrganizations()
    }

    @IBOutlet weak var orgsListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var groupMember = false
    var organization = [OrgData]()
    var organizationFiltered = [OrgData]()
    var inSearching = false
    
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
                self.checkFollowing2()
                self.orgsListTableView.reloadData()
            }
            
        })
        ref.removeAllObservers()
        
    }
    
    func logout() {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try? FIRAuth.auth()?.signOut()
            } catch  {
            }
        }
    }
    

    @IBAction func bkPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapToHideKeyboard(_ sender: UITapGestureRecognizer) {
        self.searchBar.resignFirstResponder()
        self.view.endEditing(true)
    }

}

  



extension JoingOrgVC2: UITableViewDataSource, UITableViewDelegate,  UISearchBarDelegate  {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // let cell = tableView.dequeueReusableCell(withIdentifier: "joinOrgCell", for: indexPath) as! OrganizationCell
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("leaders").childByAutoId().key
         let keyy = ref.child("Organization").childByAutoId().key
        var isFollower = false
        checkGroup(indexPath: indexPath)
        checkFollowing(indexPath: indexPath)
        ref.child("leaders").child(uid).child("My Organizations Requests").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if !self.groupMember {
            if snapshot.value is NSNull {
                // here you dnt have any group membrs reqs so you ask to join
                let alert = UIAlertController(title: "Group Request", message: "Are you sure you want to request to joing this Organization?", preferredStyle: .alert)
                let yes = UIAlertAction(title: "Yes Request", style: .default, handler: { (_) in
                    let following = ["My Organizations Requests/\(keyy)" : self.organizationFiltered[indexPath.row].OrgId]
                    let followers = ["Members Request/\(keyy)" : uid]
                    
                    ref.child("leaders").child(uid).updateChildValues(following)
                    ref.child("Organizations").child(self.organizationFiltered[indexPath.row].OrgId!).updateChildValues(followers)
                    
                    self.orgsListTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                })
                let no = UIAlertAction(title: "No! Dont Request", style: .cancel, handler: nil)
                alert.addAction(yes)
                alert.addAction(no)
                self.present(alert, animated: true, completion: nil)
                //
            }
            else {
            // here you have a org request bucket
            if let following = snapshot.value as? [String : AnyObject] {
                for (ke, value) in following {
                    if value as! String == self.organizationFiltered[indexPath.row].OrgId {
                        if self.organizationFiltered[indexPath.row].OrgCreatorId != uid {
                            //// change cell color or manip cell here
                    let alert = UIAlertController(title: "Already Sent", message: "Do you want to cancel your request?", preferredStyle: .alert)
                    let yes = UIAlertAction(title: "Yes cancel request", style: .cancel, handler: { (_) in
                        isFollower = true
                        
                        ref.child("leaders").child(uid).child("My Organizations Requests/\(ke)").removeValue()
                        ref.child("Organizations").child(self.organizationFiltered[indexPath.row].OrgId!).child("Members Request/\(ke)").removeValue()
                        
                        self.orgsListTableView.cellForRow(at: indexPath)?.accessoryType = .none
                            
                    })
                        let no = UIAlertAction(title: "No! Dont Cancel Request", style: .default, handler: nil)
                        alert.addAction(yes)
                        alert.addAction(no)
                        self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
            if !isFollower {
                
                let alert = UIAlertController(title: "Group Request", message: "Are you sure you want to request to joing this Organization?", preferredStyle: .alert)
                let yes = UIAlertAction(title: "Yes Request!", style: .default, handler: { (_) in
                
                    let following = ["My Organizations Requests/\(key)" : self.organizationFiltered[indexPath.row].OrgId]
                    let followers = ["Members Request/\(key)" : uid]
                
                    ref.child("leaders").child(uid).updateChildValues(following)
                    ref.child("Organizations").child(self.organizationFiltered[indexPath.row].OrgId!).updateChildValues(followers)
                    self.orgsListTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                 })
                let no = UIAlertAction(title: "No! Dont Request", style: .destructive, handler: nil)
                alert.addAction(yes)
                alert.addAction(no)
                self.present(alert, animated: true, completion: nil)
              }
               else {
               // self.orgsListTableView.cellForRow(at: indexPath)?.accessoryType = .none
              }
            }
          }
        })
        ref.removeAllObservers()

    }
    
    
   
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearching{
            return organizationFiltered.count
        } else {
            return organization.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "joinOrgCell", for: indexPath) as! OrganizationCell
        if inSearching{
            checkFollowing(indexPath: indexPath)
            checkGroup(indexPath: indexPath)
           
            cell.joinOrganizationNameLbl.text = self.organizationFiltered[indexPath.row].OrgId! + "\n~" + self.organizationFiltered[indexPath.row].OrgTitle
            cell.foll.text = self.organizationFiltered[indexPath.row].foll
            
        }
        return cell
    }
    
    func checkFollowing(indexPath: IndexPath) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        var isFollower = false
        
        ref.child("leaders").child(uid).child("My Organizations Requests").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject] {
                for (_, value) in following {
                    if value as! String == self.organization[indexPath.row].OrgId {
//                        self.orgsListTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                       // self.organization[indexPath.row].foll = "Pending..."
                    }
                    else {
//                        self.orgsListTableView.cellForRow(at: indexPath)?.accessoryType = .none
                       // self.organization[indexPath.row].foll = "Click To Send Request..."
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    func checkGroup(indexPath: IndexPath) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        var isFollower = false
        self.groupMember = false
        
        ref.child("leaders").child(uid).child("My Organizations").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject] {
                for (_, value) in following {
                    if value as! String == self.organizationFiltered[indexPath.row].OrgId {
                        self.orgsListTableView.cellForRow(at: indexPath)?.accessoryType = .disclosureIndicator
                        self.groupMember = true
                    }
                    else {
//                        self.orgsListTableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                    
                }
            }
        })
        ref.removeAllObservers()
    }

    
    func checkFollowing2() {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        var isFollower = false
        
        ref.child("leaders").child(uid).child("My Organizations Requests").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject] {
                
                for x in 0...self.organization.count - 1 {
                     for (_, value) in following {
                       if self.organization[x].OrgId == value as! String {
                            self.organization[x].foll = "Pending..."
                            break
                        }
                    }
                }
                
                for x in  0...self.organization.count - 1{
                    if self.organization[x].foll == nil {
                         self.organization[x].foll = "Click to send request"
                    }
                }
                for x in  0...self.organization.count - 1{
                    if self.organization[x].OrgCreatorId == FIRAuth.auth()?.currentUser?.uid {
                        self.organization[x].foll = "😁My Organization😁"
                    }
                }
            }
        })
        ref.removeAllObservers()
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == nil || searchBar.text == "" {
            
            inSearching = false
            orgsListTableView.reloadData()
            
        } else {
            
            inSearching = true
            var lower = searchBar.text!
            if organization.count > 0 {
           for x in 0...organization.count - 1  {
                    if lower == organization[x].OrgId! {
                        organizationFiltered = [organization[x]]//organization.filter({$0.OrgId?.range(of: lower) != nil})
                        
                        orgsListTableView.reloadData()
                    }
                }
            }
        }

    }
    
   

}
