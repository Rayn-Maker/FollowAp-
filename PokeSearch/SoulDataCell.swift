//
//  SoulDataCell.swift
//  InstagramLike
//
//  Created by Radiance Okuzor on 6/29/17.
//  Copyright © 2017 Vasil Nunev. All rights reserved.
//

import UIKit

class SoulDataCell: UITableViewCell {
    
    @IBOutlet weak var mySoulName: UILabel!
    @IBOutlet weak var mySoulNotes: UILabel!
    
    @IBOutlet weak var soulName: UILabel!
    @IBOutlet weak var soulNotes: UILabel!
    
    @IBOutlet weak var soulNote: UILabel!
    @IBOutlet weak var noteTimeStamp: UILabel!
    
    @IBOutlet weak var soulNameForOrg: UILabel!
    
    @IBOutlet weak var mynoteTimeStamp: UILabel!

}

class LeaderCell: UITableViewCell {
    @IBOutlet weak var leadersNameSB: UILabel!
    @IBOutlet weak var leadersEmailSB: UILabel!
    
    @IBOutlet weak var myLeadersName: UILabel!
    @IBOutlet weak var myLeadersEmail: UILabel!
    
    @IBOutlet weak var pendingLeaderName: UILabel!
    @IBOutlet weak var pendingLeaderEmail: UILabel!

    
}
