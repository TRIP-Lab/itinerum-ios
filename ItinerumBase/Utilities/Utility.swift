//
//  Utility.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/13/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit
import SVProgressHUD

class Utility {

    static var appVersion: String {
        if let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "\(versionString)"
        }
        return "0.0.0"
    }
    
    static var osVersion: String {
        return UIDevice.current.systemVersion
        
    }
    
    static var UUID:String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    static var isSurveyComplete:Bool {
        
        let toDate = Date.init(fromString: remainingDaysStr, format: .isoDateTime)
        print("Last date : \(toDate!)")
        let diffInDays = Calendar.current.dateComponents([.day], from: Date(), to: toDate!).day
        print("remaining days  : \(diffInDays!)")
        if (diffInDays ?? 0 ) > 0 {
            return false
        }
        
        return true
    }
    
    static func showAlertWithDisappearingTitle(_ title:String?) {
        guard title != nil, title != "" else {
            return
        }
        
        let topWindow = UIWindow(frame: UIScreen.main.bounds)
        topWindow.rootViewController = UIViewController()
        topWindow.windowLevel = UIWindowLevelAlert + 1
        let alert = UIAlertController(title: "", message: title, preferredStyle: .alert)
        topWindow.makeKeyAndVisible()
        topWindow.rootViewController?.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    static func showLoader() {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
    }
    
    static func hideLoader() {
        SVProgressHUD.dismiss()
    }

    static func topMostViewController() -> UIViewController? {
        let topWindow = UIWindow(frame: UIScreen.main.bounds)
        topWindow.rootViewController = UIViewController()
        topWindow.windowLevel = UIWindowLevelAlert + 1
        topWindow.makeKeyAndVisible()
        return topWindow.rootViewController
    }
    
    static func todayStartDate() -> Date? {
        let calendar = Calendar.current
        var components: DateComponents = calendar.dateComponents([.year, .day, .month], from: Date())
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)
    }
    
    static func yesterdayStartDate() -> Date? {
        //var sevenDaysAgo = self.todayStartDate()?.addingTimeInterval(-7 * 24 * 60 * 60)
        //print("7 days ago: \(sevenDaysAgo?.toString())")

        let date = self.todayStartDate()?.addingTimeInterval(-1 * 24 * 60 * 60)
        return date
    }
}

