//
//  NetworkResponse.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/25/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit
import Foundation

import Foundation

struct NetworkResponse {
    var result: [String:Any]?
    var error: NetworkError?
    var statusCode: Int?
    
    
    var surveyAllQuestions: [[String : Any]] {
        if let dict = result {
            let mainDict =  dict.dictionaryValue(key: "results")
            return mainDict.arrayOfDictionary(key: "survey")
        }
        
        return [[String : Any]]()
    }
    
    var promptQuestions: [[String : Any]] {
        if let dict = result {
            let mainDict =  dict.dictionaryValue(key: "results")
            let promptDict =  mainDict.dictionaryValue(key: "prompt")
            return promptDict.arrayOfDictionary(key: "prompts")
        }
        
        return [[String : Any]]()
    }
    
    var language: String {
        if let dict = result {
            let mainDict =  dict.dictionaryValue(key: "results")
            let lang =  mainDict.stringValue(key: "lang")
            return lang
        }
        
        return ""
    }
    
    var successMessage : String {
        if let dict = self.result {
            return dict.stringValue(key: "")
        }
        return ""
    }
}

enum NetworkError: Error {
    case parseError
    case insufficientData
    case invalidResponse
    case invalidCredentials
    case HostNameNotFound
    case serverError(Error)
    case serverCustomError(message:String)
    case unknownError
    case networkLevelError(statusCode:Int)
    
    func description() -> String {
        switch self {
        case .parseError:
            return "An error occurred when parsing the response!"
        case .insufficientData:
            return "CushyConstants.customErrorMessage"
        case .invalidResponse:
            return ""
        case .invalidCredentials:
            return "Unauthorized user!"
        case .HostNameNotFound:
            return "Host name not found!"
        case .serverError(let error):
            let message = error.localizedDescription
            return "A server error occurred. \(message)"
        case .serverCustomError(let message):
            return message == "" ? "" : message
        case .unknownError:
            return ""
        case .networkLevelError(let statusCode):
            switch statusCode {
            case 400:
                return "Bad Request!"
            case 401:
                return "Unauthorized"
            case 403:
                return "Forbidden!"
            case 404:
                return "Not Found!"
            case 405:
                return "Method Not Allowed"
            case 500:
                return "Internal Server Error"
            case 503:
                return "Service Unavailable"
            default:
                return ""
            }
        }
    }
}
