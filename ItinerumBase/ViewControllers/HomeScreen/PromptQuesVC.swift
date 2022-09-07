//
//  PromptQuesVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 9/14/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class PromptQuesVC: BaseVC {
    @IBOutlet weak var doneButton: CustomButton!
    @IBOutlet weak var tableView: UITableView!
    var questionArray:[Question] = [Question]()
    var tripModel:TripModel = TripModel()
    var location:CLLocation = CLLocation()
    var promptStartTime:Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(EditTripHeader.nib, forHeaderFooterViewReuseIdentifier: EditTripHeader.identifier)
        self.doneButton.setTitle(LocalizeString.done, for: .normal)
        
        self.tableView.register(UINib.init(nibName: "QuestionTableCell", bundle: nil), forCellReuseIdentifier: "QuestionTableCell")

        self.questionArray = QuestionClient.getAllPromptQuestion()
        self.doneButtonEnableDisable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
        if self.questionArray.count >= 1 {
            self.tripModel.answer1 = questionArray[0].answer
            self.tripModel.prompt_num1 = 0
        }
        
        if self.questionArray.count >= 2 {
            self.tripModel.answer2 = questionArray[1].answer
            self.tripModel.prompt_num2 = 1
        }
        
        self.tripModel.displayedAtDate = self.promptStartTime
        self.tripModel.recordedAtDate = Date()
        
        APP_DELEGATE?.savePromptData(isCancelled: false, tripModel: self.tripModel, location: location)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: locationNotification), object: nil, userInfo: nil)
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.global(qos: .background).async {
            APP_DELEGATE?.updateLocationOnTheServer()
        }
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func doneButtonEnableDisable() {
        var isDoneButtonEnable = true
        
        for ques in self.questionArray {
            if ques.answer.isEmpty {
                isDoneButtonEnable = false
                break
            }
        }
        
        self.doneButton.isEnable = isDoneButtonEnable

    }
}

extension PromptQuesVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.questionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questionArray[section].optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MultipleChoiceCell") as! MultipleChoiceCell
            cell.setupCellDataForPrompt(question: self.questionArray[indexPath.section], indexPath: indexPath)
            return cell
        }
        else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTableCell") as! QuestionTableCell
            cell.editTripSetupCellData(question: self.questionArray[indexPath.section], indexPath: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 90
        } else if section == 1 {
            return 90
        }
        
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: EditTripHeader.identifier) as! EditTripHeader
        headerView.titleLabel.text = self.questionArray[section].question
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let questionModel = self.questionArray[indexPath.section]
            if questionModel.answer.isEmpty {
                questionModel.answer = questionModel.optionsArray[indexPath.row]//"\(indexPath.row)"
            }
            else {
                var ansArray = questionModel.answer.components(separatedBy: ",")
                if let index = ansArray.index(of: "\(questionModel.optionsArray[indexPath.row])") {
                    ansArray.remove(at: index)
                }
                else {
                    ansArray.append("\(questionModel.optionsArray[indexPath.row])")
                }
                
                questionModel.answer = ansArray.joined(separator: ",")
            }
            
            tableView.reloadData()
        }
        else if indexPath.section == 1 {
            let questionModel = self.questionArray[indexPath.section]
            questionModel.answer = questionModel.optionsArray[indexPath.row]//"\(indexPath.row)"
            tableView.reloadData()
        }
        
        self.doneButtonEnableDisable()
    }
}
