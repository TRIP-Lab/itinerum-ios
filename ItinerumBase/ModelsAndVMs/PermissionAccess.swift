//
//  PermissionAccess.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/27/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class PermissionAccess: NSObject {
    var permissionAccessName:String = ""
    var isPermissionGranted:Bool = false
    
    override init() {
        super.init()
    }
    
    init(accessName:String, isGranted:Bool) {
        self.permissionAccessName = accessName
        self.isPermissionGranted = isGranted
    }
}
