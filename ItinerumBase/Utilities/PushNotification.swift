//
//  PushNotification.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/6/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation

import Foundation
import UserNotifications
import UIKit


class PushNotificationManager: NSObject {

    typealias CompletionHandler = (_ success:Bool) -> Void
    //static let shared = NotificationManager()
    
    static let shared: PushNotificationManager = {
        let instance = PushNotificationManager()
        return instance
    }()
    
    
    override init() {
        super.init()
    }
    
    func isPushNotificationRegistered() {
        if UIApplication.shared.isRegisteredForRemoteNotifications == true {
        }
        else {
        }
    }
    
    func isApproved(completionHandler: @escaping CompletionHandler) {
        
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                
                self.registerPushNotification(completionHandler: { (granted) in
                    if (granted == true) {
                        DispatchQueue.main.async {
                            completionHandler(true)
                        }
                    }
                })
            }
            else if settings.authorizationStatus == .denied {
                DispatchQueue.main.async {
                    completionHandler(false)
                }
            }
            else if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    completionHandler(true)
                }
            }
        })
    }
    
    
    func registerPushNotification(completionHandler: @escaping CompletionHandler){
        //self.setCategories()
        //UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
            if (granted == true) {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                DispatchQueue.main.async {
                    completionHandler(true)
                }
            }
            else {
                DispatchQueue.main.async {
                    completionHandler(false)
                }
            }
        })
    }
    
    func unRegisterPushNotification(completionHandler: @escaping CompletionHandler) {
        UIApplication.shared.unregisterForRemoteNotifications()
        completionHandler(false)
    }
    
    static func notificationPermissionAlert() {
        let cameraAlert = UIAlertController (title: LocalizeString.Notification_permission_Title.localized(), message: LocalizeString.Notification_permission_message.localized(), preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: LocalizeString.settings.localized(), style: .default) { (_) -> Void in
            if  let settingsUrl = URL(string:UIApplicationOpenSettingsURLString){
                DispatchQueue.main.async {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: LocalizeString.cancel.localized(), style: .default, handler: nil)
        cameraAlert .addAction(cancelAction)
        cameraAlert .addAction(settingsAction)
        self.topMostViewController()?.present(cameraAlert, animated: true, completion: nil)
    }
    
    static func topMostViewController() -> UIViewController? {
        let topWindow = UIWindow(frame: UIScreen.main.bounds)
        topWindow.rootViewController = UIViewController()
        topWindow.windowLevel = UIWindowLevelAlert + 1
        topWindow.makeKeyAndVisible()
        return topWindow.rootViewController
    }
    
    private func setCategories() {
        let acceptAction = UNNotificationAction(identifier: correct_identifer, title: LocalizeString.correct, options: [])
        let rejectReject = UNNotificationAction(identifier: reject_identifer, title:LocalizeString.dismiss, options: [])
        let locationNotificationCategory = UNNotificationCategory(identifier:notification_cat_identifer,actions: [acceptAction, rejectReject], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([locationNotificationCategory])
    }

}

