//
//  NumberVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/8/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import UIKit

class NumberVC: BaseVC {
    
    @IBOutlet weak var nextButton: CustomButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var screenTitleLbl: UILabel!
    @IBOutlet weak var questionLbl: UILabel!

    var numberCount:Int = 0
    var questionModel:Question = Question()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.setTitle(LocalizeString.next, for: .normal)
        self.screenTitleLbl.text = self.questionModel.questionTitle.localized()
        self.questionLbl.text = self.questionModel.question
        self.numberLbl.text = "\(self.numberCount)"
        self.questionModel.answer = "0"
    }
    
    @IBAction func minusButtonAction(_ sender: Any) {
        
        if numberCount > 0 {
            self.nextButton.isEnable = true
        }
        else  {
            self.nextButton.isEnable = false
            
        }
        
        guard numberCount > 0 else {
            return
        }
        
        self.numberCount = self.numberCount - 1
        self.numberLbl.text = "\(self.numberCount)"
        self.questionModel.answer = "\(self.numberCount)"
    }
    
    @IBAction func plusButtonAction(_ sender: Any) {
        self.numberCount = self.numberCount + 1
        self.numberLbl.text = "\(self.numberCount)"
        self.questionModel.answer = "\(self.numberCount)"
        if numberCount > 0 {
            self.nextButton.isEnable = true
        }
        else  {
            self.nextButton.isEnable = false

        }
    }
    
    @IBAction override func backButtonAction(_ sender: Any) {
        super.backButtonAction(sender)
        self.questionModel.answer = ""
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        self.loadNextViewController()
    }
}
