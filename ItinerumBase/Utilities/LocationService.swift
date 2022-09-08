//
//  LocationService.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/30/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

enum ServiceStatus {
    case enabled
    case disabled
    case notDetermine
}

class LocationService: NSObject {
    static let sharedInstance: LocationService = {
        let instance = LocationService()
        return instance
    }()
    
    
    
    var locationManager: CLLocationManager!
    var locationFoundBlock:((_ error:Error?) -> Void)?
    var systemAlertPermissionStatus:((_ status:ServiceStatus) -> Void)?
    
    override init() {
        super.init()
        self.initializeLocationProperty()
    }
    
    func initializeLocationProperty() {
        self.locationManager = CLLocationManager()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
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
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.locationManager?.stopUpdatingLocation()
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
    
    static func showLocationPermissionAlert() {
        let cameraAlert = UIAlertController (title: LocalizeString.Location_permission_Title.localized(), message: LocalizeString.Location_permission_message.localized(), preferredStyle: .alert)
        
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
    
    
    static func currentLocation() -> (lat:Double?, long:Double?) {
        var lat:Double? = nil
        var long:Double? = nil
        
        if let lat1 = UserDefaults.standard.object(forKey: "lat") {
            lat = (lat1 as! NSNumber).doubleValue
        }
        
        if let long1 = UserDefaults.standard.object(forKey: "long") {
            long = (long1 as! NSNumber).doubleValue
        }
        
        return (lat, long)
    }
    
    static var isCurrentLocationValid:Bool {
        let lat:Double? = LocationService.currentLocation().lat
        let long:Double? = LocationService.currentLocation().long
        
        guard let latitude = lat, let longitude = long else {
            return false
        }
        
        let coord = CLLocationCoordinate2DMake(latitude, longitude)
        let isValid = CLLocationCoordinate2DIsValid(coord)
        print("isValid = \(isValid)")
        return isValid
    }
    
    static func region(location:CLLocationCoordinate2D, radius:Int, identifier:String) -> CLCircularRegion? {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let region = CLCircularRegion(center: location, radius: CLLocationDistance(radius), identifier: identifier)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            return region
        }
        
        return nil
    }
    
    func monitorRegionAtLocation(location:CLLocationCoordinate2D) {
        // Make sure region monitoring is supported.
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            // Register the region.
            //let maxDistance = locationManager.maximumRegionMonitoringDistance
            
            let regions = self.locationManager.monitoredRegions
            for region in regions {
                self.locationManager.stopMonitoring(for: region)
            }
            
            let region = CLCircularRegion(center: location, radius: 100, identifier: "identifier100")
            region.notifyOnEntry = true
            region.notifyOnExit = true
            self.locationManager.startMonitoring(for: region)
            
            // stop the location manager
            self.stopUpdatingLocation()
        }
    }
    
    func saveLocationInToDatabase(location:CLLocation) {
        RealmUtilities.saveLocationInfo(locationInfo: LocationInfo.init(location: location, pointType: nil, mode: nil, accelData: nil))
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let mostRecentLocation = locations.last else {
            return
        }
        //guard let location = manager.location else {
        //    return
        //}
        
        let locValue:CLLocationCoordinate2D = mostRecentLocation.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        UserDefaults.standard.set(locValue.latitude, forKey: "lat")
        UserDefaults.standard.set(locValue.longitude, forKey: "long")
        UserDefaults.standard.synchronize()
        self.locationManager.stopUpdatingLocation()

        if let block = locationFoundBlock {
            block(nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locations error = \(error)")
        if let block = locationFoundBlock {
            block(error)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if (status == CLAuthorizationStatus.notDetermined) {
            if let block = systemAlertPermissionStatus {
                block(.notDetermine)
            }
        }
        else if (status == CLAuthorizationStatus.restricted || status == CLAuthorizationStatus.denied) {
            if let block = systemAlertPermissionStatus {
                block(.disabled)
            }
        }
        else {
            if let block = systemAlertPermissionStatus {
                block(.enabled)
            }
            locationManager?.startUpdatingLocation()
        }
    }
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.startUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
    }
    
}

