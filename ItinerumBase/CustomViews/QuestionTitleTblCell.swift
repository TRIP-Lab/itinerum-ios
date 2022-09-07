//
//  QuestionTitleTblCell.swift
//  ItinerumBase
//
//  Created by Chandramani Choudhary on 10/2/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class QuestionTitleTblCell: UITableViewCell {

    @IBOutlet weak var titleLbl:UILabel!
    @IBOutlet weak var subTitleLbl:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.backgroundColor = UIColor.appBgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
