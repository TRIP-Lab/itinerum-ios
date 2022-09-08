//
//  LocationInfo.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/22/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation
import CoreMotion

//"latitude": 45.4709612219,
//"longitude": -73.6011947415,
//"altitude": 31.82743,
//"speed": 51.04449870001568,
//"direction": 162.83454384,
//"hAccuracy": 14,
//"vAccuracy": 19,
//"modeDetected": 3,
//"accelerationX": 0.7981422356509369,
//"accelerationY": 0.7147102339936264,
//"accelerationZ": 0.47743632708330497,
//"modeDetected": 1,
//"pointType": 1,
//"timestamp": "2016-10-29T09:25:48-04:00",


class LocationInfo: Object {

   @objc dynamic var latitude:Double = 0.0
   @objc dynamic var longitude:Double = 0.0
   @objc dynamic var altitude:Double = 0.0
   @objc dynamic var speed:Double = 0.0
   @objc dynamic var direction:Double = 0.0
   @objc dynamic var hAccuracy:Double = 0.0
   @objc dynamic var vAccuracy:Double = 0.0
   @objc dynamic var accelerationX:Double = 0.0
   @objc dynamic var accelerationY:Double = 0.0
   @objc dynamic var accelerationZ:Double = 0.0
   @objc dynamic var modeDetected:Int = 0
   @objc dynamic var pointType:Int = 3
   @objc dynamic var timestamp:Double = Date().timeIntervalSince1970
   @objc dynamic var isSync:Bool = false
    
    @objc dynamic var primaryKeyValue: String = Date().timeIntervalSince1970.toString()
   @objc override static func primaryKey() -> String {
        return "primaryKeyValue"
    }
    
    convenience init(copy: LocationInfo) {
        self.init()
        self.latitude = copy.latitude
        self.longitude = copy.longitude
        self.altitude = copy.altitude
        self.speed = copy.speed
        self.direction = copy.direction
        self.hAccuracy = copy.hAccuracy
        self.vAccuracy = copy.vAccuracy
        self.accelerationX = copy.accelerationX
        self.accelerationY = copy.accelerationY
        self.accelerationZ = copy.accelerationZ
        self.modeDetected = copy.modeDetected
        self.pointType = copy.pointType
        self.timestamp = copy.timestamp
        self.isSync = copy.isSync
        self.primaryKeyValue = copy.primaryKeyValue
    }
    
    convenience init(location: CLLocation, pointType:Int?, mode:Int?, accelData:CMAccelerometerData?) {
        self.init()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.speed = location.speed
        self.direction = location.course
        self.hAccuracy = location.horizontalAccuracy
        self.vAccuracy = location.verticalAccuracy
        self.accelerationX = (accelData != nil) ? accelData!.acceleration.x : 0
        self.accelerationY = (accelData != nil) ? accelData!.acceleration.y : 0
        self.accelerationZ = (accelData != nil) ? accelData!.acceleration.z : 0
        self.modeDetected = mode ?? 0
        self.pointType = pointType ?? 0
        self.timestamp = location.timestamp.timeIntervalSince1970
        self.isSync = false
        self.primaryKeyValue = Date().timeIntervalSince1970.toString()
    }
    
    func getDictionary() -> [String:Any]  {
        var dict:[String:Any] = [String:Any]()
        dict["latitude"] =  self.latitude
        dict["longitude"] = self.longitude
        dict["altitude"] = self.altitude
        dict["speed"] = self.speed
        dict["direction"] = self.direction
        dict["hAccuracy"] = self.hAccuracy
        dict["vAccuracy"] = self.vAccuracy
        dict["modeDetected"] = self.modeDetected
        dict["accelerationX"] = self.accelerationX
        dict["accelerationY"] = self.accelerationY
        dict["accelerationZ"] = self.accelerationZ
        dict["modeDetected"] = self.modeDetected
        dict["pointType"] = self.pointType
        dict["timestamp"] = self.dateFromTimestampToUploadOnServer()
        return dict
    }
    
    func getCLLocation()-> CLLocation {
        let cllocation2d = CLLocationCoordinate2DMake(self.latitude, self.longitude)
        let date = Date.init(timeIntervalSinceReferenceDate: self.timestamp)
        let cllocation:CLLocation = CLLocation.init(coordinate: cllocation2d,
                                                    altitude: self.altitude,
                                                    horizontalAccuracy: self.hAccuracy,
                                                    verticalAccuracy: self.vAccuracy,
                                                    timestamp: date)
        return cllocation
        
    }
    
    func dateFromTimestampToUploadOnServer() -> String {
        let date = Date()//.init(timeIntervalSinceReferenceDate: self.timestamp) //Not sure what is this, but it gives 2050...
        print("date = \(date)")
        return date.toString(format: .isoDateTimeSec)
    }
}

