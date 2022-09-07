//
//  SystemAccessVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/26/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class SystemAccessVC: UIViewController {
    var permissionList:[PermissionAccess] = [PermissionAccess]()
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var nextButton: CustomButton!
    var locationService:LocationService = LocationService()
    var coreMotionManager:CoreMotionManager = CoreMotionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        self.permissionList = PredefinedData.getPermissionAccessArray()
        self.updateUI()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    fileprivate func updateUI() {
        var allDone:Bool = true
        for permission in permissionList {
            if permission.isPermissionGranted == false {
                allDone = false
                break
            }
        }
        
        if allDone == true {
            self.nextButton.isEnable = true
        }
        else {
            self.nextButton.isEnable = false
        }
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
    }
}

extension SystemAccessVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 :permissionList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? UITableViewAutomaticDimension : UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.updateUI()
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
            return cell!
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SystemAccessCell") as! SystemAccessCell
            cell.setupCellData(permissionData: permissionList[indexPath.row])
            return cell
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 1 {
//            return 10
//        }
//        
//        return 0.1
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let permissionAction = permissionList[indexPath.row]

            switch (indexPath.row) {
            case 0: //TODO:remove magic number
                let systemAccessAlertView = SystemAccessAlertView.init(frame: self.view.bounds)
                self.view.addSubview(systemAccessAlertView)
                systemAccessAlertView.agreedButtonActionBlock = { [unowned self] (isAgree) in
                    let _ = self
                    permissionAction.isPermissionGranted = isAgree
                    systemAccessAlertView.removeFromSuperview()
                    tableView.reloadData()
                }
                break
                
            case 1:
                PushNotificationManager.shared.isApproved {[weak self] (isGranted) in
                    guard let weakSelf = self else {return}
                    permissionAction.isPermissionGranted = isGranted
                    if isGranted == false {
                        PushNotificationManager.notificationPermissionAlert()
                    }
                    
                    weakSelf.tableView.reloadData()
                }
                break
                
            case 2:
                if LocationService.isLocationServiceEnabled() == .notDetermine {
                    locationService.askPermissionForLocationAccess()
                }
                else if LocationService.isLocationServiceEnabled() == .disabled {
                    LocationService.showLocationPermissionAlert()
                    permissionAction.isPermissionGranted = false
                }
                else {
                    permissionAction.isPermissionGranted = true
                    locationService.startUpdatingLocation()
                }
                
                locationService.systemAlertPermissionStatus = { [unowned self] (permissionStatus) in
                    let _ = self
                    if (permissionStatus == .notDetermine) || (permissionStatus == .disabled) {
                        permissionAction.isPermissionGranted = false
                    }
                    else {
                        permissionAction.isPermissionGranted = true
                        self.locationService.startUpdatingLocation()
                        tableView.reloadData()

                    }
                }
                
                tableView.reloadData()
                
            case 3:
                if self.coreMotionManager.isCoreMotionEnabled() == ServiceStatus.notDetermine {
                    self.coreMotionManager.askForCoreMotionPermission()
                    permissionAction.isPermissionGranted = false
                }
                else if coreMotionManager.isCoreMotionEnabled() == .disabled {
                    CoreMotionManager.showActivityPermissionAlert()
                    permissionAction.isPermissionGranted = false
                }
                else {
                    permissionAction.isPermissionGranted = true
                }
                
                tableView.reloadData()

                break
            default: break
            }
        }
    }
}











