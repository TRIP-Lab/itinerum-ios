//
//  EfficientLocationManager_old.swift
//  DataMobile
//
//  Created by Chandramani choudhary on 8/28/18.
//  Copyright © 2018 MML-Concordia. All rights reserved.
//

/*var isModeprompting:Bool = false
var lastPromptedLocation:CLLocation?

var isAppTerminated:Bool = false

var isModepromptingOnAppTerminated:Bool = false
var lastPromptedLocationOnAppTerminated:CLLocation?
var isMonitoringForRegionExit:Bool = false
var promptTimeOnAppTerminated:Double = 0.0

var isDebugLogEnabled:Bool = false
var isDebugLogLiteEnabled:Bool = false

struct DMPointOptions : OptionSet {
    let rawValue: UInt32
    
    static let dmPointLaunchPoint = DMPointOptions(rawValue: 1 << 0)
    static let dmPointMonitorRegionStartPoint = DMPointOptions(rawValue: 1 << 1)
    static let dmPointMonitorRegionExitPoint = DMPointOptions(rawValue: 1 << 2)
    static let dmPointApplicationTerminatePoint = DMPointOptions(rawValue: 1 << 3)
}

enum LocationFilterResult:Int {
    case LocationFilterResultPointValid = 0
    case LocationFilterResultPointTooCloseToPrevPoint = 1
    case LocationFilterResultPointTooInaccurate = 2
    case LocationFilterResultPointInvalid = 3
}


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
let MIN_DISTANCE_BETWEEN_POINTS:Int = 30;

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
let MONITORING_ACTIVITY_AUTOMOTIVE_TIMER:TimeInterval = 10;
let DETECTED_MOVES_TIMER:TimeInterval = 60 * 1;
let DM_MONITORED_REGION_RADIUS_KEEPER_MIN:Double = 10
let DM_MONITORED_REGION_RADIUS_KEEPER_MAX:Double = 100


import Foundation
import CoreLocation
import CoreMotion
import UIKit


class EfficientLocationManager_old_old: NSObject, CLLocationManagerDelegate {
    
    var lastLocation:CLLocation?
    var updatedNewLocation:CLLocation?
    var bestBadLocationForRegion:CLLocation?
    var bestBadLocation:CLLocation?
    
    var movingRegion:CLCircularRegion?
    var movingRegionKeeper:CLCircularRegion?

    var wifiTimer:Timer? = Timer()
    var bBadLocationTimer:Timer? = Timer()
    var appTerminatedTimer:Timer? = Timer()
    var exitOnAppTerminatedTimer:Timer? = Timer()
    var promptCountTimer:Timer? = Timer()
    var monitoringActivityTimer:Timer? = Timer()
    var monitoringActivityAutomotiveTimer:Timer? = Timer()
    
    var isGps:Bool = false
    var isAppTerminating:Bool = false
    var isDetectedMoves:Bool = false
    
    var promptTimeCountOnAppTerminated:TimeInterval = 0
    var motionActivity:CMMotionActivityManager?
    
    var bgTask:UIBackgroundTaskIdentifier?
    
    var locationManager:CLLocationManager = CLLocationManager()

    func startDMLocationManager() {
        
        // notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        
        
        // load UserDefaults
        let userDefaults = UserDefaults.standard
        isModeprompting = userDefaults.bool(forKey: "ISMODEPROMPTING_USER_DEFAULT")
        isModepromptingOnAppTerminated = userDefaults.bool(forKey: "ISMODEPROMPTINGOAT_USER_DEFAULT")

        if let lastLocData = userDefaults.data(forKey: "LASTPROMPTEDLOCATION_DEFAULT") {
            lastPromptedLocation = NSKeyedUnarchiver.unarchiveObject(with: lastLocData) as? CLLocation
        }
        
        if let lastPromptedLoc = userDefaults.data(forKey: "LASTPROMPTEDLOCATIONOAT_DEFAULT") {
            lastPromptedLocationOnAppTerminated = NSKeyedUnarchiver.unarchiveObject(with: lastPromptedLoc) as? CLLocation
        }

        promptTimeOnAppTerminated = userDefaults.double(forKey: "PROMPTTIMEOAT_USER_DEFAULT")

        // for ready to update location and create region on app terminated
        if isAppTerminated {
            self.readyOnAppTerminated()
        }
        
        
        // if significationLocationService is available - because motionActivity is used only on models which support significantLocation
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // if motionActivity is available - iPhone5s or above (M7 or above)
            if CMMotionActivityManager.isActivityAvailable() {
                // alloc motionActivity
                self.motionActivity = CMMotionActivityManager()
                
                // to show authorization for motionActivity at the moment user opens DM (finish survery and start DM), motionActivity must be started at first
                self.motionActivity?.startActivityUpdates(to: OperationQueue.main, withHandler: { activity in
                })
                // stop motionActivity
                self.motionActivity?.stopActivityUpdates()
            }
        }
        
        // set locationManager property
        self.initializeLocationProperty()
        
        // start significantLocationService, to keep running and wake up DM if it is terminated. SignificantLocation doesn't use battery a lot
        // and it also can keep app running in background(terminated) - glitch?
        self.startSignificantLocation()
        
        // start GPS mode
        self.switchToGps()
    }
    
    func switchToGps() {
        
        // stop monitoringRegion
        if (self.movingRegion != nil) {
            self.locationManager.stopMonitoring(for: self.movingRegion!)
            self.movingRegion = nil
        }
        
        // update viewContents - DMMainView - remove RegionOverlay
//        displayDelegate.locationDataSourceStoppedMonitoringRegion()
        
        // stop exitOnAppTerminatedTimer
        if self.exitOnAppTerminatedTimer != nil {
            self.exitOnAppTerminatedTimer?.invalidate()
            self.exitOnAppTerminatedTimer = nil
        }
        
        // if significationLocationService is available - because motionActivity is used only on models which support significantLocation
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // if motionActivity is available - iPhone5s or above (M7 or above)
            if CMMotionActivityManager.isActivityAvailable() {
                // stop motionActivity
                if self.monitoringActivityTimer != nil {
                    self.monitoringActivityTimer?.invalidate()
                    self.monitoringActivityTimer = nil
                }
                if self.monitoringActivityAutomotiveTimer != nil {
                    self.monitoringActivityAutomotiveTimer?.invalidate()
                    self.monitoringActivityAutomotiveTimer = nil
                }
                self.motionActivity?.stopActivityUpdates()
            }
        }
        
        // start GPS mode
        if isGps == false {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest // set AccuracyBest in GPS mode
            // start standardLocationService
            self.startUpdatingLocation()
            self.isGps = true
        }
        self.resetWifiSwitchTimer() // start timer for Wifi(region) mode
    }

    func switchToWifi(region: CLCircularRegion?) {
        if self.isGps == false {
            assert(self.isGps, "switch to wifi should not be called if we aren't currently running on GPS")
        }
        
        // if we aren't given a region, switch to gps
        if region == nil {
            print("failed to acquire point")
            // This is called when app cannot get any locations after launched.
            // Turn on Gps mode, and then it will start from beginning
            self.switchToGps()
            return
        }
        
        // if region is created by wifiTimer - start wifi mode
        if (region?.identifier == "movingRegion") {
    
            // to make Modeprompt alertView when stopped
            if self.isGps && region != nil {
                // does not allow to make Modeprompt alertView when geofence created without moving(150m) from last prompted
                let location = CLLocation(latitude: region?.center.latitude ?? 0, longitude: region?.center.longitude ?? 0)
                let deltaDistance: CLLocationDistance = lastPromptedLocation!.distance(from: location)
                if deltaDistance >= MIN_DISTANCE_MODEPROMPT {
                    // show alertView and set notification
                    //modepromptManager.readyModeprompt(location)// old code
                    APP_DELEGATE?.showAlertOrNotification(interval: 0)
                    lastPromptedLocation = location
                    isModeprompting = true
                }
            }
            
            // start Wifi mode
            print("Location manager switched to wifi")
            self.wifiTimer?.invalidate() // stop timer for Wifi(region) mode
            
            if self.isGps == true {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers // set AccuracyThreeKilo in Wifi mode
                // if significationLocationService is available - because motionActivity can be helpful only on models which support significantLocation
                if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                    // if motionActivity is available - iPhone5s or above (M7 or above)
                    if CMMotionActivityManager.isActivityAvailable() {
                        // start motion activity to help detecting moves
                        // because while standardLocation is stopping, sometimes it takes time to recognize exiting from geofence.
                        self.startMotionActivity()
                        
                        // stop standardLocationService
                        self.stopUpdatingLocation()
                        // turn on and off standardLocationService at every 3min in Wifi mode, to keep DM running in background.
                        // Because app cannot keep working over 3min in background without standardLocation
                        perform(#selector(self.scratchStandardLocation), with: nil, afterDelay: SCRATCH_STANDARDLOCATION_CYCLE)
                    }
                    // if significantLocation or motionActivity isn't available, don't stopStandardLocation
                }
                self.isGps = false
            }
            
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
//            addOptions(toLastInsertedPoint: .dmPointMonitorRegionStartPoint)
            // if regionMonitoring succeeded
            // update viewContents - DMMainView - set RegionOverlay
//            displayDelegate.locationDataSource(self, didStartMonitoringRegionWithCenter: region.center, radius: region.radius)
            
            print("started monitoring for region %@ (%f, %f), radius %f", region?.identifier ?? "", region?.center.latitude ?? "", region?.center.longitude ?? "", region?.radius ?? "")
        }
            // if region is created by onAppTerminated - movingRegionKeeper
        else if (region?.identifier == "movingRegionKeeper") {
            if isAppTerminated {
                // for modeprompt onAppTerminated, the notification will appear in 2min, if no new location updates
                if isGps && (region != nil) {
                    // does not allow to make Modeprompt alertView when geofence created without moving(150m) from last prompted
                    let location = CLLocation(latitude: (region?.center.latitude)!, longitude: (region?.center.longitude)!)
                    let deltaDistance: CLLocationDistance = lastPromptedLocation!.distance(from: location)
                    if deltaDistance >= MIN_DISTANCE_MODEPROMPT {
                        
                        // show alertView and set notification - it will notifiy if DM doesn't update location in certain time
                        //modepromptManager.localNotificationModeprompt = calcPromptTimeInterval()// old code
                        APP_DELEGATE?.showAlertOrNotification(interval: calcPromptTimeInterval())
                        lastPromptedLocationOnAppTerminated = location // put location into prePromptedLocation
                        isModepromptingOnAppTerminated = true
                    }
                }
            }
        }

    }
    
    // turn on and off standardLocationService at every 3min in Wifi mode, to keep DM running in background.
    
    @objc func scratchStandardLocation() {
        if isGps == false {
            // if DM is detectedMovesMode, don't toggle standardLocationService
            if isDetectedMoves == false {
                self.locationManager.startUpdatingLocation()
                self.locationManager.stopUpdatingLocation()
            }
            // repeat this method if DM is in Wifi mode
            perform(#selector(self.scratchStandardLocation), with: nil, afterDelay: SCRATCH_STANDARDLOCATION_CYCLE)
        }
    }

    // start motion activity to help detecting moves

    func startMotionActivity() {
        motionActivity?.startActivityUpdates(to: OperationQueue.main, withHandler: { activity in
            //        BOOL isStationary = activity.stationary;
            let isWalking: Bool? = activity?.walking
            let isRunning: Bool? = activity?.running
            //        BOOL isUnknown = activity.unknown;
            let isAutomotive: Bool? = activity?.automotive
            let isCycling: Bool? = activity?.cycling // iOS 8 and later
            
            // if starts moving
            if (isWalking ?? false || isRunning ?? false) && (activity?.confidence == .medium || activity?.confidence == .high) {
                
                // start timer to monitor if we're moving for several periods
                if !(self.monitoringActivityTimer != nil) {
                    self.monitoringActivityTimer = Timer.scheduledTimer(timeInterval: MONITORING_ACTIVITY_TIMER, target: self, selector: #selector(EfficientLocationManager_old.detectedMoves(timer:)), userInfo: nil, repeats: false)
                }
            } else {
                if (self.monitoringActivityTimer != nil) {
                    self.monitoringActivityTimer?.invalidate()
                    self.monitoringActivityTimer = nil
                }
            }
            // if starts moving by automotive - monitoring time should be shorter
            if (isAutomotive ?? false || isCycling ?? false) && (activity?.confidence == .medium || activity?.confidence == .high) {
                
                // start timer to monitor if we're moving for several periods
                if !(self.monitoringActivityAutomotiveTimer != nil) {
                    self.monitoringActivityAutomotiveTimer = Timer.scheduledTimer(timeInterval: MONITORING_ACTIVITY_AUTOMOTIVE_TIMER, target: self, selector: #selector(EfficientLocationManager_old.detectedMoves(timer:)), userInfo: nil, repeats: false)
                }
            } else {
                if (self.monitoringActivityAutomotiveTimer != nil) {
                    self.monitoringActivityAutomotiveTimer?.invalidate()
                    self.monitoringActivityAutomotiveTimer = nil
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
        wifiTimer = Timer(timeInterval: GPS_SWITCH_THRESHOLD, target: self, selector: #selector(self.wifiTimerDidFire(timer:)), userInfo: nil, repeats: false)
        RunLoop.current.add(wifiTimer!, forMode: .commonModes)
        
        // for modePrompt - to check if stopping for a certain time on AppTerminated
        if isAppTerminated {
            if !isAppTerminating {
                resetPromptTimeCounter()
            }
        }
    }
    
    @objc func wifiTimerDidFire(timer: Timer?) {
        
        
        // if region doesn't exist, create
        if !(movingRegion != nil) {
            
            if (lastLocation != nil) {
                // create a region to monitor based on last good location
                movingRegion = EfficientLocationManager_old.region(location: lastLocation!.coordinate, radius: DM_MONITORED_REGION_RADIUS, identifier: "movingRegion")
            }
            else if (bestBadLocationForRegion != nil) && (bestBadLocationForRegion!.horizontalAccuracy <= BBAD_MAX_HORIZONTAL_ACCURACY) {
                // adjust region radius
                let radius = adjustRegionRadiusBBad(location: bestBadLocationForRegion!)
                //        if we don't have a good location, use our best _acceptable_ location.
                movingRegion = EfficientLocationManager_old.region(location: (bestBadLocationForRegion?.coordinate)!, radius: Int(radius), identifier: "movingRegion")

                print("no good points received, using larger geofence")
            }
            // bestBadLocationForRegion
            bestBadLocationForRegion = nil
            
            
            if (movingRegion != nil) {
                // if movionRegion is created, start monitoring region
                self.locationManager.startMonitoring(for: movingRegion!)
                
                print("requesting state for region: %@", movingRegion ?? "")
                // "switchToWifiForRegion" will be called from state request
                //        if we have a region, find out if we're actually in it. Only monitor regions we're actually in.
                //        there's a bug in location manager where state requests will fail when executed immediately after a region is added:
                self.locationManager.perform(#selector(CLLocationManager.requestState(for:)), with: movingRegion, afterDelay: 1)
            } else {
                // if movingRegion isn't created
                switchToWifi(region: nil)
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location manager did change status: \(status)")
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
            } else if state == .outside {
                switchToGps()
            } else {
                // state Unknown
                switchToWifi(region: region as? CLCircularRegion)
            }
        } else if (region.identifier == "movingRegionKeeper") {
            if state == .inside {
                
            } else if state == .outside {
                // stop monitoringRegion
                self.locationManager.stopMonitoring(for: movingRegionKeeper!)
                movingRegionKeeper = nil
            } else {
                // state Unknown
                // stop monitoringRegion
                self.locationManager.stopMonitoring(for: movingRegionKeeper!)
                movingRegionKeeper = nil
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("user entered %@", region.identifier)
        
        // for ready to update location and create region on app terminated
        if isAppTerminated {
            readyOnAppTerminated()
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
            self.locationManager.stopMonitoring(for: movingRegionKeeper!)
            movingRegionKeeper = nil
        }
        
        if !(region.identifier == "movingRegionKeeper") || !isGps {
            // switch to Gps mode and stop monitoringRegion
            switchToGps()
            
            // to fix glitch, app should call a method in "(isGPS)didUpdateLocations", at this time.
            // so, I moved its method into "updateLocations", to call it from here.
            self.updateLocation()
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
            self.locationManager.stopMonitoring(for: movingRegionKeeper!)
            movingRegionKeeper = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let mostRecentLocation = locations.last else {
            return
        }
        
        print("locations EfficientLocationManager_old = \(mostRecentLocation.coordinate.latitude) \(mostRecentLocation.coordinate.longitude)")
        self.updatedNewLocation = locations.last

        // for ready to update location and create region on app terminated
        if isAppTerminated {
            readyOnAppTerminated()
        }
    
        // keep creating region to have geofence all the time, to wake up DM just in case if DM is killed
        self.keepCreatingRegion()
        
        if isGps {
            // if Gps mode, updateLocation
            self.updateLocation()
        } else if (movingRegion != nil) {
            // if not GPS: this is our fallback. sometimes we don't seem to exit regions, so we're going
            // to manually check and see if we seem to be far away from the region we're in, ostensibly.
            let movingRegionLocation = CLLocation(latitude: (movingRegion?.center.latitude)!, longitude: (movingRegion?.center.longitude)!)
            
            let deltaDistance: CLLocationDistance = movingRegionLocation.distance(from: locations.last!)
            
            if (Int((deltaDistance - locations.last!.horizontalAccuracy)) > 150) || (lastLocation == nil)  {
                print("received point likely outside of monitored region, switching to gps")
                switchToGps()
            }
        }
    }
    
    // this is called from "(isGPS)didUpdateLocations" or "didExitRegion"
    func updateLocation() {
        
        if (updatedNewLocation?.horizontalAccuracy)! <= MIN_HORIZONTAL_ACCURACY {
            // record updatedNewlocation
            self.record(newLocation: updatedNewLocation!)
        } else if !(bestBadLocation != nil) {
            // if our accuracy isn't any good
            bestBadLocation = updatedNewLocation // we may lose the chances to record bestBadLocation, however we shouldn't lose for the senstive area??? - we should fix - for example, even in bestBadLocation, if app will not be able to record the location around there at all, app should record bestBadLocation
            
            // to record bestLocation in bestBadLocation
            if(bBadLocationTimer == nil) {
                self.bBadLocationTimer = Timer.scheduledTimer(withTimeInterval: BBAD_RECORD_TIMER, repeats: false, block: {[unowned self] (timer) in
                    
                    // record bestBadLocation, if accuracy is less than BBAD_MIN_HORIZONTAL_ACCURACY and not nil
                    if (self.bestBadLocation != nil) && (self.bestBadLocation!.horizontalAccuracy <= BBAD_MIN_HORIZONTAL_ACCURACY) {
                        self.record(newLocation: self.bestBadLocation!)

                    } else {
                        self.resetBBadLocation()
                        // after resetting, put bestBadLocation into bestBadLocationForRegion
                        self.bestBadLocationForRegion = self.bestBadLocation
                    }
                })
            }
        } else if ((updatedNewLocation?.horizontalAccuracy)! < (bestBadLocation?.horizontalAccuracy)!) {
            bestBadLocation = updatedNewLocation
        }
        
        resetWifiSwitchTimer()
    }
    
    
    // reset bBadLocationTimer and bBadLocation
    func resetBBadLocation() {
        if (bBadLocationTimer != nil) {
            bBadLocationTimer?.invalidate()
            bBadLocationTimer = nil
            bestBadLocation = nil
            bestBadLocationForRegion = nil
        }
    }
    
    func record(newLocation: CLLocation) {
        
        // calculate distance between newLocation and lastLocation
        let deltaDistance: CLLocationDistance = (self.lastLocation != nil) ? newLocation.distance(from: self.lastLocation!) : 0
        
        // if we're moving quickly, we will save points less frequently.
        let minDistance = CLLocationDistance(fmax(Float(MIN_DISTANCE_BETWEEN_POINTS), Float((newLocation.speed) * 4))) // 30m distance OR 27km/h or higher
        
        if (deltaDistance >= minDistance) || !(lastLocation != nil) {
            

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
//                let deltaTime: TimeInterval = now.timeIntervalSince(lastInsertedLocation.timestamp) // old code
                
                
                let deltaTime: TimeInterval = now.timeIntervalSince((RealmUtilities.getLastLocationFromDB()?.getCLLocation().timestamp) ?? Date())

                if deltaTime < 60 * 60 * 24 {
                    options = []
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
            //insertLocation(newLocation, pointOptions: options) // old code
            let locInfo = LocationInfo.init(location: newLocation, pointType: Int(options.rawValue))
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
    
    // keep creating region to have geofence all the time, to wake up DM just in case if DM is killed
    
    func keepCreatingRegion() {
        // if region doesn't exist, create
        if !(movingRegionKeeper != nil) {
            // create region
            // adjust region radius
            let radius = adjustRegionRadiusKeeper(location: updatedNewLocation!)
            // create a region to monitor
            movingRegionKeeper = EfficientLocationManager_old.region(location: updatedNewLocation!.coordinate, radius: Int(radius), identifier: "movingRegionKeeper")
            
            // if region is created
            if (movingRegionKeeper != nil) {
                // start monitoring region
                self.locationManager.startMonitoring(for: movingRegionKeeper!)
                
                // request state
                // to know that didDetermineState: is called by requestStateForRegion
                // because, didDetermineState: is called by requestStateForRegion or when DM exits or enters the region.
                self.locationManager.perform(#selector(CLLocationManager.requestState(for:)), with: movingRegionKeeper, afterDelay: 1)

            }
        }
    }
    // MARK: - onAppTerminated
    
    // for ready to update location and create region on app terminated, DM can work for only 3min in background(terminated)
    func readyOnAppTerminated() {
        if (appTerminatedTimer == nil) {
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
//                addOptions(toLastInsertedPoint: .dmPointMonitorRegionStartPoint)
                
                isModepromptingOnAppTerminated = false
            } else {
                isModepromptingOnAppTerminated = false
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
    
    func adjustRegionRadiusKeeper(location: CLLocation) -> CLLocationDistance {
        var radius = CLLocationDistance((location.horizontalAccuracy) * 0.1)
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
        
        if (self.promptCountTimer == nil) {
            self.promptCountTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {[unowned self] (timer) in
                self.promptTimeCountOnAppTerminated += 1
                if self.promptTimeCountOnAppTerminated >= MODEPROMPT_THRESHOLD_ON_APP_TERMINATED {
                    self.promptTimeCountOnAppTerminated = MODEPROMPT_THRESHOLD_ON_APP_TERMINATED
                    self.promptCountTimer?.invalidate()
                    self.promptCountTimer = nil
                }
            })
        }
    }
    
    func calcPromptTimeInterval() -> Double {
        // promptTimeOnAppTerminated is used for promptTimeInterval for modeprompt onAppTerminated
        // it is also used in checkModePromptOnAppTerminated
        promptTimeOnAppTerminated = MODEPROMPT_THRESHOLD_ON_APP_TERMINATED - promptTimeCountOnAppTerminated
        if promptTimeOnAppTerminated <= 10 {
            promptTimeOnAppTerminated = 10
        }
        return promptTimeOnAppTerminated
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as NSError).domain == kCLErrorDomain && (error as NSError).code == 0 {
            manager.startUpdatingLocation()
        }
    }

    // saveUserDefaults
    func saveUserDefaults() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(isModeprompting, forKey: "ISMODEPROMPTING_USER_DEFAULT")
        userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: lastPromptedLocation ?? ""), forKey: "LASTPROMPTEDLOCATION_DEFAULT")
        userDefaults.set(isModepromptingOnAppTerminated, forKey: "ISMODEPROMPTINGOAT_USER_DEFAULT")
        userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: lastPromptedLocationOnAppTerminated ?? ""), forKey: "LASTPROMPTEDLOCATIONOAT_DEFAULT")
        userDefaults.set(promptTimeOnAppTerminated, forKey: "PROMPTTIMEOAT_USER_DEFAULT")
        userDefaults.synchronize()
    }


}

extension EfficientLocationManager_old {
    
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
}*/
