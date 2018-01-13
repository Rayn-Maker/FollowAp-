//
//  SoulData.swift
//  InstagramLike
//
//  Created by Radiance Okuzor on 6/29/17.
//  Copyright © 2017 Vasil Nunev. All rights reserved.
//

import UIKit

struct SoulData {
    
    var soulID: String!
    var firstName: String!
    var lastName: String!
    var phoneNumber: String!
    var cityState: String!
    var email: String!
    var school: String!
    var address: String!
    var sex: String!
    var date: Date!
    var race: String!
    var coming: Bool!
    var followUpNotes = [SoulNotes]()
    var eventContacted: String!
    var eventID: String!
    var OrgID: String!
    var invitee: String!
    var notesTimeStamp: String!
    var contactTimeStamp: Date!
    var ir: Double!
    var inviteeID: String!
    var followUpCount: Int!
    var response: Int!
   
}



struct LeadersData {
    
    var userID: String!
    var fullName: String!
    var imagePath: String!
    var phoneNumber: Int!
    var cityState: String!
    var email: String!
    var school: String!
    var address: String!
    var sex: String!
    var race: String!
    var followUpNotes: String!
    var totalInvites: String!
    var foll: String!
}

struct SoulNotes {
 
    var creatorId: String!
    var author: String!
    var notes: String!
    var notesKey: String!
    var date: Date!
    var dateS: String!
}




