//
//  TextInputVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/14/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import UIKit

class TextInputVC: BaseVC {
    
    @IBOutlet weak var nextButton: CustomButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var screenTitleLbl: UILabel!
    @IBOutlet weak var questionLbl: UILabel!
    var questionModel:Question = Question()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.setTitle(LocalizeString.next, for: .normal)
        self.emailTextField.keyboardType = .emailAddress
        self.screenTitleLbl.text = self.questionModel.questionTitle.localized()
        self.questionLbl.text = self.questionModel.question.localized()
        
        
        if questionModel.columnName == "Email" {
            self.emailTextField.placeholder = "example@gmail.com"
            if (emailTextField.text?.isEmpty)! {
                self.nextButton.isEnable = false
            }
            else {
                self.nextButton.isEnable = true
            }
        }
        else {
           // self.emailTextField.placeholder = LocalizeString.pls_enter_your_input.localized()
            self.nextButton.isEnable = true
            self.questionModel.answer = "0000" // adding zero to show next question
            
        }
    }
    
    @IBAction override func backButtonAction(_ sender: Any) {
        super.backButtonAction(sender)
        self.questionModel.answer = ""
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        //if (self.emailTextField.text?.isEmpty)! {
        //    Utility.showAlertWithDisappearingTitle(LocalizeString.enter_email.localized())
        //}
        //else if (self.emailTextField.text?.isValidEmail() == false) {
        //    Utility.showAlertWithDisappearingTitle(LocalizeString.enter_valid_email.localized())
        //}
        //else {
            self.loadNextViewController()
        //}
    }
}

extension TextInputVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.questionModel.answer = textField.text!
        
        if questionModel.columnName == "Email" {
            if self.questionModel.answer.isEmpty {
                self.nextButton.isEnable = false
            }
            else {
                self.nextButton.isEnable = true
            }
        }
        else {
            self.nextButton.isEnable = true
            if self.questionModel.answer.isEmpty {
                self.questionModel.answer = "0000" // adding zero to show next question
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}
