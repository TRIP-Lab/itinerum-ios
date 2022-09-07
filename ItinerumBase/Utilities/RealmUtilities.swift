//
//  RealmUtilities.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/22/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class RealmDataManager {
    
    static func configure() {
        // For now, just drop the database
        var config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        config.deleteRealmIfMigrationNeeded = true
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try! Realm()
    }
}

class RealmUtilities: NSObject {
    
    //location information operation
    static func getLocationInfo() -> [LocationInfo] {
        let realm = try! Realm()
        var locationArray = [LocationInfo]()
        let locList = realm.objects(LocationInfo.self)
        if locList.count > 0 {
            for locModel in locList {
                locationArray.append(LocationInfo.init(copy: locModel))
            }
        }
        
        return locationArray
    }
    
    static func getPendingLocations() -> [LocationInfo] {
        let realm = try! Realm()
        var locationArray = [LocationInfo]()
        let locList = realm.objects(LocationInfo.self).filter("isSync == false")
        if locList.count > 0 {
            for locModel in locList {
                locationArray.append(LocationInfo.init(copy: locModel))
            }
        }
        
        return locationArray
    }
    
    static func getDateWiseLocation(dateType:DateType, startDate:Date? = nil, endDate:Date? = nil)-> [LocationInfo] {
        switch dateType {
        case .today:
            let startDate = Utility.todayStartDate()?.timeIntervalSince1970
            let endDate = Date().timeIntervalSince1970

            let realm = try! Realm()
            var locationArray = [LocationInfo]()
            let locList = realm.objects(LocationInfo.self).filter("timestamp >= \(Double(startDate!)) && timestamp <= \(Double(endDate))")
            if locList.count > 0 {
                for locModel in locList {
                    locationArray.append(LocationInfo.init(copy: locModel))
                }
            }
            
            return locationArray
            
        case .yesterday:
            
            let startDate = Utility.yesterdayStartDate()?.timeIntervalSince1970
            let endDate = Date().timeIntervalSince1970
            
            let realm = try! Realm()
            var locationArray = [LocationInfo]()
            let locList = realm.objects(LocationInfo.self).filter("timestamp >= \(Double(startDate!)) && timestamp <= \(Double(endDate))")
            if locList.count > 0 {
                for locModel in locList {
                    locationArray.append(LocationInfo.init(copy: locModel))
                }
            }
            
            return locationArray

        case .lastSevenDays:
            break

        case .customDays:
            guard startDate != nil, endDate != nil else {
                return [LocationInfo]()
            }
            
            let startDate = startDate?.timeIntervalSince1970
            let endDate = endDate?.timeIntervalSince1970
            
            let realm = try! Realm()
            var locationArray = [LocationInfo]()
            let locList = realm.objects(LocationInfo.self).filter("timestamp >= \(Double(startDate!)) && timestamp <= \(Double(endDate!))")
            if locList.count > 0 {
                for locModel in locList {
                    locationArray.append(LocationInfo.init(copy: locModel))
                }
            }
            
            return locationArray
        case .allDay:
            return self.getLocationInfo()
        }
        
        return [LocationInfo]()
    }
    
    static func getPendingCompletedPromptInfo() -> [TripModel] {
        let realm = try! Realm()
        var tripArray = [TripModel]()
        let tripList = realm.objects(TripModel.self).filter("isSync == false && isCancelledPrompt == false")
        if tripList.count > 0 {
            for tripModel in tripList {
                tripArray.append(TripModel.init(copy: tripModel))
            }
        }
        
        return tripArray
    }
    
    static func getAllCompletedPromptInfo() -> [TripModel] {
        let realm = try! Realm()
        var tripArray = [TripModel]()
        let tripList = realm.objects(TripModel.self).filter("isCancelledPrompt == false")
        if tripList.count > 0 {
            for tripModel in tripList {
                tripArray.append(TripModel.init(copy: tripModel))
            }
        }
        
        return tripArray
    }
    
    static func getPendingCancelledPromptInfo() -> [TripModel] {
        let realm = try! Realm()
        var tripArray = [TripModel]()
        let tripList = realm.objects(TripModel.self).filter("isSync == false && isCancelledPrompt == true")
        if tripList.count > 0 {
            for tripModel in tripList {
                tripArray.append(TripModel.init(copy: tripModel))
            }
        }
        
        return tripArray
    }
    
    static func saveLocationInfo(locationInfo: LocationInfo) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(locationInfo, update: .all)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: locationNotification), object: nil, userInfo: nil)
        }
    }
    
    static func saveLocationInfo(locationInfoArray: [LocationInfo]) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(locationInfoArray, update: .all)
        }
    }
    
    static func saveTripInfo(tripInfo: TripModel) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(tripInfo, update: .all)
        }
    }
    
    static func getTripInfo() -> [TripModel] {
        let realm = try! Realm()
        var tripArray = [TripModel]()
        let tripList = realm.objects(TripModel.self)
        if tripList.count > 0 {
            for tripModel in tripList {
                tripArray.append(TripModel.init(copy: tripModel))
            }
        }
        
        return tripArray
    }
    
    static func getLastLocationFromDB() -> LocationInfo? {
        let realm = try! Realm()
        let locList = realm.objects(LocationInfo.self)
        if locList.count > 0 {
            return locList.last
        }
        
        return nil
    }
    
    static func clearAllData() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
}
