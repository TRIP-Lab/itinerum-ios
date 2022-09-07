//
//  FirstScreenVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/19/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class FirstScreenVC: BaseVC {

    @IBOutlet var moreThan18YearBGView:UIView!
    @IBOutlet var checkBoxButton:UIButton!
    @IBOutlet var startButton:CustomButton!
    @IBOutlet var textLbl:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.moreThan18YearBGView.layer.cornerRadius = self.moreThan18YearBGView.frame.size.height / 2
        self.moreThan18YearBGView.clipsToBounds = true
        self.moreThan18YearBGView.addAppBasedShadow()
        self.checkBoxButton.isSelected = false
        self.startButton.isEnable = false

        self.updateUI()
    }

    func updateUI() {
        if self.checkBoxButton.isSelected == true {
            self.checkBoxButton.setImage(#imageLiteral(resourceName: "checkCopy"), for: .normal)
            self.moreThan18YearBGView.backgroundColor = UIColor.appRedColor
            self.textLbl.textColor = UIColor.white
        }
        else {
            self.checkBoxButton.setImage(#imageLiteral(resourceName: "checkCopy3"), for: .normal)
            self.moreThan18YearBGView.backgroundColor = UIColor.white
            self.textLbl.textColor = UIColor.black
            self.moreThan18YearBGView.layer.borderWidth = 1
            self.moreThan18YearBGView.layer.borderColor = UIColor.appRedColor.cgColor
            self.moreThan18YearBGView.clipsToBounds = true
        }
    }
    
    @IBAction func checkboxButtonAction(_ sender: Any) {
        if self.checkBoxButton.isSelected == true {
            self.checkBoxButton.isSelected = false
            self.startButton.isEnable = false

        }
        else {
            self.checkBoxButton.isSelected = true
            self.startButton.isEnable = true

        }
        self.updateUI()
    }
   
    @IBAction func startButtonAction(_ sender: Any) {
        if self.checkBoxButton.isSelected {
            self.performSegue(withIdentifier: "SystemAccessVC", sender: nil)
        }
    }
}
