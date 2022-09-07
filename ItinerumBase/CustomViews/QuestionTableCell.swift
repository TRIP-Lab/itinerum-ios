//
//  QuestionTableCell.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/29/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class QuestionTableCell: UITableViewCell {

    @IBOutlet weak var cellBGView:UIView!
    @IBOutlet weak var checkboxImageView:UIImageView!
    @IBOutlet weak var questionLbl:PaddingLabel!
    var questionModel:Question = Question()
    var indexPath:IndexPath?

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
    
    func setupCellData(question:Question, indexPath:IndexPath) {
        self.questionModel = question
        self.indexPath = indexPath
        self.questionLbl.text = self.questionModel.optionsArray[indexPath.row].localized()
        
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
    
    func editTripSetupCellData(question:Question, indexPath:IndexPath) {
        self.questionModel = question
        self.indexPath = indexPath
        self.questionLbl.text = self.questionModel.optionsArray[indexPath.row].localized()
        
        DispatchQueue.main.async {
            self.cellBGView.layer.cornerRadius = self.cellBGView.frame.size.height / 2
            self.cellBGView.clipsToBounds = true
            
            
            if "\((self.questionModel.optionsArray[indexPath.row]))" == self.questionModel.answer {
                self.checkboxImageView.image = UIImage.init(named: "successCheck")
                self.cellBGView.backgroundColor = UIColor.appRedColor
                self.questionLbl.textColor = UIColor.white
                self.cellBGView.addAppBasedShadow()
            }
            else {
                self.checkboxImageView.image = nil
                self.cellBGView.backgroundColor = UIColor.clear
                self.questionLbl.textColor = UIColor.black
            }
        }
    }
    
    func updateUI() {
        self.cellBGView.layer.cornerRadius = self.cellBGView.frame.size.height / 2
        self.cellBGView.clipsToBounds = true
        
        if "\((self.indexPath?.row)!)" == self.questionModel.answer {
            self.checkboxImageView.image = UIImage.init(named: "successCheck")
            self.cellBGView.backgroundColor = UIColor.appRedColor
            self.questionLbl.textColor = UIColor.white
            self.cellBGView.addAppBasedShadow()
        }
        else {
            self.checkboxImageView.image = nil
            self.cellBGView.backgroundColor = UIColor.clear
            self.questionLbl.textColor = UIColor.black
            //self.cellBGView.layer.borderWidth = 1
            //self.cellBGView.layer.borderColor = UIColor.appRedColor.cgColor
            //self.cellBGView.clipsToBounds = true
        }
        
    }
}
