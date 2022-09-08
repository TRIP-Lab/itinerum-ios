//
//  ReachabilityManager.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/13/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import Reachability

public class ReachabilityManager {
    public static var sharedInstance: Reachability = {
        let manager = try! Reachability()
        // Add additional setup for the manager
        return manager
    }()
    
    static func isOnline() -> Bool {
        if ReachabilityManager.sharedInstance.connection == .none {
            return false
        }
        else {
            return true
        }
       // return ReachabilityManager.sharedInstance.isReachable
    }
}

