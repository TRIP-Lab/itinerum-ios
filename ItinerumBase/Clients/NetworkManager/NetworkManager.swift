//
//  NetworkManager.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/25/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

public class NetworkManager: NSObject
{
    private var session:URLSession!
    
    private func dataSession() -> URLSession {
        var dataSession: URLSession?
        let defaultConfigObject:URLSessionConfiguration = URLSessionConfiguration.default
        defaultConfigObject.requestCachePolicy = .reloadIgnoringCacheData
        dataSession = URLSession(configuration:defaultConfigObject, delegate:nil, delegateQueue:OperationQueue.main)
        return dataSession!
    }
    
    static let shared: NetworkManager = {
        let instance = NetworkManager ()
        return instance
    } ()
    
    override private init() {
        super.init()
        self.session = self.dataSession()
    }
    
    func performRequest(request:NetworkRequest, success:@escaping (( _ serverResponse:NetworkResponse) -> Void))
    {
        let req:URLRequest = request.getRequest()
        let defaultSession: URLSession = self.session
        
        print("\nheader request = \(String(describing: req.allHTTPHeaderFields)))")
        print("\nmethod type = \(request.methodName) and URL = \(request.url)")
        print("\nparameters = \(request.parameters)\n")
        
        let dataTask:URLSessionDataTask = defaultSession.dataTask(with: req) { (data:Data?, res:URLResponse?, error:Error?) in
            
            var response = NetworkResponse()
            
            if let serverRes = res {
                let statusCode = (serverRes as! HTTPURLResponse).statusCode
                response.statusCode = statusCode
            }
            //response.statusCode = (res as! HTTPURLResponse).statusCode
            //print("\nstatus code = \(response.statusCode!)\n")
            if (error != nil) {
                print("\nerror = \(error!)\n")
                response.error = NetworkError.serverError(error!)
            }
            else if ((response.statusCode == 200) || (response.statusCode == 201))
            {
                let datastring = NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)
                print("Response String : \(datastring!)")
                

                if (data == nil || data?.count == 0) {
                    response.error = NetworkError.insufficientData
                }
                else {
                    do {
                        let responseDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String,Any>
                        print("\nResponse dict : \(responseDict!))")
                        if responseDict == nil {
                            response.error = NetworkError.insufficientData
                        }
                        else {
                            let status = responseDict?.stringValue(key: "")
                            if status == "" {
                                response.result = responseDict!
                            }
                            else {
                                
                                let message = responseDict?.stringValue(key: "")
                                response.error = NetworkError.serverCustomError(message: message!)
                            }
                        }
                    }
                    catch _  {
                        response.error = NetworkError.parseError
                    }
                }
            }
            else {
                response.error = NetworkError.networkLevelError(statusCode: response.statusCode!)
            }
            
            success(response)
        }
        
        dataTask.resume()
    }
}

 

