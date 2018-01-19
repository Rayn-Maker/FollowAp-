//
//  LeadersData.swift
//  InstagramLike
//
//  Created by Radiance Okuzor on 6/29/17.
//  Copyright © 2017 Vasil Nunev. All rights reserved.
//

import UIKit


class EventData: NSObject {
    var eventName: String!
    var eventGroup: String!
    var eventCreatorName: String!
    var eventId: String!
    var eventCreatorId: String!
    var eventGroupId: String!
    var eventMembers: String?
    var GroupId: String?
    var GroupCreator: String?
    var date: Date!
}

class OrgData: NSObject {

    var OrgTitle: String!
    var OrgCreatorName: String!
    var OrgCreatorId: String!
    var OrgMembers: String?
    var OrgId: String?
    var date: Date!
    var foll: String!
    var sharedKey: String!
}

class Churches {
    var churchName: String?
    var churchID: String?
    var churchZoneName: String?
    var churchZoneId: String?
    var creatorName: String?
    var creatorID: String?
     var date: Date!
}

class Zones {
    var zoneName: String?
    var zoneKey: String?
    var churchArray: [Churches]?
    var date: Date?
    var creatorID: String?
    var creatorName: String?
}


