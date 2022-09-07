//
//  AddTripVc.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/17/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class TripListCell: UITableViewCell {
    @IBOutlet var numberLabel:UILabel!
    @IBOutlet var dateLabel:UILabel!
    @IBOutlet var timeLabel:UILabel!
    @IBOutlet weak var editButton: UIButton!
    var tripInfo:TripModel = TripModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func setupUI(trip:TripModel, index:Int) {
        self.tripInfo = trip
        self.numberLabel.text = "\(index + 1)"
        self.dateLabel.text = self.tripInfo.getDateString
        self.timeLabel.text = self.tripInfo.getTimeString
    }
}

class AddTripVC: BaseVC {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var tripList:[TripModel] = [TripModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tripList = RealmUtilities.getTripInfo()
        self.tableView.reloadData()
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: LocalizeString.adding_destination, message: LocalizeString.notIncrement_validated_Trip, preferredStyle: .alert)
        let yesAction: UIAlertAction = UIAlertAction(title: LocalizeString.continueTile, style: .default) {[unowned self] action -> Void in
            let _ = self
            self.loadEditScreen(trip: TripModel())
        }
        let noAction: UIAlertAction = UIAlertAction(title: LocalizeString.dismiss, style: .default) {[unowned self] action -> Void in
            let _ = self
        }
        actionSheetController.addAction(noAction)
        actionSheetController.addAction(yesAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func loadEditScreen(trip:TripModel) {
        let editVC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "EditTripVC") as! EditTripVC
        editVC.tripModel = trip
        self.navigationController?.pushViewController(editVC, animated: true)

    }
}

extension AddTripVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tripList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tripInfo = self.tripList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripListCell") as! TripListCell
        cell.setupUI(trip: tripInfo, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.loadEditScreen(trip: self.tripList[indexPath.row])

    }
}

