//
//  MultipleChoiceCell.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/15/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import UIKit


class MultipleChoiceCell: UITableViewCell {
    @IBOutlet weak var cellBGView:UIView!
    @IBOutlet weak var checkboxImageView:UIImageView!
    @IBOutlet weak var questionLbl:PaddingLabel!
    var questionModel:Question = Question()
    var indexPath:IndexPath!
    
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
        
        //DispatchQueue.main.async {
            self.updateUI()
        //}
    }
    
    func setupCellDataForPrompt(question:Question, indexPath:IndexPath) {
        self.questionModel = question
        self.indexPath = indexPath
        self.questionLbl.text = self.questionModel.optionsArray[indexPath.row].localized()
        
        DispatchQueue.main.async {
        self.updateUIForPrompt()
        }
    }
    
    func updateUI() {
        self.cellBGView.layer.cornerRadius = self.cellBGView.frame.size.height / 2
        self.cellBGView.clipsToBounds = true
        
        let ansArray = self.questionModel.answer.components(separatedBy: ",")
        let isContain = ansArray.contains("\((indexPath?.row)!)")
        
        if isContain == true  {
            self.checkboxImageView.image = #imageLiteral(resourceName: "checkCopy")
            self.cellBGView.backgroundColor = UIColor.appRedColor
            self.questionLbl.textColor = UIColor.white
            self.cellBGView.addAppBasedShadow()
        }
        else {
            self.checkboxImageView.image = #imageLiteral(resourceName: "checkCopy3")
            self.cellBGView.backgroundColor = UIColor.appBgColor
            self.questionLbl.textColor = UIColor.black
        }
    }
    
    func updateUIForPrompt() {
        self.cellBGView.layer.cornerRadius = self.cellBGView.frame.size.height / 2
        self.cellBGView.clipsToBounds = true
        
        let ansArray = self.questionModel.answer.components(separatedBy: ",")
        let isContain = ansArray.contains("\((self.questionModel.optionsArray[indexPath.row]))")
        
        if isContain == true  {
            self.checkboxImageView.image = #imageLiteral(resourceName: "checkCopy")
            self.cellBGView.backgroundColor = UIColor.appRedColor
            self.questionLbl.textColor = UIColor.white
            self.cellBGView.addAppBasedShadow()
        }
        else {
            self.checkboxImageView.image = #imageLiteral(resourceName: "checkCopy3")
            self.cellBGView.backgroundColor = UIColor.appBgColor
            self.questionLbl.textColor = UIColor.black
        }
    }
}

