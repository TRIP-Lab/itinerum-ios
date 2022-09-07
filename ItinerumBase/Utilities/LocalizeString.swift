//
//  LocalizeString.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/27/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit
import Foundation

public struct LocalizeString {
    static let guideline_and_term_and_condition = "guideline_and_term_and_condition".localized()
    static let allow_notifications = "allow_notifications".localized()
    static let allow_location = "allow_location".localized()
    static let allow_activity = "allow_activity".localized()
    static let next = "next".localized()
    static let settings = "settings".localized()
    static let cancel = "cancel".localized()
    static let yes = "yes".localized()
    static let no = "no".localized()
    static let back = "back".localized()
    static let done = "done".localized()
    static let save = "save".localized()
    static let proejct_name = "project_name".localized()
    static let of = "of".localized()
    
    // email setup
    static let email_subject = "email_subject".localized()
    static let mail_not_setup_message = "mail_not_setup_message".localized()
    static let email_sent_message = "email_sent_message".localized()
    static let email_send_fail = "email_send_fail".localized()

    static let from_date = "from_date".localized()
    static let to_date = "to_date".localized()
    static let enter_date_range = "enter_date_range".localized()
    
    static let today = "today".localized()
    static let yesterday = "yesterday".localized()
    static let custom_Days = "custom_Days".localized()
    static let All_Days = "All_Days".localized()
    
    static let select_location_on_map = "select_location_on_map".localized()

    static let complete_survey_message = "complete_survey_message".localized()
    static let trip_completed_alert_title = "trip_completed_alert_title".localized()
    static let trip_completed_alert_message = "trip_completed_alert_message".localized()

    static let map_search_bar_placeholder = "map_search_bar_placeholder".localized()
    // local notification/alert
    static let You_seem_stopped = "You_seem_stopped".localized()
    static let have_reached_destination = "have_reached_destination".localized()
    static let correct = "correct".localized()
    static let dismiss = "dismiss".localized()
    
    // edit trip screen
    static let adding_destination = "adding_destination".localized()
    static let notIncrement_validated_Trip = "notIncrement_validated_Trip".localized()
    static let continueTile = "continueTile".localized()
    static let destination_location = "destination_location".localized()
    static let edit_arrival_date = "edit_arrival_date".localized()
    static let edit_arrival_time = "edit_arrival_time".localized()


    //alert message and alert title
    static let Location_permission_Title = "Location_permission_Title".localized()
    static let Location_permission_message = "Location_permission_message".localized()
    static let Notification_permission_Title = "Notification_permission_Title".localized()
    static let Notification_permission_message = "Notification_permission_message".localized()
    static let activity_permission_title = "activity_permission_title".localized()
    static let activity_permission_message = "activity_permission_message".localized()
    
    // extra added localization strings
    static let networkError = "network_error".localized()
    static let pls_enter_your_input = "pls_enter_your_input".localized()
    static let enter_valid_email = "enter_valid_email".localized()
    
    //settins screen alert
   static let pause_recording = "pause_recording".localized()
   static let Are_you_sur_for_pause_recording = "Are_you_sur_for_pause_recording".localized()
   static let resume_recording = "resume_recording".localized()
   static let Are_you_sur_for_resume_recording = "Are_you_sur_for_resume_recording".localized()
    
    // info screen
    static let feedback = "feedback".localized()
    static let consent_agreement = "consent_agreement".localized()
    static let consent_agreement_desc = "consent_agreement_desc".localized()
    static let About_Itinerum_MTL = "About_Itinerum_MTL".localized()
    static let About_Itinerum_MTL_desc = "About_Itinerum_MTL_desc".localized()


    struct OccupationQues {
        static let ques_title = "occupation_ques_title"
        static let ques = "occupation_ques"
        static let option_1 = "occupation_option_1"
        static let option_2 = "occupation_option_2"
        static let option_3 = "occupation_option_3"
        static let option_4 = "occupation_option_4"
        static let option_5 = "occupation_option_5"
        static let option_6 = "occupation_option_6"
    }
    
    struct WorkLocationQues {
        static let ques_title = "work_location_ques_title"
        static let ques = "work_location_ques"
        
    }
    
    struct HomeLocationQues {
        static let ques_title = "home_location_ques_title"
        static let ques = "home_location_ques"
    }
    
    struct TravelToWork1Ques {
        static let ques_title = "travelToWork1_ques_title"
        static let ques = "travelToWork1_ques"
        static let option_1 = "travelToStudyOrWork_option_1"
        static let option_2 = "travelToStudyOrWork_option_2"
        static let option_3 = "travelToStudyOrWork_option_3"
        static let option_4 = "travelToStudyOrWork_option_4"
        static let option_5 = "travelToStudyOrWork_option_5"
        static let option_6 = "travelToStudyOrWork_option_6"
        static let option_7 = "travelToStudyOrWork_option_7"
        static let option_8 = "travelToStudyOrWork_option_8"

    }
    
    struct TravelToWork2Ques {
        static let ques_title = "travelToWork2_ques_title"
        static let ques = "travelToWork2_ques"
        static let option_1 = "alternativeTravelToStudyOrWork_option_1"
        static let option_2 = "alternativeTravelToStudyOrWork_option_2"
        static let option_3 = "alternativeTravelToStudyOrWork_option_3"
        static let option_4 = "alternativeTravelToStudyOrWork_option_4"
        static let option_5 = "alternativeTravelToStudyOrWork_option_5"
        static let option_6 = "alternativeTravelToStudyOrWork_option_6"
        static let option_7 = "alternativeTravelToStudyOrWork_option_7"
        static let option_8 = "alternativeTravelToStudyOrWork_option_8"
        static let option_9 = "alternativeTravelToStudyOrWork_option_9"
    }
    
    struct StudyLocationQues {
        static let ques_title = "study_location_ques_title"
        static let ques = "study_location_ques"
    }
    
    struct TravelToStudy1Ques {
        static let ques_title = "travelToStudy1_ques_title"
        static let ques = "travelToStudy1_ques"
        static let option_1 = "travelToStudyOrWork_option_1"
        static let option_2 = "travelToStudyOrWork_option_2"
        static let option_3 = "travelToStudyOrWork_option_3"
        static let option_4 = "travelToStudyOrWork_option_4"
        static let option_5 = "travelToStudyOrWork_option_5"
        static let option_6 = "travelToStudyOrWork_option_6"
        static let option_7 = "travelToStudyOrWork_option_5"
        static let option_8 = "travelToStudyOrWork_option_6"

    }
    
    struct TravelToStudy2Ques {
        static let ques_title = "travelToStudy2_ques_title"
        static let ques = "travelToStudy2_ques"
        static let option_1 = "alternativeTravelToStudyOrWork_option_1"
        static let option_2 = "alternativeTravelToStudyOrWork_option_2"
        static let option_3 = "alternativeTravelToStudyOrWork_option_3"
        static let option_4 = "alternativeTravelToStudyOrWork_option_4"
        static let option_5 = "alternativeTravelToStudyOrWork_option_5"
        static let option_6 = "alternativeTravelToStudyOrWork_option_6"
        static let option_7 = "alternativeTravelToStudyOrWork_option_7"
        static let option_8 = "alternativeTravelToStudyOrWork_option_8"
        static let option_9 = "alternativeTravelToStudyOrWork_option_9"

    }
    
    struct SexQues {
        static let ques_title = "sex_ques_title"
        static let ques = "sex_ques"
        static let option_1 = "sex_option_1"
        static let option_2 = "sex_option_2"
        static let option_3 = "sex_option_3"
        static let option_4 = "sex_option_4"
    }
    
    struct AgeBracketQues {
        static let ques_title = "age_ques_title"
        static let ques = "age_ques"
        static let option_1 = "age_option_1"
        static let option_2 = "age_option_2"
        static let option_3 = "age_option_3"
        static let option_4 = "age_option_4"
        static let option_5 = "age_option_5"
        static let option_6 = "age_option_6"
        static let option_7 = "age_option_7"
        static let option_8 = "age_option_8"

    }
    
    struct ProvideEmailQues {
        static let ques_title = "feedback_email_ques_title"
        static let ques = "feedback_email_ques"
        static let option_1 = "feedback_email_ques"
    }
    
    /*struct DriverLicenceQues {
        static let ques_title = "licence_ques_title"
        static let ques = ""
        static let option_1 = "licence_option_1"
        static let option_2 = "licence_option_2"
    }
    
    struct ServiceSubscriptionQues {
        static let ques_title = "subscription_ques_title"
        static let ques = "subscription_ques"
        static let option_1 = "subscription_option_1"
        static let option_2 = "subscription_option_2"
        static let option_3 = "subscription_option_3"
        static let option_4 = "subscription_option_4"
        static let option_5 = "subscription_option_5"
    }
    
    struct LiveWithQues {
        static let ques_title = "live_with_ques_title"
        static let ques = ""
        static let option_1 = "live_with_option_1"
        static let option_2 = "live_with_option_2"
        static let option_3 = "live_with_option_3"
        static let option_4 = "live_with_option_4"
    }
    
    struct TotalMemberAtHomeQues {
        static let ques_title = "member_ques_title"
        static let ques = ""
        static let option_1 = "member_option_1"
    }
    
    struct HowManyBelow18Ques {
        static let ques_title = "member_below18_ques_title"
        static let ques = ""
        static let option_1 = "member_below18_option_1"
    }
    
    struct HowManyCarQues {
        static let ques_title = "totalCar_ques_title"
        static let ques = ""
        static let option_1 = "totalCar_option_1"
    }
    
    struct AgreeQues {
        static let ques_title = "agree_ques_title"
        static let ques = "agree_ques"
        static let option_1 = "agree_option_1"
        static let option_2 = "agree_option_2"
    }*/
}
