//
//  QuestionClient.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/11/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class QuestionClient: NSObject {

    typealias CompletionHandler = ([Question], NetworkError?) -> Void
    typealias updateCompletionHandler = (NetworkError?) -> Void

    static func createUser(completionHandler: @escaping CompletionHandler) {
        
        let language = Bundle.main.preferredLocalizations.first ?? "en"

        if let result = UserDefaults.saveCreateUserDynamicQuestion {
            
            var response = NetworkResponse()
            response.result = result
            if response.language == language {
                
                var question:[Question] = [Question]()
                let allQuestions = response.surveyAllQuestions
                for ques in allQuestions {
                    let quesModel = Question.init(dict: ques)
                    if quesModel.screenTypeID < 100 {
                        question.append(quesModel)
                    }
                }
                
                DispatchQueue.main.async {
                    completionHandler(question, response.error)
                }
                
                return
            }
        }
        
        //let uuid = UIDevice.current.identifierForVendor?.uuidString
        //var finalUUID = uuid?.replacingOccurrences(of: "-", with: "")
        //finalUUID = finalUUID?.replacingOccurrences(of: " ", with: "")
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //TODO: Confirm date format is good
        
        let user:[String:Any] = [
            "uuid": Utility.UUID,
            "itinerumVersion": Utility.appVersion,
            "model": UIDevice.current.localizedProductName,
            "osVersion": Utility.osVersion,
            "os": "iOS"
        ]
        
        var surveyName = ""
        if language == "en" {
            surveyName = english_survey_name
        }
        else {
            surveyName = french_survey_name
        }
        
        let param :[String:Any] = [
            "user" : user,
            "surveyName": surveyName,
            "lang" : language]
        
        let request = NetworkRequest.init(method: .post, path: APIConfiguration.createUser, param: param)
        NetworkManager.shared.performRequest(request: request) { (response) in
            var question:[Question] = [Question]()
            if (response.result != nil) {
                UserDefaults.saveCreateUserDynamicQuestion = response.result!
                let allQuestions = response.surveyAllQuestions
                for ques in allQuestions {
                    let quesModel = Question.init(dict: ques)
                    if quesModel.screenTypeID < 100 {
                        question.append(quesModel)
                    }
                }
            }
            
            DispatchQueue.main.async {
                completionHandler(question, response.error)
            }
        }
    }
    
    static func getAllPromptQuestion()->[Question] {
        
        if let result = UserDefaults.saveCreateUserDynamicQuestion {
            var question:[Question] = [Question]()
            var response = NetworkResponse()
            response.result = result
            let allQuestions = response.promptQuestions
            for ques in allQuestions {
                let quesModel = Question.init(promptQuesDict: ques)
                question.append(quesModel)
            }
            
            return question
        }
        
        return [Question]()
    }
    
    static func updateSurveyDataToServer(questionArray:[Question], completionHandler: @escaping updateCompletionHandler) {
        
        var surveyDict:[String:Any] = [String:Any]()
        
        for question in questionArray {
            
            switch question.screenTypeID {
            case ScreenType.singleSelection.rawValue:
                surveyDict[question.columnName] = question.answer.localized()
                break
            case ScreenType.multipleSelection.rawValue:
                let ansArray = question.answer.components(separatedBy: ",")
                surveyDict[question.columnName] = ansArray
                break
            case ScreenType.numberInput.rawValue:
                surveyDict[question.columnName] = question.answer
                break
            case ScreenType.locationInput.rawValue:
                let ansArray = question.answer.components(separatedBy: ",")
                surveyDict[question.columnName] =  ["latitude":ansArray.first ?? "0.0","longitude":ansArray.last ?? "0.0"]
                break
            case ScreenType.textboxInput.rawValue:
                surveyDict[question.columnName] = question.answer
                break
            case ScreenType.invalid.rawValue:
                break
            default:
                break
            }
        }
        
        var param:[String:Any] = [String:Any]()
        param["survey"] = surveyDict
        param["uuid"] = Utility.UUID

        let request = NetworkRequest.init(method: .post, path: APIConfiguration.update, param: param)
        NetworkManager.shared.performRequest(request: request) { (response) in
            
            DispatchQueue.main.async {
                completionHandler(response.error)
            }
        }
    }
    
    static func updateLocationDataToServer(completionHandler: @escaping updateCompletionHandler) {
        var mainParamDict:[String:Any] = [String:Any]()
        let locationArray = RealmUtilities.getPendingLocations()
        var locationDictArray:[[String:Any]] = [[String:Any]]()
        
        for locInfo in locationArray {
            locInfo.isSync = true
            locationDictArray.append(locInfo.getDictionary())
        }
        
        mainParamDict["uuid"] =  Utility.UUID
        mainParamDict["coordinates"] =  locationDictArray

        let successTripArray = RealmUtilities.getPendingCompletedPromptInfo()
        
        var successTripDictArray:[[String:Any]] = [[String:Any]]()
        for tripInfo in successTripArray {
            if tripInfo.answer1.isEmpty == false {
                let tripInfoDict1 =  tripInfo.getDictionary(isFirst: true)
                successTripDictArray.append(tripInfoDict1)
            }
            
            if tripInfo.answer2.isEmpty == false {
                let tripInfoDict2 = tripInfo.getDictionary(isFirst: false)
                successTripDictArray.append(tripInfoDict2)
            }
         }
        
        mainParamDict["prompts"] =  successTripDictArray


        let cancelTripArray = RealmUtilities.getPendingCancelledPromptInfo()
        
        var cancelTripDictArray:[[String:Any]] = [[String:Any]]()
        for tripInfo in cancelTripArray {
            
            let tripInfoDict1 =  tripInfo.getDictionary(isFirst: true)
            cancelTripDictArray.append(tripInfoDict1)
            
        }
        
        mainParamDict["cancelledPrompts"] =  cancelTripDictArray
        
        print("mainParamDict = \(mainParamDict)")
        let request = NetworkRequest.init(method: .post, path: APIConfiguration.update, param: mainParamDict)
        NetworkManager.shared.performRequest(request: request) { (response) in
            
            if response.error == nil {
                for locInfo in locationArray {
                    locInfo.isSync = true
                    RealmUtilities.saveLocationInfo(locationInfo: locInfo)
                }
                
                for tripInfo in successTripArray {
                    tripInfo.isSync = true
                    RealmUtilities.saveTripInfo(tripInfo: tripInfo)
                }
                
                for tripInfo in cancelTripArray {
                    tripInfo.isSync = true
                    RealmUtilities.saveTripInfo(tripInfo: tripInfo)
                }
            }
            
            DispatchQueue.main.async {
                completionHandler(response.error)
            }
        }

    }
}


