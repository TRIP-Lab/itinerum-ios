//
//  SystemAccessAlertView.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/29/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit
import Foundation

class SystemAccessAlertView: UIView {

    var agreedButtonActionBlock:((_ isAgree:Bool)->Void)?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.loadViewFromNib ()
    }
    
    func loadViewFromNib()
    {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "SystemAccessAlertView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = self.bounds
        if let tempView = view.viewWithTag(1001) {
            tempView.addAppBasedShadow()
        }
    
        self.addSubview(view)
    }

    @IBAction func closeButtonAction(_ sender: Any) {
        if let block = agreedButtonActionBlock {
            block(false)
        }
        self.removeFromSuperview()
    }
    
    @IBAction func greenButtonAction(_ sender: Any) {
        if let block = agreedButtonActionBlock {
            block(true)
        }
    }
    
}
