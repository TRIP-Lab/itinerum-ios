//
//  InfoCell.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/20/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import UIKit


class AboutCell: UITableViewCell {
    
    @IBOutlet weak var aboutLabel: UILabel!
    
    var item: String? {
        didSet {
            guard  let item = item else {
                return
            }
            
            aboutLabel?.text = item
        }
    }
}
