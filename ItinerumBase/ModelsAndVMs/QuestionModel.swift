//
//  QuestionModel.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/29/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation

class Question: NSObject {
    var questionTitle:String = ""
    var question:String =  ""
    var optionsArray:[String] = [String]()
    var answer:String = ""
    var columnName:String = ""
    var screenTypeID:Int = 0
    var answerRequired:Bool = true
    
    convenience init(dict:[String:Any]) {
        self.init()
        self.questionTitle = dict.stringValue(key: "colName")
        self.question = dict.stringValue(key: "prompt")
        self.screenTypeID = dict.numberValue(key: "id").intValue
        self.columnName = dict.stringValue(key: "colName")
        self.answerRequired = dict.numberValue(key: "answerRequired").boolValue

        let quesDict = dict.dictionaryValue(key: "fields")
        if let array = quesDict["choices"] {
            self.optionsArray = (array as! [String])
        }
    }
    
    convenience init(promptQuesDict:[String:Any]) {
        self.init()
        self.questionTitle = promptQuesDict.stringValue(key: "colName")
        self.question = promptQuesDict.stringValue(key: "prompt")
        self.screenTypeID = promptQuesDict.numberValue(key: "id").intValue
        self.columnName = promptQuesDict.stringValue(key: "colName")
        self.answerRequired = promptQuesDict.numberValue(key: "answerRequired").boolValue

        if let array = promptQuesDict["choices"] {
            self.optionsArray = (array as! [String])
        }
    }
}
