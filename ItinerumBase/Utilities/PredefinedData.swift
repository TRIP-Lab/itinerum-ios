//
//  PredefinedData.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 7/27/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class PredefinedData: NSObject {
    
    private var questionsArray:[Question]!
    var occupationType:OccupationType = .none {
        didSet {
            self.loadData()
        }
    }
    
    static let shared: PredefinedData = {
        let instance = PredefinedData()
        return instance
    } ()
    
    private override init() {
        super.init()
        self.questionsArray = [Question]()
        loadData()
    }
    
    func loadData() {
        
        var question:Question?
        if self.questionsArray.count == 1 {
            question = self.questionsArray.first
        }
        
        self.questionsArray.removeAll()
        
        if self.occupationType == .none {
            questionsArray.append(self.occupationQues)
        }
        else if (self.occupationType == .fullTimeWorker) || (self.occupationType == .partTimeWorker){
            
            if question != nil {
                questionsArray.append(question!)
            }
            
            questionsArray.append(self.homeLocationQues)
            questionsArray.append(self.workLocationQues)
            questionsArray.append(self.travelToWork1Ques)
            questionsArray.append(self.travelToWork2Ques)
            questionsArray.append(self.sexQues)
            questionsArray.append(self.ageBracketQues)
            self.questionsArray.append(self.emailQues)
        }
        else if self.occupationType == .student{
            if question != nil {
                questionsArray.append(question!)
            }
            
            questionsArray.append(self.homeLocationQues)
            questionsArray.append(self.studyLocationQues)
            questionsArray.append(self.travelToStudy1Ques)
            questionsArray.append(self.travelToStudy2Ques)
            questionsArray.append(self.sexQues)
            questionsArray.append(self.ageBracketQues)
            self.questionsArray.append(self.emailQues)
        }
        else if ((self.occupationType == .retired) || (self.occupationType == .atHome) || (self.occupationType == .other)){
            if question != nil {
                questionsArray.append(question!)
            }
            
            questionsArray.append(self.homeLocationQues)
            questionsArray.append(self.sexQues)
            questionsArray.append(self.ageBracketQues)
            self.questionsArray.append(self.emailQues)
        }
        
        if self.occupationType != .none {
            let serverArray = ((UIApplication.shared.delegate) as? AppDelegate)?.dynamicQuesArray
            self.questionsArray.append(contentsOf: serverArray!)
        }
    }
    
    class func getPermissionAccessArray() -> [PermissionAccess] {
        var array:[PermissionAccess] = [PermissionAccess]()
        var permission = PermissionAccess.init(accessName: LocalizeString.guideline_and_term_and_condition, isGranted: false)
        array.append(permission)
        permission = PermissionAccess.init(accessName: LocalizeString.allow_notifications, isGranted: false)
        array.append(permission)
        permission = PermissionAccess.init(accessName: LocalizeString.allow_location, isGranted: false)
        array.append(permission)
        permission = PermissionAccess.init(accessName: LocalizeString.allow_activity, isGranted: false)
        array.append(permission)
        return array
    }
    
    var isMoreThanEighteen:Bool {
        get { return true}
    }
    
    var occupationQues:Question {
        let question = Question()
        question.questionTitle = LocalizeString.OccupationQues.ques_title
        question.question = LocalizeString.OccupationQues.ques
        question.optionsArray = [LocalizeString.OccupationQues.option_1,LocalizeString.OccupationQues.option_2,LocalizeString.OccupationQues.option_3,LocalizeString.OccupationQues.option_4, LocalizeString.OccupationQues.option_5, LocalizeString.OccupationQues.option_6]
        question.answer = ""
        question.answerRequired = true
        question.columnName = QuestionType.occupationQues.rawValue
        question.screenTypeID = 1
        return question
    }
    
    var workLocationQues:Question {
        let question = Question()
        question.questionTitle = LocalizeString.WorkLocationQues.ques_title
        question.question = LocalizeString.WorkLocationQues.ques
        question.optionsArray = []
        question.answer = ""
        question.answerRequired = true
        question.columnName = QuestionType.workLocationQues.rawValue
        question.screenTypeID = 4
        return question
    }
    
    var homeLocationQues:Question {
        let question = Question()
        question.questionTitle = LocalizeString.HomeLocationQues.ques_title
        question.question = LocalizeString.HomeLocationQues.ques
        question.optionsArray = []
        question.answer = ""
        question.answerRequired = true
        question.columnName = QuestionType.homeLocationQues.rawValue
        question.screenTypeID = 4
        return question
    }
    
    var travelToWork1Ques:Question {
        let question = Question()
        question.questionTitle = LocalizeString.TravelToWork1Ques.ques_title
        question.question = LocalizeString.TravelToWork1Ques.ques
        question.optionsArray = [LocalizeString.TravelToWork1Ques.option_1, LocalizeString.TravelToWork1Ques.option_2, LocalizeString.TravelToWork1Ques.option_3, LocalizeString.TravelToWork1Ques.option_4, LocalizeString.TravelToWork1Ques.option_5, LocalizeString.TravelToWork1Ques.option_6, LocalizeString.TravelToWork1Ques.option_7, LocalizeString.TravelToWork1Ques.option_8]
        question.answer = ""
        question.answerRequired = true
        question.columnName = QuestionType.travelToWorkQues.rawValue
        question.screenTypeID = 2
        return question
    }
    
    var travelToWork2Ques:Question {
        let question = Question()
        question.questionTitle = LocalizeString.TravelToWork2Ques.ques_title
        question.question = LocalizeString.TravelToWork2Ques.ques
        question.optionsArray = [LocalizeString.TravelToWork2Ques.option_1, LocalizeString.TravelToWork2Ques.option_2, LocalizeString.TravelToWork2Ques.option_3, LocalizeString.TravelToWork2Ques.option_4, LocalizeString.TravelToWork2Ques.option_5, LocalizeString.TravelToWork2Ques.option_6, LocalizeString.TravelToStudy2Ques.option_7, LocalizeString.TravelToStudy2Ques.option_8, LocalizeString.TravelToStudy2Ques.option_9]
        question.answer = ""
        question.answerRequired = true
        question.columnName = QuestionType.alternativeTravelToWorkQues.rawValue
        question.screenTypeID = 2
        return question
    }
    
    var studyLocationQues:Question {
        let question = Question()
        question.questionTitle = LocalizeString.StudyLocationQues.ques_title
        question.question = LocalizeString.HomeLocationQues.ques
        question.optionsArray = []
        question.answer = ""
        question.answerRequired = true
        question.columnName = QuestionType.studyLocationQues.rawValue
        question.screenTypeID = 4
        return question
    }
    
    var travelToStudy1Ques:Question {
        let question = Question()
        question.questionTitle = LocalizeString.TravelToStudy1Ques.ques_title
        question.question = LocalizeString.TravelToStudy1Ques.ques
        question.optionsArray = [LocalizeString.TravelToStudy1Ques.option_1, LocalizeString.TravelToStudy1Ques.option_2, LocalizeString.TravelToStudy1Ques.option_3, LocalizeString.TravelToStudy1Ques.option_4, LocalizeString.TravelToStudy1Ques.option_5, LocalizeString.TravelToStudy1Ques.option_6, LocalizeString.TravelToWork1Ques.option_7, LocalizeString.TravelToWork1Ques.option_8]
        question.answer = ""
        question.answerRequired = true
        question.columnName = QuestionType.travelToStudyQues.rawValue
        question.screenTypeID = 2
        return question
    }
    
    var travelToStudy2Ques:Question {
        let question = Question()
        question.questionTitle = LocalizeString.TravelToStudy2Ques.ques_title
        question.question = LocalizeString.TravelToStudy2Ques.ques
        question.optionsArray = [LocalizeString.TravelToStudy2Ques.option_1, LocalizeString.TravelToStudy2Ques.option_2, LocalizeString.TravelToStudy2Ques.option_3, LocalizeString.TravelToStudy2Ques.option_4, LocalizeString.TravelToStudy2Ques.option_5, LocalizeString.TravelToStudy2Ques.option_6, LocalizeString.TravelToStudy2Ques.option_7, LocalizeString.TravelToStudy2Ques.option_8, LocalizeString.TravelToStudy2Ques.option_9]
        question.answer = ""
        question.answerRequired = true
        question.columnName = QuestionType.alternateTravelToStudyQues.rawValue
        question.screenTypeID = 2
        return question
    }
    
    var sexQues:Question {
        let question = Question()
        question.questionTitle = LocalizeString.SexQues.ques_title
        question.question = LocalizeString.SexQues.ques
        question.optionsArray = [LocalizeString.SexQues.option_1, LocalizeString.SexQues.option_2, LocalizeString.SexQues.option_3, LocalizeString.SexQues.option_4]
        question.answer = ""
        question.answerRequired = true
        question.columnName = QuestionType.sexQues.rawValue
        question.screenTypeID = 1
        return question
    }
    
    var ageBracketQues:Question {
        let question = Question()
        question.questionTitle = LocalizeString.AgeBracketQues.ques_title
        question.question = LocalizeString.AgeBracketQues.ques
        question.optionsArray = [LocalizeString.AgeBracketQues.option_1, LocalizeString.AgeBracketQues.option_2, LocalizeString.AgeBracketQues.option_3, LocalizeString.AgeBracketQues.option_4, LocalizeString.AgeBracketQues.option_5, LocalizeString.AgeBracketQues.option_6, LocalizeString.AgeBracketQues.option_7, LocalizeString.AgeBracketQues.option_8]
        question.answer = ""
        question.answerRequired = true
        question.columnName = QuestionType.ageBracketQues.rawValue
        question.screenTypeID = 1
        return question
    }
    
    var emailQues:Question {
        let question = Question()
        question.questionTitle = LocalizeString.ProvideEmailQues.ques_title
        question.question = LocalizeString.ProvideEmailQues.ques
        question.optionsArray = []
        question.answer = ""
        question.answerRequired = true
        question.columnName = QuestionType.email.rawValue
        question.screenTypeID = 5
        return question
    }
    
    var allQuestionsArray:[Question] {
        return self.questionsArray
    }
}
