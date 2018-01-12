//
//  OrganizationHomeVC2.swift
//  PokeSearch
//
//  Created by Radiance Okuzor on 12/11/17.
//  Copyright © 2017 Radiance Okuzor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class OrganizationList2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        strn = (FIRAuth.auth()?.currentUser?.displayName)!
       strn += "\n~"
        strn += (FIRAuth.auth()?.currentUser?.email)!
        authorsLbl.text = strn
        displayPic()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        fetchMyOrgs()
    }


    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var leaderPicture: UIImageView!
    @IBOutlet weak var currentLeader: UILabel!
    @IBOutlet weak var orgsListTableView: UITableView!
    @IBOutlet weak var authorsLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var strn = String()
    var ref = FIRDatabase.database().reference()
    var orgKey = String()
    var organization = [OrgData]()
    var myOrg = [String]()
    var mySoulsKey = [String]()
    var soulArray = [SoulData]()
    
    
    func logout() {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try? FIRAuth.auth()?.signOut()
            } catch  {
                }
            }
        }
    
    func fetchMyOrgs(){
        organization.removeAll()
        myOrg.removeAll()
        let ref = FIRDatabase.database().reference()
        ref.child("leaders").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
        
            let users = snapshot.value as! [String : AnyObject]
    
            for (_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid == FIRAuth.auth()?.currentUser?.uid {
                        if let mygroups = value["My Organizations"] as? [String : String]{
                            for (_,orgs) in mygroups{
                                self.myOrg.append(orgs)
                            }
                        }
            self.myOrg.append(FIRAuth.auth()!.currentUser!.uid)
        
            ref.child("Organizations").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
        
        
            if snapshot.value is NSNull {
                print("organiation folder is null")
            }
            else {
        
            self.organization.removeAll()
        
                guard let groupsSanpshot = snap.value as? [String : AnyObject] else {return}
        
                for (_, value) in groupsSanpshot { //organizationID
                    if let organizationID = value["organizationID"] as? String {
                        for each in self.myOrg {
                            if each == organizationID {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                                var organizationToShow = OrgData()
                                
                                if  let creator = value["creator"] as? String, let creatorID = value["creatorID"] as? String, let organizationName = value["organizationName"] as? String, let dateString = value["date"] as? String, let date = dateFormatter.date(from: dateString) {
                                    organizationToShow.OrgCreatorName = creator
                                    organizationToShow.OrgCreatorId = creatorID
                                    organizationToShow.OrgId = organizationID
                                    organizationToShow.OrgTitle = organizationName
                                    organizationToShow.date = date
                                    self.organization.insert(organizationToShow, at: 0)
                                }
                              }
                            }
                        
                        self.organization.sort(by: { $0.date.compare($1.date) == .orderedDescending })
                            self.orgsListTableView.reloadData()
                        }
                      }
                    }
        
                })
                            }
                        }
                    }
             self.organization.sort(by: { $0.date.compare($1.date) == .orderedDescending })
                    self.orgsListTableView.reloadData()
                })
                ref.removeAllObservers()
        
    }

    
    func creatNewGroup(){
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        
        orgKey = ref.child("Organizations").childByAutoId().key
        let sharedKey = ref.child("Organizations").childByAutoId().key
        
        
        let alert = UIAlertController(title: "New Organization", message: "What's Your Organization Name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter org name here"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let post = UIAlertAction(title: "Create", style: .default) { _ in
            guard let text = alert.textFields?.first?.text else { return }
            if text != "" {
            print(text)
            
            let dateString = String(describing: Date())
            
            let parameters = ["organizationID"    : self.orgKey,
                              "organizationName"  : text,
                              "creatorID"         : uid,
                              "creator"           : FIRAuth.auth()!.currentUser!.displayName!,
                              "date"              : dateString,
                              "SharedKey"         : sharedKey ] 
            let org = ["\(self.orgKey)" : parameters]
            let undrUsers = ["My Organizations/\(self.orgKey)" : self.orgKey]
            let underOrgs = ["Members/\(self.orgKey)" : uid]
            
            self.ref.child("Organizations").updateChildValues(org)
            self.ref.child("leaders").child(uid).updateChildValues(undrUsers)
            self.ref.child("Organizations").child(self.orgKey).updateChildValues(underOrgs)
            self.fetchMyOrgs()
            self.orgsListTableView.reloadData()
            }
        }
        alert.addAction(cancel)
        alert.addAction(post)
        present(alert, animated: true, completion: nil)

        
    }


    
    var userStorage: FIRStorageReference!
    
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    
    func displayPic(){
        let ref = FIRDatabase.database().reference()
        ref.child("leaders").queryOrderedByKey().observeSingleEvent(of: .value, with: {snapshot in
            let users = snapshot.value as! [String : AnyObject]
            self.activitySpinner.hidesWhenStopped = true
            
            for(_,value) in users {
                if let uid = value["uid"] as? String {
                    if uid == FIRAuth.auth()?.currentUser?.uid {
                        if let imagePath = value["urlToImage"] as? String, let cstate = value["cityState"] as? String, let fname = value["full name"] as? String
                            
                        {
                            
                            self.storageRef.reference(forURL: imagePath).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                                if error == nil {
                                    if let data = imgData{
                                        self.leaderPicture.image = UIImage(data: data)
                                    }
                                }
                                else {
                                    print(error?.localizedDescription)
                                }
                            })
                            
                        }
                        
                        
                    } //
                }
            }
            self.activitySpinner.stopAnimating()
            
        })
        ref.removeAllObservers()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupListToGroupView" {
            let vc = segue.destination as! OrganizationHomeVC
            let indexPath = orgsListTableView.indexPathForSelectedRow

            vc.iamUser.append(organization[(indexPath!.row)].OrgId!)
            vc.iamUser.append(organization[(indexPath!.row)].OrgTitle!)
            vc.iamUser.append(organization[(indexPath!.row)].OrgCreatorName!)
            vc.iamUser.append(organization[(indexPath!.row)].OrgCreatorId!)
        
            
            
        }
    }
    
    @IBAction func createNewGroup(_ sender: Any) {
        
        creatNewGroup()
    }
    
 
    
    @IBAction func homePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refresh(_ sender: Any) {
        orgsListTableView.isHidden = false
        fetchMyOrgs()
        displayPic()
    }
    
    
    @IBAction func signOutPressed(_ sender: Any) {
        
        logout()
    }
    
}



extension OrganizationList2: UITableViewDataSource, UITableViewDelegate,  UISearchBarDelegate  {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == orgsListTableView {
            return organization.count
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == orgsListTableView  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "organizationCell", for: indexPath)
            cell.textLabel?.text = self.organization[indexPath.row].OrgTitle
            cell.imageView?.image = #imageLiteral(resourceName: "followAppPp")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "organizationSoulCell", for: indexPath)
            cell.textLabel!.text = soulArray[indexPath.row].firstName + "  " +  soulArray[indexPath.row].lastName
            return cell

        }
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == orgsListTableView {
            performSegue(withIdentifier: "groupListToGroupView", sender: self)
        }
       
    }
   
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if tableView == orgsListTableView {
        let uid = FIRAuth.auth()!.currentUser!.uid
        if self.organization[indexPath.row].OrgCreatorId != uid {
            let alert = UIAlertController(title: "Exit Organization", message: "Are you sure you want to leave this \(self.organization[indexPath.row].OrgTitle!) If you do, you will no longer have access to this groups", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes Leave✌️", style: .destructive, handler: { (_) in
          self.ref.child("Organizations").child(self.organization[indexPath.row].OrgId!).child("Members").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
               if snapshot.value is NSNull {
                print("My Members folder is null")
               }
              else {
                if let orgMembrs = snapshot.value as? [String : AnyObject] {
                    for (ke, value) in orgMembrs {
            
                    if value as! String == uid {
                    self.ref.child("Organizations").child(self.organization[indexPath.row].OrgId!).child("Members/\(ke)").removeValue()
                    self.ref.child("leaders").child(uid).child("My Organizations/\(ke)").removeValue()
                    self.fetchMyOrgs()

                        }
                    }
                }
            }
            
         })
        }) //
        let no = UIAlertAction(title: "Never mind keep me in🕺", style: .default, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
            }
        else { // show souls here
            let alert = UIAlertController(title: "Exit Organization", message: "Sorry you are the chief of \(self.organization[indexPath.row].OrgTitle!) therefore you can't leave Org", preferredStyle: .alert)
          let no = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(no)
         self.present(alert, animated: true, completion: nil)
            
        }
     }
        
    }
    
}

extension UIImageView {
    
    func downloadImage(from imgURL: String!) {
        
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
            
        }
        
        task.resume()
    }
}
