//
//  GooglePlace.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/8/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation

class GooglePlaces: NSObject {
    var name = ""
    var city = ""
    var state = ""
    var formattedAddress = "";
    var placeID = ""
    var placeLatitude:Double = 0.0
    var placeLongitude:Double = 0.0
    
    override init()
    {
        super.init()
    }
    
}
