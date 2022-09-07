//
//  String.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/28/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
extension String {
    
    func localized(bundle: Bundle = .main, tableName: String = "Localization") -> String {
        //return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
        return NSLocalizedString(self, tableName: tableName, value: "\(self)", comment: "") //by cm
    }
    
    func isValidEmail() -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    static func convertJsonToDictionary(text: String?) -> [String: Any]? {
        
        guard let jsonString = text, jsonString != "" else {
            return nil
        }
        
        if let data = jsonString.data(using: .utf8) {
            do  {
                if let dict =  try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    return dict
                }
                
                return nil
            }
            catch {
                print(error.localizedDescription)
                return nil
            }
        }
        
        return nil
    }
    
    static func convertDictionaryToJson(dict:[String: Any]?) -> String?
    {
        guard dict != nil else {
            return nil
        }
        
        do {
            //Convert to Data
            let jsonData = try JSONSerialization.data(withJSONObject: dict ?? "", options: JSONSerialization.WritingOptions.prettyPrinted)
            
            //Convert back to string. Usually only do this for debugging
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                print(JSONString)
                return JSONString
            }
            
            return nil
            //In production, you usually want to try and cast as the root data structure. Here we are casting as a dictionary. If the root object is an array cast as [Any].
            //var json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
        } catch {
            print(error)
            return nil
        }
    }
}
extension Double {
    func toString() -> String {
        return String(describing: self)
    }
}

