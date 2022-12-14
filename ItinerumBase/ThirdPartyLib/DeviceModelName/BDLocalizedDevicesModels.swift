//
//  UIDevice+BDLocalizedDevicesModels.swift
//  BDLocalizedDevicesModels
//
//  Created by Benoit Deldicque on 26/06/2018.
//  Copyright © 2018 Benoit Deldicque. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    /// The product name of the device.
    public var productName: String {
        get {
            // Retrieve english bundle.
            let enBundle = Bundle(path: (self.frameworkBundle.path(forResource: "en", ofType: "lproj"))!)

            return NSLocalizedString(self.deviceTypeIdentifier, tableName: "DeviceModel", bundle: enBundle!, value: self.deviceTypeIdentifier, comment: "")
        }
    }

    /// The product name of the device as a localized string.
    public var localizedProductName: String {
        get {
            return NSLocalizedString(self.deviceTypeIdentifier, tableName: "DeviceModel", bundle: self.frameworkBundle, value: self.deviceTypeIdentifier, comment: "")
        }
    }

    // MARK: -
    private var deviceTypeIdentifier: String {
        get {
            // Check if device is a simulator to get the right machine identifier.
            if let machine = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                return machine
            } else {
                var size: Int = 0
                sysctlbyname("hw.machine", nil, &size, nil, 0)
                var machine = [CChar](repeating: 0, count: size)
                sysctlbyname("hw.machine", &machine, &size, nil, 0)

                return String(cString: machine)
            }
        }
    }

    private var frameworkBundle: Bundle {
        get {
            return Bundle(identifier: "Concordia.MonResoMobilite")!
        }
    }
    
    //return Bundle(identifier: "com.Itinerum.ItinerumBase")!

}
