//
//  EditTripCell.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/22/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class EditTripDateTimeCell: UITableViewCell {
    @IBOutlet var dateLabel:UILabel!
    @IBOutlet weak var editButton: UIButton!
    var tripModel:TripModel = TripModel()
    var isDateClicked:Bool = true
    var datePicker:UIDatePicker!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
    }
    
   @IBOutlet weak var textField:UITextField! // to show input view temp text field used
    
    @IBAction func editButtonAction(_ sender: Any) {
        self.pickUpDate()
        self.textField.becomeFirstResponder()

    }
    
    func setupDateTimeUI(isDate:Bool,trip:TripModel ) {
        self.isDateClicked = isDate
        self.tripModel = trip
    
        if isDate {
            self.editButton.setTitle(LocalizeString.edit_arrival_date, for: .normal)
            self.dateLabel.text = self.tripModel.getDateString
        }
        else {
            self.editButton.setTitle(LocalizeString.edit_arrival_time, for: .normal)
            self.dateLabel.text = self.tripModel.getTimeString
        }
    }
    
    //MARK:- textFiled Delegate
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        self.pickUpDate(self.textField)
//    }
    
    //MARK:- Function of datePicker
    func pickUpDate(){
        
        // DatePicker
        datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 216))
        datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = self.isDateClicked == true ? UIDatePickerMode.date :UIDatePickerMode.time
        datePicker.minimumDate = Date()
        textField.inputView = datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        toolBar.tintColor = UIColor.appRedColor
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: LocalizeString.done, style: .plain, target: self, action: #selector(EditTripDateTimeCell.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: LocalizeString.cancel, style: .plain, target: self, action: #selector(EditTripDateTimeCell.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    
    // MARK:- Button Done and Cancel
    @objc func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .none
        //textField_Date.text = dateFormatter1.string(from: datePicker.date)
        if isDateClicked {
            let date = Date.updateDate(inDate: self.tripModel.displayedAtDate, fromDate: datePicker.date)
            self.tripModel.displayedAtDate = date
            self.dateLabel.text = self.tripModel.getDateString
        }
        else {
            
            let date = Date.updateTime(inDate: self.tripModel.displayedAtDate, fromDate: datePicker.date)
            self.tripModel.displayedAtDate = date
            let dateStr = self.tripModel.getTimeString
            self.dateLabel.text = dateStr
        }
        
        textField.resignFirstResponder()
    }
    
    @objc func cancelClick() {
        textField.resignFirstResponder()
    }
}

