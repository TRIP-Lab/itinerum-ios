//
//  TripModel.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/21/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit
import RealmSwift

//"prompts": [
//{
//"uuid": "0dd86866-9e00-474f-a24b-103431254726",
//"displayedAt": "2017-04-27T08:37:03-04:00",
//"recordedAt": "2017-04-27T08:37:03-04:00",
//"longitude": -73.5769640073,
//"latitude": 45.4868670481,
//"answer": "Choice 1",
//"prompt_num": 0
//}],

class TripModel: Object {
    @objc dynamic var uuid:String = NSUUID.init().uuidString
    @objc dynamic var displayedAtDate:Date = Date()
    @objc dynamic var recordedAtDate:Date = Date()
    @objc dynamic var latitude:String = ""
    @objc dynamic var longitude:String = ""
    
    @objc dynamic var answer1:String = ""
    @objc dynamic var prompt_num1:Int = 0
    
    @objc dynamic var answer2:String = ""
    @objc dynamic var prompt_num2:Int = 0

    @objc dynamic var isSync:Bool = false
    @objc dynamic var isCancelledPrompt:Bool = false

    //@objc dynamic var primaryKeyValue: String = Date().timeIntervalSince1970.toString()
    @objc override static func primaryKey() -> String {
        return "uuid"
    }

    convenience init(copy: TripModel) {
        self.init()
        
        self.uuid = copy.uuid
        self.displayedAtDate = copy.displayedAtDate
        self.recordedAtDate = copy.recordedAtDate
        self.latitude = copy.latitude
        self.longitude = copy.longitude
        self.answer1 = copy.answer1
        self.prompt_num1 = copy.prompt_num1
        self.answer2 = copy.answer2
        self.prompt_num2 = copy.prompt_num2
        self.isSync = copy.isSync
    }
    
    var getDateString:String {
         return displayedAtDate.toString(format: .custom("MM-dd-yyyy"))

    }
    
    var getTimeString:String {
//        let dateStr = self.displayedAtDate.toString(style: .short)
//        let time:String =  dateStr.components(separatedBy: ",").last ?? ""
//        return time
        
        let time = displayedAtDate.toString(format: .custom("hh:mm a"))
        return time

    }
    
    func getDictionary(isFirst:Bool) -> [String:Any]  {
        var dict:[String:Any] = [String:Any]()
        dict["uuid"] =  self.uuid
        dict["displayedAt"] = self.displayedAtDate.toString(format: .isoDateTimeSec)
        dict["recordedAt"] = self.recordedAtDate.toString(format: .isoDateTimeSec)
        dict["longitude"] = self.longitude
        dict["latitude"] = self.latitude
        dict["answer"] = isFirst == true ? self.answer1 : self.answer2
        dict["prompt_num"] = isFirst == true ? self.prompt_num1 : self.prompt_num2
        return dict
    }
}

