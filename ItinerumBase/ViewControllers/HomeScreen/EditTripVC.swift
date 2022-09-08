//
//  EditTripVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/17/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class EditTripVC: BaseVC {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var questionArray:[Question] = [Question]()
    var tripModel:TripModel = TripModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(EditTripHeader.nib, forHeaderFooterViewReuseIdentifier: EditTripHeader.identifier)
        self.saveButton.setTitle(LocalizeString.save, for: .normal)

        // first section
        let firstSection = Question() // adding only for increasing count
        firstSection.optionsArray = ["Edit date", "Edit time"];
        self.questionArray.append(firstSection)
        
        self.tableView.register(UINib.init(nibName: "QuestionTableCell", bundle: nil), forCellReuseIdentifier: "QuestionTableCell")

        // second section
        let array = QuestionClient.getAllPromptQuestion()
        
        if array.count >= 1 {
            array[0].answer = tripModel.answer1
        }
        
        if array.count >= 2 {
            array[1].answer = tripModel.answer2
        }
        
        self.questionArray.append(contentsOf: array)
        
        
        // third section
        let question = Question() // adding only for increasing count
        question.question = LocalizeString.destination_location
        question.optionsArray = ["Map cell"];
        self.questionArray.append(question)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        if self.tripModel.latitude.isEmpty || self.tripModel.longitude.isEmpty{
            Utility.showAlertWithDisappearingTitle(LocalizeString.select_location_on_map)
        }
        else {
            if self.questionArray.count >= 1 {
                self.tripModel.answer1 = questionArray[1].answer
                self.tripModel.prompt_num1 = 0
            }
            
            if self.questionArray.count >= 2 {
                self.tripModel.answer2 = questionArray[2].answer
                self.tripModel.prompt_num2 = 1
            }
            
            RealmUtilities.saveTripInfo(tripInfo: self.tripModel)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension EditTripVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.questionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questionArray[section].optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return 200
        }
        else {
            return  UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditTripDateTimeCell") as! EditTripDateTimeCell
            cell.setupDateTimeUI(isDate: indexPath.row == 0 ? true : false, trip: self.tripModel)
            return cell
            
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MultipleChoiceCell") as! MultipleChoiceCell
            cell.setupCellDataForPrompt(question: self.questionArray[indexPath.section], indexPath: indexPath)
            return cell
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTableCell") as! QuestionTableCell
            cell.editTripSetupCellData(question: self.questionArray[indexPath.section], indexPath: indexPath)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditTripMapCell") as! EditTripMapCell
            cell.setupMapView(tripModel: self.tripModel)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0.01
        } else if section == 1 {
            return 90
        }
        else if section == 2 {
            return 90
        }
        else if section == 3 {
            return 50
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: EditTripHeader.identifier) as! EditTripHeader
            headerView.titleLabel.text = self.questionArray[section].question
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
        }
        else if indexPath.section == 1 {
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
        else if indexPath.section == 2 {
            let questionModel = self.questionArray[indexPath.section]
            questionModel.answer = questionModel.optionsArray[indexPath.row]//"\(indexPath.row)"
            tableView.reloadData()
        }
        else if indexPath.section == 3 {
            let editTripVC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "EditTripMapVC") as! EditTripMapVC
            editTripVC.tripModel = self.tripModel
            self.navigationController?.pushViewController(editTripVC, animated: true)
        }
        
    }
}
