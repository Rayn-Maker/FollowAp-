//
//  EventManagementVC.swift
//  PokeSearch
//
//  Created by Radiance Okuzor on 1/20/18.
//  Copyright © 2018 Radiance Okuzor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import MessageUI

class EventManagementVC: UIViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        formatAttendance()
    }

    

    @IBOutlet weak var attendanceSheet: UITextView!

    
    var eventID: String?
    var eventName: String!
    var orgID: String?
    var reuccuringDays = [String]()
    var attendancd = [Attendance]()
    var emailFile = String()
   var strn = String()
    
    func editEvent(){
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        let parameters = [
            "EventName"  : eventName ?? " " ,
                               "creatorID"    : uid,
                                   "creator"  : FIRAuth.auth()!.currentUser!.displayName!] as [String : Any]
        let event = ["\(eventID ?? "")" : parameters]
        ref.child("Organizations").child(self.orgID!).child("Events").child(eventID!).updateChildValues(event)

    }
    
    
    func formatAttendance(){
        var dat = [String]()
        var nnm = [Attendance]()
        var ar = [Attendance]()
        var camCount = 0
        var tot = 0
        strn = "\(eventName ?? "") Attendance Report"
        strn += "=======================\n"
        if attendancd.count > 0 {
            dat.append(attendancd[0].dateS)
            strn += "-----"
            strn += attendancd[0].dateS
            strn += "-----\n"
           attendancd.sort(by: { $0.name < $1.name })
        
            var j = Attendance()
            j.name = ""
            j.came = ""
        nnm.append(j)
        ar = attendancd
        ar.sort(by: { $0.name < $1.name })
//        nnm.append(ar[0])
        for x in 0...ar.count - 1{
            dat.append(ar[x].dateS)
            if ar[x].name != nnm[x].name {
            strn += "Name: "
            strn += ar[x].name
            strn += "\n"
            strn += "Came: "
            strn += ar[x].came
                if ar[x].came == "yes" {
                    camCount = camCount + 1
                }
            tot = tot + 1
            strn += "\n"
//            if dat[x+1] != dat[x] {
//                strn += "Total who came \(camCount) out of \(tot) \n"
//                strn += "----"
//                strn += ar[x].dateS
//                strn += "Name: "
//                strn += ar[x].name
//                strn += "\n"
//                strn += "Came: "
//                 strn += ar[x].came
//                strn += "----\n"
//            }
            nnm.append(ar[x])
            } else {
               nnm.append(ar[x])
            }
        }
            strn += "Total who came \(camCount) out of \(tot) \n"
    }
        attendanceSheet.text = strn
        saveFile()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        editEvent()
    }
    
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
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
        mailControllerVC.setSubject("\(eventName ?? " ") Attendance Report")
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
        let fileName = "Test"
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
//        print("FilePath: \(fileURL.path)")
        
        let writeString = "\(attendanceSheet.text ?? "")"
        do {
            // Write to the file
            try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {

            
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

}












