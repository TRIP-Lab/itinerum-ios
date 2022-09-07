//
//  BaseClassVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/30/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.appBgColor

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNextQuestion() -> Question {
        let question = PredefinedData.shared.allQuestionsArray
        if let index  = question.index(where: {$0.answer == ""}) {
            return question[index]
        }
        else {
            return Question()
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadMapView(questionModel:Question) {
        let storyboard = UIStoryboard.init(name: "Question", bundle: nil)
        let locationQuesVC = storyboard.instantiateViewController(withIdentifier: "LocationQuesVC") as! LocationQuesVC
        locationQuesVC.questionModel = questionModel
        self.navigationController?.pushViewController(locationQuesVC, animated: true)
    }
    
    func loadNormalQuestion(questionModel:Question) {
        let storyboard = UIStoryboard.init(name: "Question", bundle: nil)
        let questionVC = storyboard.instantiateViewController(withIdentifier: "QuestionVC") as! QuestionVC
        questionVC.questionModel = questionModel
        self.navigationController?.pushViewController(questionVC, animated: true)
    }
    
    func numberVCQuestion(questionModel:Question) {
        let storyboard = UIStoryboard.init(name: "Question", bundle: nil)
        let numberVC = storyboard.instantiateViewController(withIdentifier: "NumberVC") as! NumberVC
        numberVC.questionModel = questionModel
        self.navigationController?.pushViewController(numberVC, animated: true)
    }
    
    func inputVCQuestion(questionModel:Question) {
        let storyboard = UIStoryboard.init(name: "Question", bundle: nil)
        let textInputVC = storyboard.instantiateViewController(withIdentifier: "TextInputVC") as! TextInputVC
        textInputVC.questionModel = questionModel
        self.navigationController?.pushViewController(textInputVC, animated: true)
    }
    
    func multipleChoiceVCQuestion(questionModel:Question) {
        let storyboard = UIStoryboard.init(name: "Question", bundle: nil)
        let multipleChoiceVC = storyboard.instantiateViewController(withIdentifier: "MultipleChoiceVC") as! MultipleChoiceVC
        multipleChoiceVC.questionModel = questionModel
        self.navigationController?.pushViewController(multipleChoiceVC, animated: true)
    }
    
    func loadIntroScreen() {
        let storyboard = UIStoryboard.init(name: "IntroVC", bundle: nil)
        let introVC = storyboard.instantiateViewController(withIdentifier: "IntroVC") as! IntroVC
        self.navigationController?.pushViewController(introVC, animated: true)
    }
        
    func loadNextViewController() {
        
        let question = PredefinedData.shared.allQuestionsArray
        let index  = question.index(where: {$0.answer == ""})
        guard index != nil else {
            self.updateAPICalling()
            return
        }
        
        let questionModel:Question = question[index!]
        let questionScreenType = ScreenType.init(rawValue: questionModel.screenTypeID)
        
        switch questionScreenType {
        case .singleSelection?:
            self.loadNormalQuestion(questionModel: questionModel)
        break
        case .multipleSelection?:
            self.multipleChoiceVCQuestion(questionModel: questionModel)
            break
        case .numberInput?:
            self.numberVCQuestion(questionModel: questionModel)
            break
        case .locationInput?:
            self.loadMapView(questionModel: questionModel)
            break
        case .textboxInput?:
            self.inputVCQuestion(questionModel: questionModel)
            break
        case .invalid?:
            break
        case .none:
            break
        }
    }
    
    func updateAPICalling() {
        self.view.showLoader()
        let question = PredefinedData.shared.allQuestionsArray
        QuestionClient.updateSurveyDataToServer(questionArray: question) { (error) in
            self.view.hideLoader()
            if error != nil {
                self.quickAlertViewWithMessage(msg: error?.description())
            }
            else {
                UserDefaults.isUserCreatedSuccessfully = true
                UserDefaults.isLocationRecordingEnabled = true
                self.loadIntroScreen()
            }
        }
    }
}

extension UIViewController {
    
    public func quickAlertViewWithMessage(msg : String?)
    {
        self.quickAlertView(titleStr: "Alert", withMessage: msg)
    }
    
    public func quickAlertView(titleStr : String?, withMessage msg : String?)
    {
        let actionSheetController: UIAlertController = UIAlertController(title: titleStr, message: msg, preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(okAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
}
