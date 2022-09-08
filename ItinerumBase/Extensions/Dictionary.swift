
import Foundation

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any
{
    func stringValue(key: Key) -> String
    {
        var stringValue = ""
        let val = self[key]
        switch (val) {
        case is String :
            stringValue = val as? String ?? stringValue
            break
        case is NSNumber :
            if let num = val as? NSNumber {
                stringValue = num.stringValue
            }
            break
        case is Bool :
            stringValue = (val as? Bool).map { String($0) } ?? stringValue
            break
        //case is NSNull :
        //    break
        default: break
            
        }
        
        return stringValue
    }
    
    func numberValue(key: Key) -> NSNumber {
        var numberValue = NSNumber(value: 0)
        let val = self[key]
        switch (val) {
        case is NSNumber :
            numberValue = val as? NSNumber ?? numberValue
            break
        case is String :
            let decimal = NSDecimalNumber(string: val as? String)
            if decimal != NSDecimalNumber.notANumber {
                numberValue = decimal
            }
            break
        case is Bool :
            numberValue = NSNumber(value: val as? Bool ?? false)
            break
        default: break
        }
        
        return numberValue
    }
    
    func dictionaryValue(key: Key) -> [String:Any]
    {
        if let val = self[key]
        {
            if val is [String:Any] || val is NSDictionary || val is Dictionary
            {
                return (val as! [String : Any])
            }
            
            if val is NSNumber || val is String
            {
                return [String:Any]()
            }
            
            if val is NSNull {
                return [String:Any]()
            }
        }
        
        return [String:Any]()
    }
    
    func dictionary(key: Key) -> [String:Any]?
    {
        if let val = self[key]
        {
            if val is [String:Any] || val is NSDictionary || val is Dictionary
            {
                return val as? [String : Any]
            }

            if val is NSNumber || val is String
            {
                return nil
            }
            
            if val is NSNull {
                return nil
            }
        }
        
        return nil
    }
    
    func arrayOfDictionary(key: Key) -> [[String:Any]]
    {
        if let val = self[key]
        {
            if ((val is [[String:Any]] ) || (val is NSArray) || (val is Array<[String:Any]>))
            {
                return val as! [[String:Any]]
            }
            
            if val is NSNumber || val is String
            {
                return [[String:Any]]()
            }
            
            if val is NSNull {
                return [[String:Any]]()
            }
        }
        
        return [[String:Any]]()
    }
}
