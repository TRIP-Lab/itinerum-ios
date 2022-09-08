//
//  NetworkConfiguration.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/25/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

struct APIConfiguration {
    static var baseURL = "https://api.itinerum.ca/mobile/v1/"
    static let createUser = "create"
    static let update = "update"
}

struct ServerResponse {
    struct key {
        static let result = "result"
    }
    
    struct value {
        static let success = "SUCCESS"
        static let fail = "FAIL"
    }
}

struct ServerRequest {
    struct key {
        static let page = ""
    }
}
