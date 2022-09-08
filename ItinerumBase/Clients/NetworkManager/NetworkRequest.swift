//
//  NetworkRequest.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/25/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//



import Foundation
import MobileCoreServices

public enum HTTPMethod : String
{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

class NetworkRequest {
    private var urlPath: String
    private var httpMethodType: HTTPMethod
    
    // Default false
    var containsBaseUrl = false
    
    // Default true
    var isRequiredHeader = true
    
    // Default start with 1 for track retry count
    var requestCount = 1
    
    // Can be optional and can modify during the process
    var parameters: [String:Any] = [String:Any]()
    
    init(method: HTTPMethod, path: String, param:[String:Any] = [String:Any]()) {
        self.httpMethodType = method
        self.urlPath = path
        self.parameters = param
    }
    
    init (method: HTTPMethod, path: String) {
        self.httpMethodType = method
        self.urlPath = path
    }
    
    
    //MARK: Public methods
    var url:String {
        return (containsBaseUrl) ? urlPath : (APIConfiguration.baseURL + urlPath)
    }
    
    var methodName:String {
        return httpMethodType.rawValue
    }
    
    func getRequest() -> URLRequest {
        var request = URLRequest.init(url: requestUrl)
        if isRequiredHeader {
            setCommonHeader(&request)
        }
        
        if httpMethodType != .get {
            if let jsonData = try? JSONSerialization.data(withJSONObject: self.parameters, options:[]) {
                request.httpBody = jsonData
            }
        }
        
        return request
    }
    
    //MARK: Private methods
    private var requestUrl: URL {
        if httpMethodType == .get {
            return self.queryUrl
        }
        return  URL(string:url)!
    }
    
    private var queryUrl: URL {
        get {
            var urlComponents = URLComponents(string: url)
            urlComponents?.queryItems = parameters.map { (arg) -> URLQueryItem in
                var (key, value) = arg
                //if ((value as? Int) != nil) {
                value = "\(value)"
                //}
                return URLQueryItem(name: key, value: value as? String)
            }
            return (urlComponents?.url)!
        }
    }
    
    private func setCommonHeader(_ request: inout URLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = httpMethodType.rawValue
        request.timeoutInterval = 30
    }
}


