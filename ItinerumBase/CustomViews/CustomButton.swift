//
//  CustomButton.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/26/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

@IBDesignable
open class CustomButton: UIButton {
    private var _isEnable :Bool = true
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initialSetting()
    }
    
    func initialSetting() {
        self.backgroundColor = UIColor.appRedColor
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
        
        self.addAppBasedShadow()
    }
    
    var isEnable:Bool {
        get {
            return _isEnable
        }
        set {
            _isEnable = newValue
            if newValue == true {
                self.backgroundColor = UIColor.appRedColor
                self.isUserInteractionEnabled = true
            } else {
                self.backgroundColor = UIColor.appRedColor.withAlphaComponent(0.6)
                self.isUserInteractionEnabled = false
            }
        }
    }
}


