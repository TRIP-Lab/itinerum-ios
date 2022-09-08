//
//  UserDefault.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/13/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation

extension UserDefaults {
    class var isUserCreatedSuccessfully: Bool {
        get {
            return self.standard.bool(forKey: "isUserCreatedSuccessfully")
        }
        set {
            self.standard.set(newValue, forKey: "isUserCreatedSuccessfully")
            self.standard.synchronize()
        }
    }
    
    class var isUserWantInfiniteTripValidation: Bool? {
        get {
            if let value = self.standard.value(forKey: "isUserWantInfiniteTripValidation") {
                return (value as! Bool)
            }
            else {
                return nil
            }
        }
        set {
            self.standard.set(newValue, forKey: "isUserWantInfiniteTripValidation")
            self.standard.synchronize()
        }
    }
    
    class var isLocationRecordingEnabled: Bool {
        get {
            return self.standard.bool(forKey: "isLocationRecordingEnabled")

            /*if let flage = self.standard.object(forKey: "isLocationRecordingEnabled") {
                return flage as! Bool
            }
            else {
                self.standard.set(true, forKey: "isLocationRecordingEnabled")
                self.standard.synchronize()
                return self.standard.bool(forKey: "isLocationRecordingEnabled")
            }*/
            
        }
        set {
            self.standard.set(newValue, forKey: "isLocationRecordingEnabled")
            self.standard.synchronize()
        }
    }
    
    class var getTripValidatedCount: Int {
        get {
            return self.standard.integer(forKey: "tripValidated")
        }
    }
    
    class func updateTripValidation() {
        var count = self.standard.integer(forKey: "tripValidated")
        count = count + 1
        self.standard.set(count, forKey: "tripValidated")
        self.standard.synchronize()
    }
    
    class var saveCreateUserDynamicQuestion:[String:Any]? {
        get {
            let jsonString = self.standard.string(forKey: "saveCreateUserDynamicQuestion")
            let dict = String.convertJsonToDictionary(text: jsonString)
            return dict
        }
        set {
            let jsonString = String.convertDictionaryToJson(dict: newValue)
            UserDefaults.standard.set(jsonString, forKey: "saveCreateUserDynamicQuestion")
            UserDefaults.standard.synchronize()
        }
    }
    
    func saveLastPromptedNotificationLocationAndTime(lat:Double?, long:Double?) {
        guard  lat != nil, long != nil else {
            UserDefaults.standard.removeObject(forKey: "saveLast_lat")
            UserDefaults.standard.removeObject(forKey: "saveLast_long")
            return
        }
        
        UserDefaults.standard.set(lat, forKey: "saveLast_lat")
        UserDefaults.standard.set(long, forKey: "saveLast_long")
        UserDefaults.standard.set(Date.init().toString(format: .isoDateTimeSec), forKey: "saveLast_time")
        UserDefaults.standard.synchronize()
    }
    
    func getLastPromptedNotificationLocationAndTime() -> (lat:Double, long:Double, date:Date)? {
        
        let lat = UserDefaults.standard.double(forKey: "saveLast_lat")
        let long = UserDefaults.standard.double(forKey: "saveLast_long")
        
        var startDate:Date = Date()
        if let time = UserDefaults.standard.string(forKey: "saveLast_time") {
            startDate = Date.init(fromString: time, format: .isoDateTimeSec) ?? Date()
        }
       
        guard  lat != 0.0, long != 0.0 else {
            return nil
        }
        
        return (lat, long, startDate) 
    }
}
