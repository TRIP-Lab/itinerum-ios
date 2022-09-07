//
//  AppDelegate.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/25/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import UserNotifications
import Crashlytics
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var dynamicQuesArray:[Question] = [Question]()
    var efficientLocationManager:EfficientLocationManager = EfficientLocationManager.shared
    weak var homeScreenVCRef:HomeScreen? // only ref of Home screen to show the prompt
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        GMSServices.provideAPIKey(googleAPIKey)
        GMSPlacesClient.provideAPIKey(googleAPIKey)
        RealmDataManager.configure()
        UIApplication.shared.applicationIconBadgeNumber = 1
        UIApplication.shared.applicationIconBadgeNumber = 0
        FirebaseApp.configure()

        
        if Utility.isSurveyComplete == true {
            let storyboard = UIStoryboard.init(name: "SurveyCompleteVC", bundle: nil)
            self.window?.rootViewController = storyboard.instantiateInitialViewController()
        }
        else {
            
            self.createUserAPICall()
            
            if UserDefaults.isUserCreatedSuccessfully {
                let storyboard = UIStoryboard.init(name: "Home", bundle: nil)
                self.window?.rootViewController = storyboard.instantiateInitialViewController()
                //self.efficientLocationManager.startDMLocationManager()
                //TODO: this is where this is sync
                DispatchQueue.global(qos: .background).async {
                    self.updateLocationOnTheServer()
                }
            }
            else {
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                self.window?.rootViewController = storyboard.instantiateInitialViewController()
            }
            
            // this is called when app is launched on app terminated status by some services
            if let launch = launchOptions{
                if launch[UIApplicationLaunchOptionsKey.location] != nil {
                    // it is called by Location services (region, significant)
                    if launch.keys.contains(UIApplicationLaunchOptionsKey.location) {
                        isAppTerminated = true
                    }
                }
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        UIApplication.shared.applicationIconBadgeNumber = 1
        UIApplication.shared.applicationIconBadgeNumber = 0

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        isAppTerminated = false;
        
        if let locAndTime = UserDefaults.standard.getLastPromptedNotificationLocationAndTime() {
            PromptManager.showAlertOrNotification(location: CLLocation.init(latitude: locAndTime.lat, longitude: locAndTime.long), interval: 0, startDate: locAndTime.date)
            
            UserDefaults.standard.saveLastPromptedNotificationLocationAndTime(lat: nil, long: nil)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //TODO: Move this elsewhere
    func updateLocationOnTheServer() {
        QuestionClient.updateLocationDataToServer { (error) in
            if error == nil {
                print("Location sync on the server")
                //TODO: Save timestamp last sucessful sync
                UserDefaults.standard.set(Date().toString(), forKey: "prompt.lastsynctimestamp")
            }
            else {
                print("Location sync not complete = \(error?.description() ?? "nothing")")

            }
        }
    }

    func createUserAPICall() {
        
        if UserDefaults.isUserCreatedSuccessfully {
            return
        }
        
        if !ReachabilityManager.isOnline() {
            Utility.showAlertWithDisappearingTitle(LocalizeString.networkError.localized())
            return
        }
        
        Utility.showLoader()
        QuestionClient.createUser { (questionArray, error) in
            Utility.hideLoader()
            if (error != nil) {
                Utility.showAlertWithDisappearingTitle(error?.localizedDescription.localized())
            }
            else {
                print(questionArray)
                self.dynamicQuesArray = questionArray
            }
        }
    }
    
    func savePromptData(isCancelled:Bool, tripModel:TripModel, location:CLLocation) {
        if isCancelled == true {
            tripModel.latitude = "\(location.coordinate.latitude )"
            tripModel.longitude = "\(location.coordinate.longitude )"
            tripModel.isCancelledPrompt = true
            RealmUtilities.saveTripInfo(tripInfo: tripModel)
        }
        else {
            tripModel.latitude = "\(location.coordinate.latitude )"
            tripModel.longitude = "\(location.coordinate.longitude )"
            tripModel.isCancelledPrompt = false
            RealmUtilities.saveTripInfo(tripInfo: tripModel)
            UserDefaults.updateTripValidation()
        }
    }
}

extension AppDelegate
{
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        print("Notification being triggered AppDelegate = \(notification.request.content.userInfo)")
        //if notification.request.identifier == "" {
        completionHandler( [.alert,.sound,.badge])
        //}
        
        /*let userInfo = notification.request.content.userInfo as! [String:Any]
        print("Tapped in notification appDelegate : \(userInfo)")
        
        let loc = CLLocation.init(latitude: userInfo.numberValue(key: "lat").doubleValue, longitude: userInfo.numberValue(key: "long").doubleValue)
        if PromptManager.isModePrompting == false {
            PromptManager.locationStopAlert(location:loc)
            PromptManager.isModePrompting = true
        }*/
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        let userInfo = response.notification.request.content.userInfo as! [String:Any]
        print("Tapped in notification appDelegate : \(userInfo)")
        
        let loc = CLLocation.init(latitude: userInfo.numberValue(key: "lat").doubleValue, longitude: userInfo.numberValue(key: "long").doubleValue)
        let date = Date.init(fromString: userInfo.stringValue(key: "date"), format: .isoDateTimeSec)
        
        let categoryType = response.notification.request.content.categoryIdentifier
        let categoryActionType = response.actionIdentifier
        print("categoryType : \(categoryType)")
        print("categoryActionType : \(categoryActionType)")
        
        PromptManager.locationStopAlert(location:loc, startTime: date)
        UserDefaults.standard.saveLastPromptedNotificationLocationAndTime(lat: nil, long: nil)

        if categoryActionType == correct_identifer {
            //UserDefaults.updateTripValidation()
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: locationNotification), object: nil, userInfo: nil)
        }
        completionHandler()
    }
}


