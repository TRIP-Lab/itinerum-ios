//
//  AlertUtil.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/25/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class PromptManager: NSObject {

    enum PromptStatus:Int {
        case keepShowingPrompt = 1
        case disabledPrompt = 0
        case notDetermine = 2
    }
    
    static var isModePrompting:Bool = false
    
    static func locationStopAlert(location:CLLocation, startTime:Date?) {
//        guard PromptManager.isModePrompting == false else {
//            return
//        }
        
        let showAlertVC = UIStoryboard.init(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        showAlertVC.msgTxt = LocalizeString.have_reached_destination
        showAlertVC.titleTxt = LocalizeString.You_seem_stopped
        showAlertVC.yesButtonTxt = LocalizeString.correct
        showAlertVC.noButtonTxt = LocalizeString.dismiss
        showAlertVC.location = location
        showAlertVC.promptStartTime = startTime != nil ? startTime : Date()
        showAlertVC.modalPresentationStyle = .overCurrentContext
        showAlertVC.yesButtonActionBlock = {
            /*let dict = ["lat":"\(location.coordinate.latitude)", "long":"\(location.coordinate.longitude)"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: promptQuestionNotification), object: nil, userInfo: dict)*/
            
            let promptQuesVC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "PromptQuesVC") as! PromptQuesVC
            promptQuesVC.tripModel = TripModel()
            promptQuesVC.location = location
            promptQuesVC.promptStartTime = startTime ?? Date()
            APP_DELEGATE?.homeScreenVCRef?.navigationController?.pushViewController(promptQuesVC, animated: true)
            PromptManager.isModePrompting = false
        }
        
        showAlertVC.noButtonActionBlock = {
            let tripModel = TripModel()
            tripModel.displayedAtDate = startTime ?? Date()
            APP_DELEGATE?.savePromptData(isCancelled: true, tripModel: tripModel, location: location)
            PromptManager.isModePrompting = false
        }
        
        Utility.topMostViewController()?.present(showAlertVC, animated: false, completion: nil)
    }
    
    static func showAlertForCompletionOfTripValidate() {
        let showAlertVC = UIStoryboard.init(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        showAlertVC.titleTxt = LocalizeString.trip_completed_alert_title
        showAlertVC.msgTxt = LocalizeString.trip_completed_alert_message
        showAlertVC.yesButtonTxt = LocalizeString.yes
        showAlertVC.noButtonTxt = LocalizeString.no
        showAlertVC.modalPresentationStyle = .overCurrentContext
        showAlertVC.yesButtonActionBlock = {
            UserDefaults.isUserWantInfiniteTripValidation = true
        }
        showAlertVC.noButtonActionBlock = {
            UserDefaults.isUserWantInfiniteTripValidation = false
        }
        
        Utility.topMostViewController()?.present(showAlertVC, animated: false, completion: nil)
    }
    
    static func createNotification(interval:TimeInterval, location:CLLocation) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let notification = UNMutableNotificationContent()
        notification.title = LocalizeString.proejct_name
        notification.subtitle = LocalizeString.You_seem_stopped
        notification.body = LocalizeString.have_reached_destination
        notification.badge = 1
        notification.sound = UNNotificationSound.default()
        notification.categoryIdentifier = notification_cat_identifer
        let dict = ["lat":"\(location.coordinate.latitude)", "long":"\(location.coordinate.longitude)", "date" : Date().toString(format: .isoDateTimeSec)]
        notification.userInfo = dict

        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: interval == 0 ? 1 : interval, repeats: false)
        let request = UNNotificationRequest(identifier: "notification", content: notification, trigger: notificationTrigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    static func showAlertOrNotification(location:CLLocation, interval:TimeInterval = 0, startDate:Date? ) {
        
        if UserDefaults.getTripValidatedCount < maxValidatedTrip {
            if UIApplication.shared.applicationState == .active {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) {
                    PromptManager.locationStopAlert(location:location, startTime: startDate)
                }
            }
            else  {
                self.createNotification(interval: interval, location:location)
                UserDefaults.standard.saveLastPromptedNotificationLocationAndTime(lat: location.coordinate.latitude, long: location.coordinate.longitude)
            }
        }
        else if UserDefaults.isUserWantInfiniteTripValidation == true {
            if UIApplication.shared.applicationState == .active {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) {
                    PromptManager.locationStopAlert(location:location, startTime: startDate)
                }
            }
            else  {
                self.createNotification(interval: interval, location: location)
                UserDefaults.standard.saveLastPromptedNotificationLocationAndTime(lat: location.coordinate.latitude, long: location.coordinate.longitude)

            }
        }
    }
}
