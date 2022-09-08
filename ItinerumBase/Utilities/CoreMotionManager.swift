//
//  CoreMotionManager.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/27/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit

class CoreMotionManager: NSObject {
    
    typealias CompletionHandler = (_ type:String) -> Void
    typealias CompletionHandler1 = (_ type:Bool) -> Void
    typealias systemAlertPermissionStatus = ((_ status:ServiceStatus) -> Void)

    var activityManager:CMMotionActivityManager!
    var pedometer:CMPedometer!
    
    override init() {
        super.init()
        activityManager = CMMotionActivityManager()
        pedometer = CMPedometer()
    }
    
    static let shared = CoreMotionManager()
    
    

    func isCoreMotionEnabled() -> ServiceStatus {
        if #available(iOS 11.0, *) {
            if CMMotionActivityManager.authorizationStatus() == .notDetermined {
                return ServiceStatus.notDetermine
            }
            else if (CMMotionActivityManager.authorizationStatus() == .denied) || CMMotionActivityManager.authorizationStatus() == .restricted{
                return ServiceStatus.disabled
            }
            else {
                return ServiceStatus.enabled
            }
        } else {
            if CMSensorRecorder.isAuthorizedForRecording() {
                return ServiceStatus.enabled
            }else{
                return ServiceStatus.disabled
            }
        }
    }
    
    func startUpdatingActivity(completionHandler: @escaping CompletionHandler){
        
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.startUpdates(from: Date()) { data, error in
                DispatchQueue.main.async(execute: {
                    if (data != nil && error == nil) {
                        let steps = data!.numberOfSteps
                        print("steps: \(steps)")
                    }
                })
            }
        }
        
        
        if CMMotionActivityManager.isActivityAvailable() {

            
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: {
                (data: CMMotionActivity?) in
                DispatchQueue.main.async(execute: {
                    if let data = data {
                        if data.stationary {
                            completionHandler("stationary")
                        }else if data.walking {
                            completionHandler("walking")
                        }else if data.running {
                            completionHandler("running")
                        }else if data.automotive {
                            completionHandler("automotive")
                        }else{
                            completionHandler("None")
                        }
                    }
                })
            })
        }else{
            completionHandler("None")
        }
    }
    
    func askForCoreMotionPermission() {
        if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: { (data: CMMotionActivity?) in
                self.activityManager.stopActivityUpdates()
            })
        }else{
        }
    }
    
    static func showActivityPermissionAlert() {
        let cameraAlert = UIAlertController (title: LocalizeString.activity_permission_title.localized(), message: LocalizeString.activity_permission_message.localized(), preferredStyle: .alert)
        
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
        Utility.topMostViewController()?.present(cameraAlert, animated: true, completion: nil)
    }
}

