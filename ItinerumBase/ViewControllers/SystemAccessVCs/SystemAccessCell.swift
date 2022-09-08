//
//  SystemAccessTableCellTableViewCell.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/27/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit
import Foundation

class SystemAccessCell: UITableViewCell {

    @IBOutlet weak var cellBGView:UIView!
    @IBOutlet weak var checkboxImageView:UIImageView!
    @IBOutlet weak var accessNameLbl:PaddingLabel!
    var permissionModel:PermissionAccess = PermissionAccess()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
    }
    
    func setupCellData(permissionData:PermissionAccess) {
        self.permissionModel = permissionData
        self.accessNameLbl.text = self.permissionModel.permissionAccessName.localized()
        self.layoutIfNeeded()
        
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
    
    func updateUI() {
        
        self.cellBGView.layer.cornerRadius = self.cellBGView.frame.size.height / 2
        self.cellBGView.clipsToBounds = true
        
        if self.permissionModel.isPermissionGranted == true {
            self.checkboxImageView.image = #imageLiteral(resourceName: "checkCopy")
            self.cellBGView.backgroundColor = UIColor.appRedColor
            self.accessNameLbl.textColor = UIColor.white
        }
        else {
            self.checkboxImageView.image = #imageLiteral(resourceName: "checkCopy3")
            self.cellBGView.backgroundColor = UIColor.white
            self.accessNameLbl.textColor = UIColor.black
            self.cellBGView.layer.borderWidth = 1
            self.cellBGView.layer.borderColor = UIColor.appRedColor.cgColor
            self.cellBGView.clipsToBounds = true
        }
        
        self.cellBGView.addAppBasedShadow()
    }

}

