//
//  PromptModel.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 9/5/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import RealmSwift

//"uuid": "c1d15413-b33d-4aaa-bf84-762517a3284b",
//"displayedAt": "2017-04-27T08:37:03-04:00",
//"cancelledAt": "2017-04-27T08:37:03-04:00",
//"longitude": -73.5769640073,
//"latitude": 45.4868670481,

//class PromptModel: Object {
//    @objc dynamic var uuid:String = ""
//    @objc dynamic var displayedAt:String = ""
//    @objc dynamic var cancelledAt:String = ""
//    @objc dynamic var longitude:Double = 0.0
//    @objc dynamic var latitude:Double = 0.0
//    @objc dynamic var isSync:Bool = false
//    @objc dynamic var primaryKeyValue: String = Date().timeIntervalSince1970.toString()
//    @objc override static func primaryKey() -> String {
//        return "primaryKeyValue"
//    }
//    
//    convenience init(copy: PromptModel) {
//        self.init()
//        
//        self.uuid = copy.uuid
//        self.displayedAt = copy.displayedAt
//        self.cancelledAt = copy.cancelledAt
//        self.latitude = copy.latitude
//        self.longitude = copy.longitude
//        self.isSync = copy.isSync
//        self.primaryKeyValue = copy.primaryKeyValue
//    }
//    
//    func getDictionary(isFirst:Bool) -> [String:Any]  {
//        var dict:[String:Any] = [String:Any]()
//        dict["uuid"] =  self.uuid
//        dict["displayedAt"] = self.displayedAt
//        dict["cancelledAt"] = self.cancelledAt
//        dict["longitude"] = self.longitude
//        dict["latitude"] = self.latitude
//        return dict
//    }
//}
