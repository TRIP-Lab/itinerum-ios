//
//  EnumConstants.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/30/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import UIKit

enum QuestionType : String {
    case occupationQues = "member_type"
    case workLocationQues = "location_work"
    case homeLocationQues = "location_home"
    case travelToWorkQues = "travel_mode_work"
    case alternativeTravelToWorkQues = "travel_mode_alt_work"
    case studyLocationQues = "location_study"
    case travelToStudyQues = "travel_mode_study"
    case alternateTravelToStudyQues = "travel_mode_alt_study"
    case sexQues = "Gender"
    case ageBracketQues = "Age"
    case newsletter = "Newsletter"
    case newsletterFrench = "Infolettre"

    case email = "Email"
    case none
}


enum ScreenType : Int {
    case singleSelection = 1
    case multipleSelection = 2
    case numberInput = 3
    case locationInput = 4
    case textboxInput = 5
    case invalid = 0
}

enum OccupationType : String {
    case fullTimeWorker = "occupation_option_1"
    case partTimeWorker = "occupation_option_2"
    case student = "occupation_option_3"
    case retired = "occupation_option_4"
    case atHome = "occupation_option_5"
    case other = "occupation_option_6"
    case none = "none"
}

enum DateType : Int {
    case today = 1
    case yesterday = 2
    case lastSevenDays = 3
    case customDays = 4
    case allDay = 5
}

