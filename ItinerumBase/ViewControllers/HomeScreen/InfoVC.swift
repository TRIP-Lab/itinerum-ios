//
//  InfoVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/17/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit
import MessageUI

 class Info {
    var title:String = ""
    var infoArray:[String] = [String]()
    var isCollapsed:Bool = true
    var isCollapsible: Bool  = true

}

class InfoVC: BaseVC {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var infoArray:[Info] = [Info]()

    override func viewDidLoad() {
        super.viewDidLoad()

        var infoObj = Info.init()
        infoObj.title = LocalizeString.feedback
        infoObj.infoArray = []
        self.infoArray.append(infoObj)
        
        infoObj = Info.init()
        infoObj.title = LocalizeString.consent_agreement
        infoObj.infoArray = [LocalizeString.consent_agreement_desc]
        self.infoArray.append(infoObj)
        
        infoObj = Info.init()
        infoObj.title = LocalizeString.About_Itinerum_MTL
        infoObj.infoArray = [LocalizeString.About_Itinerum_MTL_desc]
        self.infoArray.append(infoObj)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.register(HeaderView.nib, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension InfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.infoArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = self.infoArray[section]
        //guard item.isCollapsible else {
        //    return item.infoArray.count
        //}
        
        if item.isCollapsed {
            return 0
        } else {
            return item.infoArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.infoArray[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath) as! AboutCell
        cell.item = item.infoArray[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier) as! HeaderView
        headerView.backgroundColor = UIColor.white
        if section == 0 {
            headerView.arrowLabel?.isHidden = true
        } else {
            headerView.arrowLabel?.isHidden = false
        }
        
        let item = self.infoArray[section]
        headerView.item = item
        headerView.headerTapBlock = { [unowned self] in
            
            if section == 0 {
                //if let url = URL(string: "mailto:cm032869981@gmail.com") {
                //    UIApplication.shared.open(url)
                //}
                self.showMailComposer() 
            }
            else {
                let _ = self
                //if item.isCollapsible {
                // Toggle collapse
                let collapsed = item.isCollapsed == true ? false : true
                item.isCollapsed = collapsed
                headerView.setCollapsed(collapsed: collapsed)
                
                // Adjust the number of the rows inside the section
                tableView.beginUpdates()
                tableView.reloadSections([section], with: .fade)
                tableView.endUpdates()
                //}
            }
        }
        return headerView
    }
}

extension InfoVC : MFMailComposeViewControllerDelegate {
    func showMailComposer() {
        
        let body = "[\(UIDevice.current.localizedProductName), \(Utility.osVersion), \(Utility.appVersion)]"

        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            Utility.showAlertWithDisappearingTitle(LocalizeString.mail_not_setup_message)
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients([email_TO])
        composeVC.setSubject(LocalizeString.email_subject)
        composeVC.setMessageBody(body, isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)

    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        if error != nil {
            Utility.showAlertWithDisappearingTitle(error?.localizedDescription)
            controller.dismiss(animated: true, completion: nil)
        }
        else {
            switch (result) {
            case .cancelled:
                controller.dismiss(animated: true, completion: nil)
            case .sent:
                controller.dismiss(animated: true, completion: nil)
                Utility.showAlertWithDisappearingTitle(LocalizeString.email_sent_message)
            case .failed:
                controller.dismiss(animated: true, completion: nil)
                Utility.showAlertWithDisappearingTitle(LocalizeString.email_send_fail)
            default:
                break;
            }
        }
    }
}
