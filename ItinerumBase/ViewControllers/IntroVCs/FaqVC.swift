//
//  FaqVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 9/22/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class FaqVC: BaseVC {

    @IBOutlet weak var faqLbl:UILabel!
    @IBOutlet weak var faqTitleLbl:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let clickOnFAQGesture = UITapGestureRecognizer(target: self, action: #selector(FaqVC.clickFAQAction(_:)))
        clickOnFAQGesture.numberOfTapsRequired = 1
        clickOnFAQGesture.numberOfTouchesRequired = 1
        self.faqLbl.isUserInteractionEnabled = true
        self.faqLbl.addGestureRecognizer(clickOnFAQGesture)
        //TODO (Use proper localization files)
        let language = Bundle.main.preferredLocalizations.first ?? "fr" 
        if language == "en" {
            let attributedString = NSMutableAttributedString(string: "For more information, consult our FAQs.", attributes: [
                .font: UIFont(name: "NunitoSans-Regular", size: 25.0)!,
                .foregroundColor: UIColor.black,
                .kern: 0.0
                ])
            attributedString.addAttributes([
                .font: UIFont(name: "NunitoSans-Bold", size: 25.0)!,
                .foregroundColor: UIColor(red: 239.0 / 255.0, green: 51.0 / 255.0, blue: 63.0 / 255.0, alpha: 1.0)
                ], range: NSRange(location: 34, length: 4))
            self.faqLbl.attributedText = attributedString
            self.faqTitleLbl.text = "Thanks. \nLet’s get started!"
        }
        else {
            let attributedString = NSMutableAttributedString(string: "Pour en savoir davantage, consultez notre foire aux questions.", attributes: [
                .font: UIFont(name: "NunitoSans-Regular", size: 25.0)!,
                .foregroundColor: UIColor.black,
                .kern: 0.0
                ])
            attributedString.addAttributes([
                .font: UIFont(name: "NunitoSans-Bold", size: 25.0)!,
                .foregroundColor: UIColor(red: 239.0 / 255.0, green: 51.0 / 255.0, blue: 63.0 / 255.0, alpha: 1.0)
                ], range: NSRange(location: 42, length: 19))
            self.faqLbl.attributedText = attributedString
            self.faqTitleLbl.text = "Merci \nAllons-y !"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func clickFAQAction(_ sender: UIGestureRecognizer) {
        loadFAQVC()
    }

    func loadFAQVC() {
        let webVC = UIStoryboard(name: "Question", bundle: nil).instantiateViewController(withIdentifier: "WebVC") as! WebVC
        webVC.urlString = FAQLink
        self.navigationController?.pushViewController(webVC, animated: true)
    }

}
