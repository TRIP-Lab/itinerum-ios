//
//  EfficientLocationManager.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 9/2/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

var isModeprompting:Bool = false
var lastPromptedLocation:CLLocation?

var isAppTerminated:Bool = false

var isModepromptingOnAppTerminated:Bool = false
var lastPromptedLocationOnAppTerminated:CLLocation?
var isMonitoringForRegionExit:Bool = false
var promptTimeOnAppTerminated:Double = 0.0

//var isRecordingStopped:Bool = false
var isModepromptDisabled:Bool = false
// cancelledPrompt
var lastSubmittedPromptedLocation:CLLocation?
var lastCancelledByUserPromptedLocation:CLLocation?
var modepromptCount:Int = 0

struct DMPointOptions : OptionSet {
    let rawValue: UInt32
    
    static let dmPointLaunchPoint = DMPointOptions(rawValue: 1 << 0)
    static let dmPointMonitorRegionStartPoint = DMPointOptions(rawValue: 1 << 1)
    static let dmPointMonitorRegionExitPoint = DMPointOptions(rawValue: 1 << 2)
    static let dmPointApplicationTerminatePoint = DMPointOptions(rawValue: 1 << 3)
}



import Foundation
import CoreLocation
import CoreMotion
import UIKit
import UserNotifications


class EfficientLocationManager: NSObject {
    
    var lastLocation: CLLocation?
    var bestBadLocation: CLLocation?
    var updatedNewLocation: CLLocation?
    var bestBadLocationForRegion: CLLocation?

    var movingRegion: CLCircularRegion?
    var movingRegionKeeper: CLCircularRegion?

    var isRecordingRestarted = false // recording
    var isAppTerminating = false
    var isGps = false
    var isDetectedMoves = false
    var isStationary = false
    var isWalking = false
    var isRunning = false
    var isUnknown = false
    var isAutomotive = false
    var isCycling = false /* iOS 8 and later */
    var isAccel = false

    var bBadLocationTimer: Timer?
    var appTerminatedTimer: Timer?
    var wifiTimer: Timer?
    var exitOnAppTerminatedTimer: Timer?
    var promptCountTimer: Timer?
    var monitoringActivityTimer: Timer?
    var monitoringActivityAutomotiveTimer: Timer?

    var promptTimeCountOnAppTerminated: TimeInterval = 0.0
    var motionActivity: CMMotionActivityManager?
    var motionManager: CMMotionManager?

    var strMAConfidence = ""
    var strBestBadLocationMA = ""
    var accelData: CMAccelerometerData?
    var bestBadAccelData: CMAccelerometerData?
    var minDistanceFilter: Int = 0
    
    var bgTask:UIBackgroundTaskIdentifier?
    
    var locationManager:CLLocationManager = CLLocationManager()
    
    static let shared: EfficientLocationManager = {
        let instance = EfficientLocationManager()
        return instance
    }()
    
    // startDMLocationManager - this is called from DMMainView when its viewDidLoad
    func startDMLocationManager() {
        
        // notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)

        
        // load UserDefaults
        isModeprompting = UserDefaults.standard.bool(forKey: "ISMODEPROMPTING_USER_DEFAULT")
        
        if let lastLocData = UserDefaults.standard.data(forKey: "LASTPROMPTEDLOCATION_DEFAULT") {
            lastPromptedLocation = NSKeyedUnarchiver.unarchiveObject(with: lastLocData) as? CLLocation
        }
        
        isModepromptingOnAppTerminated = UserDefaults.standard.bool(forKey: "ISMODEPROMPTINGOAT_USER_DEFAULT")

        if let lastPromptedLoc = UserDefaults.standard.data(forKey: "LASTPROMPTEDLOCATIONOAT_DEFAULT") {
            lastPromptedLocationOnAppTerminated = NSKeyedUnarchiver.unarchiveObject(with: lastPromptedLoc) as? CLLocation
        }
        
        
        promptTimeOnAppTerminated = UserDefaults.standard.double(forKey: "PROMPTTIMEOAT_USER_DEFAULT")
        
        // for custom survey
        modepromptCount = UserDefaults.standard.integer(forKey: "MODEPROMPTCOUNT_USER_DEFAULT")
        isModepromptDisabled = UserDefaults.standard.bool(forKey: "ISMODEPROMPTDISABLED_USER_DEFAULT")
        //isRecordingStopped = userDefaults.bool(forKey: "ISRECORDINGSTOPPED_USER_DEFAULT") // old
        //isRecordingStopped = UserDefaults.isLocationRecordingEnabled

        if let lastsubmittedPromptedLoc = UserDefaults.standard.data(forKey: "LASTSUBMITTEDPROMPTEDLOCATION_DEFAULT") {
            lastSubmittedPromptedLocation = NSKeyedUnarchiver.unarchiveObject(with: lastsubmittedPromptedLoc) as? CLLocation
        }
        
        if let lastCancelPromptedLoc = UserDefaults.standard.data(forKey: "LASTCANCELLEDBYUSERPROMPTEDLOCATION_DEFAULT") {
            lastSubmittedPromptedLocation = NSKeyedUnarchiver.unarchiveObject(with: lastCancelPromptedLoc) as? CLLocation
        }
        
        
        // use Accel or not
        isAccel = true
        
        // set parameter from survey data
        minDistanceFilter = 25
        
        
        // for ready to update location and create region on app terminated
        if isAppTerminated {
            readyOnAppTerminated()
        }
        
        // if significationLocationService is available - because motionActivity is used only on models which support significantLocation
//        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
//
//            // start motionActivity
//            // if motionActivity is available - iPhone5s or above (M7 or above)
//            if CMMotionActivityManager.isActivityAvailable() {
//                // alloc motionActivity
//                motionActivity = CMMotionActivityManager()
//
//                // to show authorization for motionActivity at the moment user opens DM (finish survery and start DM), motionActivity must be started at first
//                motionActivity?.startActivityUpdates(to: OperationQueue.main, withHandler: { activity in
//                })
//                // stop motionActivity
//                motionActivity?.stopActivityUpdates()
//            }
//        }
        
        // set locationManager property
        self.initializeLocationProperty()
        
        // start significantLocationService, to keep running and wake up DM if it is terminated. SignificantLocation doesn't use battery a lot
        // and it also can keep app running in background(terminated) - glitch?
        self.startSignificantLocation()

        // start motion - accelerometer
        if isAccel {
            motionManager = CMMotionManager()
        }
        
        // recording
        if UserDefaults.isLocationRecordingEnabled == true {
            startRecording()
        }
        //    // start GPS mode
        //    [self switchToGps];
        
        // start motionActivity - call this after switchToGps because there is isGPS flag
        // if motionActivity is available - iPhone5s or above (M7 or above)
        if CMMotionActivityManager.isActivityAvailable() {
            // alloc motionActivity
            motionActivity = CMMotionActivityManager()
            startMotionActivity()
        }
    }

    
    // recording
    // startRecording - this is called from startDMLocationManager, and DMMainView when recordingBtn is tapped
    func startRecording() {
        // this method is called when app starts or recocording restarts, so check if it is restarting
        if UserDefaults.isLocationRecordingEnabled == false {
            isRecordingRestarted = true
            //isRecordingStopped = false // by cm
            UserDefaults.isLocationRecordingEnabled = true
        }
        
        // start significantLocationService, to keep running and wake up DM if it is terminated. SignificantLocation doesn't use battery a lot
        // and it also can keep app running in background(terminated) - glitch?
        startSignificantLocation()
        
        isGps = false
        // start GPS mode
        switchToGps()
    }
    
    // stopRecording - this is called from DMMainView when recordingBtn is tapped
    func stopRecording() {
        //isRecordingStopped = true // by cm
        UserDefaults.isLocationRecordingEnabled = false

        // stop monitoringRegionKeeper
        if (movingRegionKeeper != nil) {
            locationManager.stopMonitoring(for: movingRegionKeeper!)
            movingRegionKeeper = nil
        }

        resetBBadLocation()
        switchToGps()
        isMonitoringForRegionExit = false
        lastLocation = nil
        
        // mark previous location as Terminated Point
//        addOptions(toLastInsertedPoint: DMPointApplicationTerminatePoint)
        
        self.stopSignificantLocation()
        self.stopUpdatingLocation()
    }

    func switchToGps() {
        // delete modeprompt - left from geofence
//        modepromptManager.deleteModeprompt()
        
        // stop monitoringRegion
        if (self.movingRegion != nil) {
            self.locationManager.stopMonitoring(for: self.movingRegion!)
            self.movingRegion = nil
        }
        
        // update viewContents - DMMainView - remove RegionOverlay
//        displayDelegate.locationDataSourceStoppedMonitoringRegion()
        
        // stop exitOnAppTerminatedTimer
        if (exitOnAppTerminatedTimer != nil) {
            exitOnAppTerminatedTimer?.invalidate()
            exitOnAppTerminatedTimer = nil
        }
        
        // if significationLocationService is available - because motionActivity is helpful to detect a new location only on models which support significantLocation
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // if motionActivity is available - iPhone5s or above (M7 or above)
            if CMMotionActivityManager.isActivityAvailable() {
                // stop detectMove timer
                if (monitoringActivityTimer != nil) {
                    monitoringActivityTimer?.invalidate()
                    monitoringActivityTimer = nil
                }
                if (monitoringActivityAutomotiveTimer != nil) {
                    monitoringActivityAutomotiveTimer?.invalidate()
                    monitoringActivityAutomotiveTimer = nil
                }
                // stop motionActivity
                motionActivity?.stopActivityUpdates()
            }
        }
        
        // start GPS mode
        print("Location manager switched to Gps")
        if !isGps {
            // start accel to get data only when isGps
            if isAccel {
                startAccelerometer()
            }
            
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // set AccuracyBest in GPS mode
            // start standardLocationService
            self.startUpdatingLocation()
            isGps = true
        }
        resetWifiSwitchTimer() // start timer for Wifi(region) mode
    }

    func switchToWifi(region: CLCircularRegion?) {
        if !self.isGps {
            assert(self.isGps, "switch to wifi should not be called if we aren't currently running on GPS")
        }
        
        // if we aren't given a region, switch to gps
        if region == nil {
            print("failed to acquire point")
            // This is called when app cannot get any locations after launched.
            // Turn on Gps mode, and then it will start from beginning
            switchToGps()
            return
        }
        
        // if region is created by wifiTimer - start wifi mode
        if (region?.identifier == "movingRegion") {
            
            // to make Modeprompt alertView when stopped
            if !isModepromptDisabled {
                if isGps && region != nil {
                    // does not allow to make Modeprompt alertView when geofence created without moving(150m) from last prompted
                    let location = CLLocation(latitude: region?.center.latitude ?? 0, longitude: region?.center.longitude ?? 0)
                    //let deltaDistance: CLLocationDistance = lastPromptedLocation!.distance(from: location)// old
                    let deltaDistance: CLLocationDistance = (lastPromptedLocation != nil) ? lastPromptedLocation!.distance(from: location) : 0
                    
                    if deltaDistance >= MIN_DISTANCE_MODEPROMPT {
                        // show alertView and set notification
                        //modepromptManager.readyModeprompt(location) // old code
                        PromptManager.showAlertOrNotification(location: location, startDate: nil)
                        lastPromptedLocation = location
                        isModeprompting = true
                    }
                }
            }
            
            // start Wifi mode
            print("Location manager switched to wifi")
            wifiTimer?.invalidate() // stop timer for Wifi(region) mode
            
            if isGps {
                // stop accel
                if (self.motionManager?.isAccelerometerActive)! {
                    self.motionManager?.stopAccelerometerUpdates()
                }
                
                locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers // set AccuracyThreeKilo in Wifi mode
                // if significationLocationService is available - because motionActivity can be helpful to detect a new location only on models which support significantLocation
                
                if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                    // if motionActivity is available - iPhone5s or above (M7 or above)
                    if CMMotionActivityManager.isActivityAvailable() {
                        //                    // start motion activity to help detecting moves
                        //                    // because while standardLocation is stopping, sometimes it takes time to recognize exiting from geofence.
                        //                    [self startMotionActivity];
                        
                        // stop standardLocationService
                        self.stopUpdatingLocation()
                        // turn on and off standardLocationService at every 3min in Wifi mode, to keep DM running in background.
                        // Because app cannot keep working over 3min in background without standardLocation
                        perform(#selector(self.scratchStandardLocation), with: nil, afterDelay: SCRATCH_STANDARDLOCATION_CYCLE)
                    }
                    // if significantLocation or motionActivity isn't available, don't stopStandardLocation
                }
                isGps = false
            }
            // if region is created by wifiTimer - start wifi mode
            
            
            // kill DM if it is in Wifi mode(no new locations) for 60 min, onAppTerminated
            if isAppTerminated {
                
                if self.exitOnAppTerminatedTimer != nil {
                    self.exitOnAppTerminatedTimer?.invalidate()
                    self.exitOnAppTerminatedTimer = nil
                }
                
                self.exitOnAppTerminatedTimer = Timer.scheduledTimer(withTimeInterval: EXIT_ON_APP_TERMINATED_TIMER, repeats: false, block: { (timer) in
                    
                    // kill DM by itself if it is in Wifi mode(no new locations) for 60 min, onAppTerminated
                    if isAppTerminated {
                        // prepare for appTerminated, create region and ready modeprompt
                        // just in case
                        self.prepareForAppTerminated()
                    }
                    
                    // delay, for requestStateForRegion:
                    self.perform(#selector(self.appExitOnAppTerminated), with: nil, afterDelay: 5)
                    
                })
            }
            
            // draw region overlay
            // for DMPointOptions
            isMonitoringForRegionExit = true
            // mark previous location as involving a region change
            //                addOptions(toLastInsertedPoint: DMPointMonitorRegionStartPoint)
            // if regionMonitoring succeeded
            // update viewContents - DMMainView - set RegionOverlay
            //                displayDelegate.locationDataSource(self, didStartMonitoringRegionWithCenter: region?.center, radius: region?.radius)
            
            print("started monitoring for region %@ (%f, %f), radius %f", region?.identifier ?? "", region?.center.latitude ?? "", region?.center.longitude ?? "", region?.radius ?? "")
            
        }
        else if (region?.identifier == "movingRegionKeeper") {
            if isAppTerminated {
                // for modeprompt onAppTerminated, the notification will appear in 2min, if no new location updates
                if !isModepromptDisabled {
                    if isGps && region != nil {
                        // does not allow to make Modeprompt alertView when geofence created without moving(150m) from last prompted
                        let location = CLLocation(latitude: region?.center.latitude ?? 0, longitude: region?.center.longitude ?? 0)
                        let deltaDistance: CLLocationDistance = lastPromptedLocation!.distance(from: location)
                        if deltaDistance >= MIN_DISTANCE_MODEPROMPT {
                            
                            // show alertView and set notification - it will notifiy if DM doesn't update location in certain time
                            PromptManager.showAlertOrNotification(location: location, interval: TimeInterval(calcPromptTimeInterval()), startDate: nil)
                            lastPromptedLocationOnAppTerminated = location // put location into prePromptedLocation
                            isModepromptingOnAppTerminated = true
                        }
                    }
                }
            }
        }
    }
    

    
    // turn on and off standardLocationService at every 3min in Wifi mode, to keep DM running in background.
    @objc func scratchStandardLocation() {
        if !isGps {
            // if DM is detectedMovesMode, don't toggle standardLocationService
            if isDetectedMoves == false {
                self.locationManager.startUpdatingLocation()
                self.locationManager.stopUpdatingLocation()
            }
            // repeat this method if DM is in Wifi mode
            perform(#selector(self.scratchStandardLocation), with: nil, afterDelay: SCRATCH_STANDARDLOCATION_CYCLE)
        }
    }
    
    // start accelerometer - motionManager
    func startAccelerometer() {
        if (motionManager?.isAccelerometerAvailable)! {
            if !(motionManager?.isAccelerometerActive)! {
                // set updateInterval
                motionManager?.accelerometerUpdateInterval = 1 / 10 // 10Hz
                
                let handler = { data, error in
                    // this is called when activity is updated
                    self.accelData = data
                    } as CMAccelerometerHandler
                
                // start Accelerometer
                if let aQueue = OperationQueue.current {
                    motionManager?.startAccelerometerUpdates(to: aQueue, withHandler: handler)
                }
            }
        }
    }
    
    // start motion activity to help detecting moves
    func startMotionActivity() {
        strMAConfidence = ""
        
        motionActivity?.startActivityUpdates(to: OperationQueue.main, withHandler: { activity in
            // this is called when activity is updated
            
            // get confidence
            switch activity?.confidence {
            case .low?:
                self.strMAConfidence = "Low"
            case .medium?:
                self.strMAConfidence = "Medium"
            case .high?:
                self.strMAConfidence = "High"
            default:
                self.strMAConfidence = "Error"
            }
            
            // get activity status
            self.isStationary = activity?.stationary ?? false
            self.isWalking = activity?.walking ?? false
            self.isRunning = activity?.running ?? false
            self.isUnknown = activity?.unknown ?? false
            self.isAutomotive = activity?.automotive ?? false
            self.isCycling = activity?.cycling ?? false// iOS 8 and later
            
            // to help detecting moves when in Wifi mode, stopStandardLocation
            if !self.isGps {
                // if significationLocationService is available - because motionActivity can be helpful to detect a new location only on models which support significantLocation
                if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                    // if starts moving
                    if (self.isWalking || self.isRunning) && (activity?.confidence == .low || activity?.confidence == .medium || activity?.confidence == .high) {
                        
                        // start timer to monitor if we're moving for several periods
                        if !(self.monitoringActivityTimer != nil) {
                            self.monitoringActivityTimer = Timer.scheduledTimer(timeInterval: MONITORING_ACTIVITY_TIMER, target: self, selector: #selector(self.detectedMoves(timer:)), userInfo: nil, repeats: false)
                        }
                    } else {
                        if (self.monitoringActivityTimer != nil) {
                            self.monitoringActivityTimer?.invalidate()
                            self.monitoringActivityTimer = nil
                        }
                    }
                    // if starts moving by automotive - monitoring time should be shorter
                    if (self.isAutomotive || self.isCycling) && (activity?.confidence == .low || activity?.confidence == .medium || activity?.confidence == .high) {
                        
                        // start timer to monitor if we're moving for several periods
                        if !(self.monitoringActivityAutomotiveTimer != nil) {
                            self.monitoringActivityAutomotiveTimer = Timer.scheduledTimer(timeInterval: MONITORING_ACTIVITY_AUTOMOTIVE_TIMER, target: self, selector: #selector(self.detectedMoves(timer:)), userInfo: nil, repeats: false)
                        }
                    } else {
                        if (self.monitoringActivityAutomotiveTimer != nil) {
                            self.monitoringActivityAutomotiveTimer?.invalidate()
                            self.monitoringActivityAutomotiveTimer = nil
                        }
                    }
                }
            }
        })
    }
    
    // if we keep moving for several periods, detectedMovesMode starts - startStandardLocation in Wifi mode to recognize exitingFromRegion faster
    @objc func detectedMoves(timer: Timer?) {
        
        // stop motionActivity
        if self.monitoringActivityTimer != nil {
            self.monitoringActivityTimer?.invalidate()
            self.monitoringActivityTimer = nil
        }
        if monitoringActivityAutomotiveTimer != nil{
            monitoringActivityAutomotiveTimer?.invalidate()
            monitoringActivityAutomotiveTimer = nil
        }
        motionActivity?.stopActivityUpdates()
        
        //    // if wifi is not turned on and accuracyThreeKiloMeters, sometimes it takes time to recognize exiting from geofence
        //    // (there is no method to check if wifi is turned on or not)
        //    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;  // set AccuracyBest in GPS mode
        // start standardLocationService
        self.startUpdatingLocation()
        isDetectedMoves = true
        
        perform(#selector(self.cancelDetectedMoves), with: nil, afterDelay: DETECTED_MOVES_TIMER)
    }

   
    @objc func cancelDetectedMoves() {
        // if DM is still in Wifi mode, stopStandardLocation and startMotionActivity again
        if !isGps {
            
            // self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;  // set AccuracyThreeKilo in Wifi mode
            startMotionActivity()
            self.stopUpdatingLocation()
        }
        isDetectedMoves = false
    }
    
    // this timer is used for switching between Gps and Wifi mode.
    // keep reseting timer unless location keeps updating in Gps mode.
    // so, if location doesn't update for a given time, it will switch to Wifi mode
    func resetWifiSwitchTimer() {
        wifiTimer?.invalidate()
        
        if UserDefaults.isLocationRecordingEnabled {
            // recording
            wifiTimer = Timer(timeInterval: GPS_SWITCH_THRESHOLD, target: self, selector: #selector(self.wifiTimerDidFire(_:)), userInfo: nil, repeats: false)
            RunLoop.current.add(wifiTimer!, forMode: .commonModes)
        }
        
        // for modePrompt - to check if stopping for a certain time on AppTerminated
        if isAppTerminated {
            if !isAppTerminating {
                resetPromptTimeCounter()
            }
        }
    }

    @objc func wifiTimerDidFire(_ timer: Timer?) {
        // if region doesn't exist, create
        if (self.movingRegion == nil) {

            if (self.lastLocation != nil) {
                //        create a region to monitor based on last good location
                self.movingRegion = EfficientLocationManager.region(location: (lastLocation?.coordinate)!, radius: DM_MONITORED_REGION_RADIUS, identifier: "movingRegion")
            }
            else if (self.bestBadLocationForRegion != nil) && (self.bestBadLocationForRegion!.horizontalAccuracy <= BBAD_MAX_HORIZONTAL_ACCURACY) {
                // adjust region radius
                let radius = self.adjustRegionRadiusBBad(location: self.bestBadLocationForRegion!)
                //        if we don't have a good location, use our best _acceptable_ location.
                self.movingRegion = EfficientLocationManager.region(location: self.bestBadLocationForRegion!.coordinate, radius: Int(radius), identifier: "movingRegion")
                print("no good points received, using larger geofence")
            }
            
            // bestBadLocationForRegion
            self.bestBadLocationForRegion = nil
            
            
            if (self.movingRegion != nil) {
                // if movionRegion is created, start monitoring region
                self.locationManager.startMonitoring(for: self.movingRegion!)
                print("requesting state for region: %@", self.movingRegion ?? "")
                // "switchToWifiForRegion" will be called from state request
                //        if we have a region, find out if we're actually in it. Only monitor regions we're actually in.
                //        there's a bug in location manager where state requests will fail when executed immediately after a region is added:
                //        http://www.cocoanetics.com/2014/05/radar-monitoring-clregion-immediately-after-removing-one-fails/
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.locationManager.requestState(for: self.movingRegion!)
                } // by cm
                //self.locationManager.perform(#selector(CLLocationManager.requestState(for:)), with: movingRegion, afterDelay: 1)
            } else {
                // if movingRegion isn't created
                self.switchToWifi(region: nil)
            }
        }
    }
    
    // this is called from "(isGPS)didUpdateLocations" or "didExitRegion"
    func updateLocation() {
        
        
        if (updatedNewLocation?.horizontalAccuracy)! <= MIN_HORIZONTAL_ACCURACY {
            // record updatedNewlocation
            self.record(newLocation: updatedNewLocation!, strMAData: wrapMotionActivityData(), accelData: accelData)
        }
        else if (bestBadLocation == nil) {
            
            // if our accuracy isn't any good
            self.bestBadLocation = self.updatedNewLocation
            // we may lose the chances to record bestBadLocation, however we shouldn't lose for the senstive area??? - we should fix - for example, even in bestBadLocation, if app will not be able to record the location around there at all, app should record bestBadLocation
            // keep MAData for bestBadLocation
            self.strBestBadLocationMA = self.wrapMotionActivityData()
            self.bestBadAccelData = self.accelData
            
            // to record bestLocation in bestBadLocation
            if(bBadLocationTimer == nil) {
                self.bBadLocationTimer = Timer.scheduledTimer(withTimeInterval: BBAD_RECORD_TIMER, repeats: false, block: {[unowned self] (timer) in    
                    
                    // record bestBadLocation, if accuracy is less than BBAD_MIN_HORIZONTAL_ACCURACY and not nil
                    if (self.bestBadLocation != nil) && (self.bestBadLocation!.horizontalAccuracy <= BBAD_MIN_HORIZONTAL_ACCURACY) {
                        self.record(newLocation: self.bestBadLocation!, strMAData:self.strBestBadLocationMA, accelData: self.bestBadAccelData)

                    } else {
                        self.resetBBadLocation()
                        // after resetting, put bestBadLocation into bestBadLocationForRegion
                        self.bestBadLocationForRegion = self.updatedNewLocation
                    }
                })
            }
        } else if ((updatedNewLocation?.horizontalAccuracy)! < (bestBadLocation?.horizontalAccuracy)!) {
            bestBadLocation = updatedNewLocation
            // keep MAData for bestBadLocation
            strBestBadLocationMA = wrapMotionActivityData()
            bestBadAccelData = accelData
        }
        
        resetWifiSwitchTimer()
    }
    
    // reset bBadLocationTimer and bBadLocation
    func resetBBadLocation() {
        bestBadLocation = nil
        bestBadLocationForRegion = nil
        if (bBadLocationTimer != nil) {
            bBadLocationTimer?.invalidate()
            bBadLocationTimer = nil
        }
    }
    
    func record(newLocation: CLLocation, strMAData: String, accelData: CMAccelerometerData?) {
        // calculate distance between newLocation and lastLocation
        let deltaDistance: CLLocationDistance = (self.lastLocation != nil) ? newLocation.distance(from: self.lastLocation!) : 0

        //            if we're moving quickly, we will save points less frequently.
        let minDistance = CLLocationDistance(fmax(Float(minDistanceFilter), Float((newLocation.speed) * 4))) // (30m distance OR 27km/h or higher - default) new.10m or 9km/h
        if (!(lastLocation != nil) || (deltaDistance >= minDistance)) {
            
            // make lastPromptedLocation to be used for Modeprompt, if empty
            if !(lastPromptedLocation != nil) {
                lastPromptedLocation = newLocation
            }
            
            // for modePrompt - to check if stopping for a certain time on AppTerminated
            // sometimes DM updates locations in very short time of DM is terminating, so this method should not be called when DM is terminating
            if !isAppTerminating {
                // to check if stopping for a certain time
                checkModePrompt(onAppTerminated: "recordLocation")
            }
            
            // for updating viewContents
            // if self.lastLocation exists, put 0 into options, else put DMPointLaunchPoint into options
            //        DMPointOptions options = self.lastLocation ? 0 : DMPointLaunchPoint;
            var options: DMPointOptions = []

            // if DM restarted in a certain period,
            // DMPointOptions should not be DMPointLaunchPoint
            if !(lastLocation != nil) {
                let now = Date()
                //let deltaTime: TimeInterval = now.timeIntervalSince(lastInsertedLocation.timestamp) // old
                let deltaTime: TimeInterval = now.timeIntervalSince((RealmUtilities.getLastLocationFromDB()?.getCLLocation().timestamp) ?? Date())

                // also, if DM recording is just restarted, mark the new location as LaunchPoint
                if deltaTime >= 60 * 60 * 24 || isRecordingRestarted {
                    // recording
                    options = []
                    isRecordingRestarted = false
                } else {
                    options = .dmPointLaunchPoint
                }
            } else {
                options = []
            }
            
            if isMonitoringForRegionExit {
                options = DMPointOptions(rawValue: UInt32(UInt8(options.rawValue) | UInt8(DMPointOptions.dmPointMonitorRegionExitPoint.rawValue)))
                isMonitoringForRegionExit = false
            }
            
            // save new location - EntityManager
            // and, update viewContents - DMMainView
            //insert(newLocation, pointOptions: options, str: strMAData, accelData: accelData) //old
            let locInfo = LocationInfo.init(location: newLocation, pointType: Int(options.rawValue), mode: Int(strMAData), accelData: accelData)
            RealmUtilities.saveLocationInfo(locationInfo: locInfo)
            lastLocation = newLocation

        }
        
        resetBBadLocation()
    }


    
    // MARK: - Application Lifecycle
    @objc func applicationDidEnterBackground() {
        // keep creating region to have geofence all the time, to wake up DM just in case if DM is killed
        self.keepCreatingRegion()
        
        // save UserDefaults
        saveUserDefaults()
        
        // set bgTask (for 3min)
        let app = UIApplication.shared
        bgTask = app.beginBackgroundTask(expirationHandler: {
            app.endBackgroundTask(self.bgTask!)
            self.bgTask = UIBackgroundTaskInvalid
        })
    }

    
    func keepCreatingRegion() {
        // if region doesn't exist, create
        if !(self.movingRegionKeeper != nil) && UserDefaults.isLocationRecordingEnabled {//by cm
            // recording
            // create region
            // adjust region radius
            let radius = adjustRegionRadiusKeeper(updatedNewLocation)
            // create a region to monitor
            if (self.updatedNewLocation != nil) {
                self.movingRegionKeeper = EfficientLocationManager.region(location: updatedNewLocation!.coordinate, radius: Int(radius), identifier: "movingRegionKeeper")
            }
            
            // if region is created
            if (movingRegionKeeper != nil) {
                // start monitoring region
                locationManager.startMonitoring(for: movingRegionKeeper!)
                
                // request state
                // to know that didDetermineState: is called by requestStateForRegion
                // because, didDetermineState: is called by requestStateForRegion or when DM exits or enters the region.
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.locationManager.requestState(for: self.movingRegionKeeper!)
                }// by cm

                //self.locationManager.perform(#selector(CLLocationManager.requestState(for:)), with: movingRegionKeeper, afterDelay: 1)
            }
        }
    }
    
    // for ready to update location and create region on app terminated, DM can work for only 3min in background(terminated)
    func readyOnAppTerminated() {
        if !(appTerminatedTimer != nil) {
            // it must run timer to create region and quit processing, because bgTask will finish in 3 min
            // it must run timer to create region and quit processing, because bgTask will finish in 3 min
            self.appTerminatedTimer = Timer.scheduledTimer(withTimeInterval: APP_TERMINATED_TIMER, repeats: false, block: {[unowned self] (timer) in
                
                if isAppTerminated {
                    // prepare for appTerminated, create region and ready modeprompt
                    self.prepareForAppTerminated()
                }
                
                // delay, for requestStateForRegion:
                self.perform(#selector(self.quitTaskOnAppTerminated), with: nil, afterDelay: 5)
            })
        }
        
        if bgTask == UIBackgroundTaskInvalid {
            // set bgTask (for 3min)
            let app = UIApplication.shared
            bgTask = app.beginBackgroundTask(expirationHandler: {
                
                app.endBackgroundTask(self.bgTask!)
                self.bgTask = UIBackgroundTaskInvalid
            })
        }
    }

    
    @objc func quitTaskOnAppTerminated() {
    
        // save UserDefaults
        saveUserDefaults()
        
        isAppTerminating = false
        
        // quit timer
        appTerminatedTimer?.invalidate()
        appTerminatedTimer = nil
        
        // quit bgTask
        UIApplication.shared.endBackgroundTask(bgTask!)
        bgTask = UIBackgroundTaskInvalid
    }
    
    @objc func appExitOnAppTerminated() {
        // save UserDefaults
        saveUserDefaults()
        
        isAppTerminating = false
        
        // if app is active(foreground), don't allow to quit - just in case
        let applicationState: UIApplicationState = UIApplication.shared.applicationState
        if applicationState == .background {
            
            // DM quits by itself
            exit(0)
        }
        
    }
    
    func prepareForAppTerminated() {
        isAppTerminating = true
        
        // keep creating region to have geofence all the time, to wake up DM just in case if DM is killed
        self.keepCreatingRegion()
        
        // swithToWifiForRegionl with @"movingRegionKeeper" - to ready modePromptOnAppTerminated
        self.switchToWifi(region: movingRegionKeeper)
    }
    
    // this is called from self recordLocation and DMAppDelegate applicationDidBecomeActive, didReceiveLocalNotification
    // for modePrompt - to check if stopping for a certain time on AppTerminated
    func checkModePrompt(onAppTerminated status: String?) {
        if isModepromptingOnAppTerminated {
            
            
            let now = Date()
            let deltaTime: TimeInterval = now.timeIntervalSince(lastPromptedLocationOnAppTerminated!.timestamp)
            if deltaTime >= promptTimeOnAppTerminated {
                
                // if no new location for more than certain time, make modeprompt
                lastPromptedLocation = lastPromptedLocationOnAppTerminated
                isModeprompting = true
                
                // draw region overlay
                // for DMPointOptions
                isMonitoringForRegionExit = true
                //mark previous location as involving a region change
                //addOptions(toLastInsertedPoint: .dmPointMonitorRegionStartPoint)
                
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                UIApplication.shared.applicationIconBadgeNumber = 1
                UIApplication.shared.applicationIconBadgeNumber = 0

                
                isModepromptingOnAppTerminated = false
            } else {
                // if this is called from self recordLocation
                if (status == "recordLocation") {
                    isModepromptingOnAppTerminated = false
                    
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    UIApplication.shared.applicationIconBadgeNumber = 1
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
            }
        }
    }

    
    // MARK: - misc.
    func adjustRegionRadiusBBad(location: CLLocation) -> CLLocationDistance {
        var radius = CLLocationDistance((location.horizontalAccuracy) * 1.1)
        if radius <= CLLocationDistance(DM_MONITORED_REGION_RADIUS_BBAD_MIN) {
            radius = CLLocationDistance(DM_MONITORED_REGION_RADIUS_BBAD_MIN)
        } else if radius >= CLLocationDistance(DM_MONITORED_REGION_RADIUS_BBAD_MAX) {
            radius = CLLocationDistance(DM_MONITORED_REGION_RADIUS_BBAD_MAX)
        }
        return radius
    }

    func adjustRegionRadiusKeeper(_ location: CLLocation?) -> CLLocationDistance {
        var radius = CLLocationDistance((location?.horizontalAccuracy ?? 0.0) * 0.1)
        if radius <= DM_MONITORED_REGION_RADIUS_KEEPER_MIN {
            radius = DM_MONITORED_REGION_RADIUS_KEEPER_MIN
        } else if radius >= DM_MONITORED_REGION_RADIUS_KEEPER_MAX {
            radius = DM_MONITORED_REGION_RADIUS_KEEPER_MAX
        }
        return radius
    }
    
    // for modePrompt - to check if stopping for a certain time on AppTerminated
    func resetPromptTimeCounter() {
        promptTimeCountOnAppTerminated = 0
        if !(promptCountTimer != nil) {
            promptCountTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.promptTimeCounter(_:)), userInfo: nil, repeats: true)
        }
    }
    
    @objc func promptTimeCounter(_ timer: Timer?) {
        promptTimeCountOnAppTerminated += 1
        if promptTimeCountOnAppTerminated >= MODEPROMPT_THRESHOLD_ON_APP_TERMINATED {
            promptTimeCountOnAppTerminated = MODEPROMPT_THRESHOLD_ON_APP_TERMINATED
            promptCountTimer?.invalidate()
            promptCountTimer = nil
        }
    }
    
    func calcPromptTimeInterval() -> Int {
        // promptTimeOnAppTerminated is used for promptTimeInterval for modeprompt onAppTerminated
        // it is also used in checkModePromptOnAppTerminated
        promptTimeOnAppTerminated = MODEPROMPT_THRESHOLD_ON_APP_TERMINATED - promptTimeCountOnAppTerminated
        if promptTimeOnAppTerminated <= 10 {
            promptTimeOnAppTerminated = 10
        }
        return Int(promptTimeOnAppTerminated)
    }
    func wrapMotionActivityData() -> String {
        if (strMAConfidence == "") {
            return "4"
        }
        
        if isStationary {
            return "3"
        }
        if isWalking {
            return "2"
        }
        if isRunning {
            return "8"
        }
        if isCycling {
            // iOS 8 and later
            return "1"
        }
        if isAutomotive {
            return "0"
        }
        if isUnknown {
            return "4"
        }
        
        return "4"
    }
    
    func saveUserDefaults() {
        UserDefaults.standard.set(isModeprompting, forKey: "ISMODEPROMPTING_USER_DEFAULT")
        
        if let lastPromptedLocation = lastPromptedLocation {
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: lastPromptedLocation), forKey: "LASTPROMPTEDLOCATION_DEFAULT")
        }
        
        UserDefaults.standard.set(isModepromptingOnAppTerminated, forKey: "ISMODEPROMPTINGOAT_USER_DEFAULT")
        
        if let lastPromptedLocationOnAppTerminated = lastPromptedLocationOnAppTerminated {
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: lastPromptedLocationOnAppTerminated), forKey: "LASTPROMPTEDLOCATIONOAT_DEFAULT")
        }
        
        UserDefaults.standard.set(promptTimeOnAppTerminated, forKey: "PROMPTTIMEOAT_USER_DEFAULT")
        // for custom survey
        UserDefaults.standard.set(modepromptCount, forKey: "MODEPROMPTCOUNT_USER_DEFAULT")
        UserDefaults.standard.set(isModepromptDisabled, forKey: "ISMODEPROMPTDISABLED_USER_DEFAULT")
        //UserDefaults.standard.set(isRecordingStopped, forKey: "ISRECORDINGSTOPPED_USER_DEFAULT") // recording
        
        if let lastSubmittedPromptedLocation = lastSubmittedPromptedLocation {
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: lastSubmittedPromptedLocation), forKey: "LASTSUBMITTEDPROMPTEDLOCATION_DEFAULT") // cancelledPrompt
        }
        
        if let lastCancelledByUserPromptedLocation = lastCancelledByUserPromptedLocation {
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: lastCancelledByUserPromptedLocation), forKey: "LASTCANCELLEDBYUSERPROMPTEDLOCATION_DEFAULT") // cancelledPrompt

        }
        
        UserDefaults.standard.synchronize()
    }
}

extension EfficientLocationManager: CLLocationManagerDelegate {
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let mostRecentLocation = locations.last else {
            return
        }
        
        print("locations EfficientLocationManager = \(mostRecentLocation.coordinate.latitude) \(mostRecentLocation.coordinate.longitude)")
        self.updatedNewLocation = locations.last
        
        // for ready to update location and create region on app terminated
        if isAppTerminated {
            self.readyOnAppTerminated()
        }
        
        // keep creating region to have geofence all the time, to wake up DM just in case if DM is killed
        self.keepCreatingRegion()
        
        if self.isGps {
            // if Gps mode, updateLocation
            self.updateLocation()
        } else if (self.movingRegion != nil) {
            
            //        if not GPS: this is our fallback. sometimes we don't seem to exit regions, so we're going
            //        to manually check and see if we seem to be far away from the region we're in, ostensibly.
            let movingRegionLocation = CLLocation(latitude: (self.movingRegion?.center.latitude)!, longitude: (self.movingRegion?.center.longitude)!)
            let deltaDistance: CLLocationDistance = movingRegionLocation.distance(from: updatedNewLocation!)
            if (Int((deltaDistance - self.updatedNewLocation!.horizontalAccuracy)) > 150) || !(lastLocation != nil) {
                print("received point likely outside of monitored region, switching to gps")
                self.switchToGps()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as NSError).domain == kCLErrorDomain && (error as NSError).code == 0 {
            self.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location manager did change status: \(status)")
        if (status == .authorizedAlways) == (status == .authorizedWhenInUse) {
            self.startUpdatingLocation()
            self.startDMLocationManager()
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        //    we only want to monitor for exit of regions that we are actually in.
        //    is this problematic? i.e., based on the fact that we only *set* region boundaries when our info has been bad for 2 mins?
        //    probably not: our solution is problematic anyway. This *should* be a decent failsafe. But it requires some testing?
        var stateDescription: String
        switch state {
        case .inside:
            stateDescription = "inside"
        case .outside:
            stateDescription = "outside"
        case .unknown:
            stateDescription = "unknown"
        }
        
        print("determined state: %@ for region %@", stateDescription, region)
        
        // movingRegion
        if (region.identifier == "movingRegion") {
            if state == .inside {
                switchToWifi(region: region as? CLCircularRegion)
            }
            else if state == .outside {
                self.switchToGps()
            }
            else {
                // state Unknown
                self.switchToWifi(region: region as? CLCircularRegion)
            }
        }
        else if (region.identifier == "movingRegionKeeper") {
            if state == .inside {
            }
            else if state == .outside {
                // stop monitoringRegion
                if (movingRegionKeeper != nil) {
                    self.locationManager.stopMonitoring(for: self.movingRegionKeeper!)
                    self.movingRegionKeeper = nil
                }
            }
            else {
                // state Unknown
                // stop monitoringRegion
                if (movingRegionKeeper != nil) {
                    self.locationManager.stopMonitoring(for: self.movingRegionKeeper!)
                    self.movingRegionKeeper = nil
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("user entered %@", region.identifier)
        
        // for ready to update location and create region on app terminated
        if isAppTerminated {
            self.readyOnAppTerminated()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("user exited %@", region.identifier)
        
        // for ready to update location and create region on app terminated
        if isAppTerminated {
            readyOnAppTerminated()
        }
        
        // if exit from movingRegionKeeper, remove it
        if (region.identifier == "movingRegionKeeper") {
            // stop monitoringRegion
            if (movingRegionKeeper != nil) {
                self.locationManager.stopMonitoring(for: self.movingRegionKeeper!)
                self.movingRegionKeeper = nil
            }
        }
        
        if !(region.identifier == "movingRegionKeeper") || !isGps {
            // switch to Gps mode and stop monitoringRegion
            switchToGps()
            
            // to fix glitch, app should call a method in "(isGPS)didUpdateLocations", at this time.
            // so, I moved its method into "updateLocations", to call it from here.
            updateLocation()
        }
    }
    // failed to create a region
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        
        // for ready to update location and create region on app terminated
        if isAppTerminated {
            readyOnAppTerminated()
        }
        
        // if failed to create a region "movinRegion", switch to GPS again
        if (region?.identifier == "movingRegion") {
            switchToGps()
        } else if (region?.identifier == "movingRegionKeeper") {
            // stop monitoringRegion
            if (movingRegionKeeper != nil) {
                self.locationManager.stopMonitoring(for: self.movingRegionKeeper!)
                self.movingRegionKeeper = nil
            }
        }
    }
}

extension EfficientLocationManager {
    
    static func region(location:CLLocationCoordinate2D, radius:Int, identifier:String) -> CLCircularRegion? {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let region = CLCircularRegion(center: location, radius: CLLocationDistance(radius), identifier: identifier)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            return region
        }
        
        return nil
    }
    
    func initializeLocationProperty() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 25 //meter
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.delegate = self
        
    }
    
    func askPermissionForLocationAccess() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    
    static func isLocationServiceEnabled() -> ServiceStatus
    {
        if CLLocationManager.locationServicesEnabled()
        {
            switch(CLLocationManager.authorizationStatus())
            {
            case .restricted, .denied:
                return ServiceStatus.disabled
            case .notDetermined:
                return ServiceStatus.notDetermine
            case .authorizedAlways, .authorizedWhenInUse:
                return ServiceStatus.enabled
            }
        }
        else
        {
            print("Location services are not enabled")
            return ServiceStatus.disabled
        }
    }
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func startSignificantLocation() {
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func stopSignificantLocation() {
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
}
