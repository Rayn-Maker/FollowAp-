//
//  MyInvitesVC.swift
//  PokeSearch
//
//  Created by Radiance Okuzor on 7/14/17.
//  Copyright © 2017 Radiance Okuzor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class MyInvitesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveSouls()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        retrieveSouls()
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
     var soulArray = [SoulData]()
    var mySoulsKey = [String]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soulArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "myInvitesToSoulsData", sender: self)
    }
    
    func numberOfSections(in prayerTable: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "mySoulsCell", for: indexPath)
        
        
        cell.textLabel?.text = self.soulArray[indexPath.row].firstName + " " + self.soulArray[indexPath.row].lastName + "   " + "IR -\(self.soulArray[indexPath.row].ir ?? 0)"
        
        
        
        return cell
    }
    
    
    
    
    func retrieveSouls() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        ref.child("leaders").child(uid!).child("myInvites").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
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
                        self.soulArray.sort(by: { $0.firstName < $1.firstName })
                        self.tableView.reloadData()
                        
                    })
                    
                }
            })
            ref.removeAllObservers()
       
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myInvitesToSoulsData" {
                        let vc = segue.destination as! MySoulsData
                        let indexPath = tableView.indexPathForSelectedRow
            vc.mySoulData.append(soulArray[(indexPath!.row)].firstName)
            vc.mySoulData.append(soulArray[(indexPath!.row)].lastName)
            vc.mySoulData.append(soulArray[(indexPath!.row)].phoneNumber)
            vc.mySoulData.append(soulArray[(indexPath!.row)].email)
            vc.mySoulData.append(soulArray[(indexPath!.row)].invitee)
            vc.mySoulData.append(soulArray[(indexPath!.row)].eventContacted)
            vc.mySoulData.append(soulArray[(indexPath!.row)].address)
            vc.mySoulData.append(soulArray[(indexPath!.row)].school)
            vc.mySoulData.append(soulArray[(indexPath!.row)].sex)
            vc.mySoulData.append(soulArray[(indexPath!.row)].race)
            vc.mySoulData.append(soulArray[(indexPath!.row)].soulID)
            vc.orgID = soulArray[(indexPath!.row)].OrgID
            vc.eventID = soulArray[(indexPath!.row)].eventID
            
       
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        viewDidLoad()
    }

    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
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
        
        let alert = UIAlertController(title: soulArray[indexPath.row].firstName, message: strng, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)

    }
}

