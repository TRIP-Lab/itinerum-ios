//
//  QuestionVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/29/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class QuestionVC: BaseVC {
    
    @IBOutlet weak var screenTitleLbl: UILabel!
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var nextButton: CustomButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var questionModel:Question = Question()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.setTitle(LocalizeString.next, for: .normal)
        self.questionModel = self.getNextQuestion()
        
        self.tableView.register(UINib.init(nibName: "QuestionTableCell", bundle: nil), forCellReuseIdentifier: "QuestionTableCell")
        self.tableView.register(UINib.init(nibName: "QuestionTitleTblCell", bundle: nil), forCellReuseIdentifier: "QuestionTitleTblCell")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        if self.questionModel.answer.isEmpty {
            self.nextButton.isEnable = false
        }
        
        self.backButton.isHidden = false
        if self.questionModel.questionTitle == LocalizeString.OccupationQues.ques_title {
            self.backButton.isHidden = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        self.loadNextViewController()
    }
    
    @IBAction override func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.questionModel.answer = ""
    }
}

extension QuestionVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return questionModel.optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 100
        }
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 100))
        v.backgroundColor = UIColor.clear
        v.clipsToBounds =  true
        let imageView = UIImageView.init(image: UIImage(named: "gradient"))
        imageView.clipsToBounds = true
        imageView.frame = v.bounds
        v.addSubview(imageView)
        return v
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTitleTblCell") as! QuestionTitleTblCell
            cell.titleLbl.text = self.questionModel.questionTitle.localized()
            cell.subTitleLbl.text = self.questionModel.question.localized()
            return cell
            
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTableCell") as! QuestionTableCell
            cell.setupCellData(question: self.questionModel, indexPath: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            return
        }
        
        let answer = self.questionModel.optionsArray[indexPath.row]

        if self.questionModel.columnName == QuestionType.occupationQues.rawValue {
            PredefinedData.shared.occupationType = OccupationType.init(rawValue: answer)!
        }
        
        if self.questionModel.columnName == QuestionType.newsletter.rawValue || self.questionModel.columnName == QuestionType.newsletterFrench.rawValue{
            if indexPath.row == 0 {
                let webVC = UIStoryboard(name: "Question", bundle: nil).instantiateViewController(withIdentifier: "WebVC") as! WebVC
                webVC.urlString = newsLetterLink
                self.navigationController?.pushViewController(webVC, animated: true)
            }
        }
        
        self.questionModel.answer = "\(indexPath.row)"
        tableView.reloadData()
        if !self.questionModel.answer.isEmpty {
            self.nextButton.isEnable = true
        }

    }
}
