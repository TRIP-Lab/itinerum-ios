//
//  SurveyCompleteVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 9/17/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class SurveyCompleteVC: UIViewController {

    @IBOutlet weak var thanksLbl:UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributedString = NSMutableAttributedString(string: LocalizeString.complete_survey_message, attributes: [.foregroundColor: UIColor.black, .kern: 0.5])
        attributedString.addAttributes([.foregroundColor: UIColor(red: 239.0 / 255.0, green: 51.0 / 255.0, blue: 63.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: 16))
        
        self.thanksLbl.attributedText = attributedString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
