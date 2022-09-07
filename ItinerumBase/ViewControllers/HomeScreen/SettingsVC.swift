//
//  ViewController.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/17/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class SettingsVC: BaseVC {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var locationRecordingSwitch: UISwitch!
    
    @IBOutlet weak var syncLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.isLocationRecordingEnabled == true {
            self.locationRecordingSwitch.isOn = true
        }
        else {
            self.locationRecordingSwitch.isOn = false
        }
        let lastSync = UserDefaults.standard.string(forKey: "prompt.lastsynctimestamp") ?? ""
        if (lastSync == "")
        {
            syncLabel.text = "Aucune synchronisation" //TODO: Localize
        }
        else
        {
            syncLabel.text = lastSync //TODO: Localize
        }

        
    }
    
    
    @IBAction func manualSyncTouch(_ sender: Any) {
        APP_DELEGATE?.updateLocationOnTheServer()
    }
    
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchButtonAction(_ sender: Any) {
        if self.locationRecordingSwitch.isOn {
            
            let actionSheetController: UIAlertController = UIAlertController(title: LocalizeString.resume_recording, message: LocalizeString.Are_you_sur_for_resume_recording, preferredStyle: .alert)
            let yesAction: UIAlertAction = UIAlertAction(title: LocalizeString.yes, style: .default) {[unowned self] action -> Void in
                let _ = self
                UserDefaults.isLocationRecordingEnabled = true
                self.locationRecordingSwitch.isOn = true
                EfficientLocationManager.shared.startRecording()
            }
            let noAction: UIAlertAction = UIAlertAction(title: LocalizeString.no, style: .default) {[unowned self] action -> Void in
                let _ = self
                UserDefaults.isLocationRecordingEnabled = false
                self.locationRecordingSwitch.isOn = false
                EfficientLocationManager.shared.stopRecording()

            }
            actionSheetController.addAction(yesAction)
            actionSheetController.addAction(noAction)
            self.present(actionSheetController, animated: true, completion: nil)
        }
        else {
            let actionSheetController: UIAlertController = UIAlertController(title: LocalizeString.pause_recording, message: LocalizeString.Are_you_sur_for_pause_recording, preferredStyle: .alert)
            let yesAction: UIAlertAction = UIAlertAction(title: LocalizeString.yes, style: .default) {[unowned self] action -> Void in
                let _ = self
                UserDefaults.isLocationRecordingEnabled = false
                self.locationRecordingSwitch.isOn = false
                EfficientLocationManager.shared.stopRecording()

            }
            let noAction: UIAlertAction = UIAlertAction(title: LocalizeString.no, style: .default) {[unowned self] action -> Void in
                let _ = self
                UserDefaults.isLocationRecordingEnabled = true
                self.locationRecordingSwitch.isOn = true
                EfficientLocationManager.shared.startRecording()
            }
            
            actionSheetController.addAction(yesAction)
            actionSheetController.addAction(noAction)
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
