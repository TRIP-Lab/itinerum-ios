//
//  EditTripHeader.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/22/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class EditTripHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
