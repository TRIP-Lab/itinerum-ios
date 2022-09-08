//
//  Constants.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/8/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import UIKit

let googleAPIKey = "AIzaSyCFfTFAOL5wSu4tTSJRxneBwN33QqnN_ro"
let FAQLink = "https://itinerum.ca/fr/faq.html"
let newsLetterLink = "https://itinerum.ca/about.html"


let APP_DELEGATE =  (UIApplication.shared.delegate) as? AppDelegate

// notification constant
let correct_identifer = "correct_identifier"
let reject_identifer = "reject_identifer"
let notification_cat_identifer = "stopLocationNotification"

let remainingDaysStr = "2023-12-28T02:00+01:00"

let maxValidatedTrip = 25
let SCREEN_WIDTH: CGFloat = UIScreen.main.bounds.size.width

let locationNotification = "LocationNotification"
let promptQuestionNotification = "showPromptQuestionNotification"

let email_TO = "zachary.patterson@concordia.ca"

let latitude = 45.5088591
let longitude = -73.5563951

let english_survey_name = "itinerummtlte2018ios"
let french_survey_name = "itinerummtltf2018ios"

/**
 The minimum amount of time the location service will be running in GPS mode.
 */
let  GPS_SWITCH_THRESHOLD:TimeInterval = 60 * 2;
/**
 The value to set the location manager desiredAccuracy in GPS mode.
 */
let MIN_HORIZONTAL_ACCURACY:Double = 30;
/**
 The minimum required distance between new location and last location.
 */
//let MIN_DISTANCE_BETWEEN_POINTS:Int = 30;

let DM_MONITORED_REGION_RADIUS:Int = 100
let DM_MONITORED_REGION_RADIUS_BBAD_MIN:Int =  150
let DM_MONITORED_REGION_RADIUS_BBAD_MAX:Int = 500
let BBAD_RECORD_TIMER:TimeInterval = 60 * 1
let BBAD_MIN_HORIZONTAL_ACCURACY:Double = 100  // location can be recorded under this accuracy
let BBAD_MAX_HORIZONTAL_ACCURACY:Double = 1600;  // this is used for a geofence point when no good location point
let APP_TERMINATED_TIMER:TimeInterval = 160
let MIN_DISTANCE_MODEPROMPT:Double = 150;
let MODEPROMPT_THRESHOLD_ON_APP_TERMINATED:TimeInterval = 60 * 3;
let SCRATCH_STANDARDLOCATION_CYCLE:TimeInterval = 160;
let EXIT_ON_APP_TERMINATED_TIMER:TimeInterval = 60 * 60;
let MONITORING_ACTIVITY_TIMER:TimeInterval = 30;
let MONITORING_ACTIVITY_AUTOMOTIVE_TIMER:TimeInterval = 3;
let DETECTED_MOVES_TIMER:TimeInterval = 60 * 1;
let DM_MONITORED_REGION_RADIUS_KEEPER_MIN:Double = 10
let DM_MONITORED_REGION_RADIUS_KEEPER_MAX:Double = 100
