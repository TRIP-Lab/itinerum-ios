//
//  AlertVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 9/18/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class AlertVC: UIViewController {
    
    @IBOutlet weak var alertBackView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var yesButton: CustomButton!
    @IBOutlet weak var noButton: CustomButton!
    var location:CLLocation = CLLocation()
    var promptStartTime:Date?
    
    var titleTxt : String = ""
    var msgTxt : String = ""
    var yesButtonTxt : String = ""
    var noButtonTxt : String = ""
    
    typealias ButtonHandlerAlias = () -> Void
    var yesButtonActionBlock:ButtonHandlerAlias? = nil
    var noButtonActionBlock:ButtonHandlerAlias? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.alertBackView.addAppBasedShadow()
        self.titleLabel.text = titleTxt
        self.subtitleLbl.text = msgTxt
        self.yesButton.setTitle(yesButtonTxt, for: .normal)
        self.noButton.setTitle(noButtonTxt, for: .normal)
        
        if promptStartTime == nil {
            self.promptStartTime = Date()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func yesButtonAction(_ sender: Any) {
        if let block = self.yesButtonActionBlock {
            block()
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func noButtonAction(_ sender: Any) {
        if let block = self.noButtonActionBlock {
            block()
        }
        self.dismiss(animated: false, completion: nil)
    }
}

