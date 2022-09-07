//
//  HomeScreenVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/15/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import GoogleMaps

class HomeScreen: BaseVC {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var daysRemainingView: UIView!
    @IBOutlet weak var remainingDaysLbl: UILabel!
    @IBOutlet weak var totalRemainingDaysLbl: UILabel!
    
    @IBOutlet weak var dateBgView: UIView!
    @IBOutlet weak var tripValidatedView: UIView!
    @IBOutlet weak var tripValidatedLbl: UILabel!
    @IBOutlet weak var totalTripLbl: UILabel!
    
    @IBOutlet weak var infoImgView: UIImageView!
    @IBOutlet weak var settingImgView: UIImageView!
    @IBOutlet weak var addTripImgView: UIImageView!
    @IBOutlet weak var dateMainBgView: UIView!
    @IBOutlet weak var arrowDownButton: UIButton!
    
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var yesterdayButton: UIButton!
    @IBOutlet weak var allDayButton: UIButton!
    @IBOutlet weak var customDayButton: UIButton!
    
    var dateType:DateType = DateType.today
    var datePicker:UIDatePicker!
    weak var tempTextField:UITextField?

    var locationService:LocationService = LocationService.sharedInstance
    //var polyline:GMSPolyline?

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        APP_DELEGATE?.homeScreenVCRef = self
        
        UIApplication.shared.applicationIconBadgeNumber = 0

        self.todayButton.setTitle(LocalizeString.today, for: .normal)
        self.yesterdayButton.setTitle(LocalizeString.yesterday, for: .normal)
        self.allDayButton.setTitle(LocalizeString.All_Days, for: .normal)
        self.customDayButton.setTitle(LocalizeString.custom_Days, for: .normal)

        let infoGesture = UITapGestureRecognizer(target: self, action: #selector(self.infoAction(_:)))
        infoImgView.addGestureRecognizer(infoGesture)
        infoImgView.isUserInteractionEnabled = true
        
        let addTripGesture = UITapGestureRecognizer(target: self, action: #selector(self.addTripAction(_:)))
        addTripImgView.addGestureRecognizer(addTripGesture)
        addTripImgView.isUserInteractionEnabled = true
        
        let settingGesture = UITapGestureRecognizer(target: self, action: #selector(self.settingAction(_:)))
        settingImgView.addGestureRecognizer(settingGesture)
        settingImgView.isUserInteractionEnabled = true
        
        self.daysRemainingView.addAppBasedShadow()
        self.dateBgView.addAppBasedShadow()
        self.tripValidatedView.addAppBasedShadow()
        
        self.locationPermission()
        self.setupMapView()
        self.updateButtonUI(button: self.todayButton)
        self.drawPolylineOnMap()
        
        NotificationCenter.default.addObserver(self, selector:#selector(HomeScreen.locNotification(_:)) , name: NSNotification.Name(rawValue: locationNotification), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector:#selector(HomeScreen.loadPromptScreenNotification(_:)) , name: NSNotification.Name(rawValue: promptQuestionNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let toDate = Date.init(fromString: remainingDaysStr, format: .isoDateTime)
        let diffInDays = Calendar.current.dateComponents([.day], from: Date(), to: toDate!).day
        self.remainingDaysLbl.text = "\(diffInDays ?? 0)"
        self.totalRemainingDaysLbl.text = ""//"of \(diffInDays ?? 0)"
        self.tripValidatedLbl.text =  "\(UserDefaults.getTripValidatedCount)"
        self.totalTripLbl.text = "\(LocalizeString.of) \(maxValidatedTrip)"
        
        if UserDefaults.isUserWantInfiniteTripValidation == nil && UserDefaults.getTripValidatedCount == maxValidatedTrip {
            PromptManager.showAlertForCompletionOfTripValidate()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: Button action
    @IBAction func todayButtonAction(_ sender: Any) {
        self.updateButtonUI(button: sender as! UIButton)
        self.dateType = .today
        self.drawPolylineOnMap()
        self.arrowDownButtonAction(sender)
    }
    
    @IBAction func yesterdayButton(_ sender: Any) {
        self.updateButtonUI(button: sender as! UIButton)
        self.dateType = .yesterday
        self.drawPolylineOnMap()
        self.arrowDownButtonAction(sender)
    }
    
    @IBAction func customDayButtonAction(_ sender: Any) {
        self.updateButtonUI(button: sender as! UIButton)
        self.showCustomDateAlert()

    }
    
    @IBAction func allDayButtonAction(_ sender: Any) {
        self.updateButtonUI(button: sender as! UIButton)
        self.dateType = .allDay
        self.drawPolylineOnMap()
        self.arrowDownButtonAction(sender)
    }
    
    
    func updateButtonUI(button:UIButton) {
        self.customDayButton.isSelected = false
        self.customDayButton.backgroundColor = UIColor.white
        self.customDayButton.titleLabel?.textColor = UIColor.black
        
        self.todayButton.isSelected = false
        self.todayButton.backgroundColor = UIColor.white
        self.todayButton.titleLabel?.textColor = UIColor.black
        
        self.yesterdayButton.isSelected = false
        self.yesterdayButton.backgroundColor = UIColor.white
        self.yesterdayButton.titleLabel?.textColor = UIColor.black
        
        self.allDayButton.isSelected = false
        self.allDayButton.backgroundColor = UIColor.white
        self.allDayButton.titleLabel?.textColor = UIColor.black
        
        button.isSelected = true
        button.backgroundColor = UIColor.appRedColor
        button.titleLabel?.textColor = UIColor.white
    }
    
    
    
    func drawCircle(locArray:[LocationInfo]) {
        
        //let tripArray = RealmUtilities.getAllCompletedPromptInfo()
        
//        for info in tripArray {
//            let circleCenter: CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(info.latitude)!, Double(info.longitude)!)
//            let circ = GMSCircle(position: circleCenter, radius: 10)
//            circ.fillColor = UIColor.appRedColor
//            circ.strokeColor = UIColor.appRedColor
//            circ.strokeWidth = 2
//            circ.map = mapView
        if let loc = locArray.last {
            let position:CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(loc.latitude), Double(loc.longitude))
            let marker = GMSMarker(position: position)
            marker.title = ""
            marker.snippet = ""
            //marker.infoWindowAnchor = CGPoint(x: 2, y: 2)
            marker.icon = UIImage(named: "point")
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.map = mapView
        }
        
//      }
    }
    
    func drawPolylineOnMap(startDate:Date? = nil, endDate:Date? = nil) {
        
        self.mapView.clear()

        let path = GMSMutablePath()
        let locationArray = RealmUtilities.getDateWiseLocation(dateType: self.dateType, startDate: startDate, endDate: endDate)
        
        for location in locationArray {
            path.add(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
        
        if locationArray.count > 0 {
           if let lat = locationArray.last?.latitude, let long = locationArray.last?.longitude {
                let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: self.mapView.camera.zoom)
            self.mapView.moveCamera(GMSCameraUpdate.setCamera(camera))
            }
        }
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 6.0
        polyline.strokeColor = UIColor.appRedColor
        polyline.map = self.mapView
        
        drawCircle(locArray: locationArray)
    }
    
    func setupMapView() {
       
        self.mapView.isMyLocationEnabled = true
        //mapView.settings.myLocationButton = true
        //mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 20)
        let camera:GMSCameraPosition?
        
        if let location = self.mapView.myLocation {
            camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevelDefault)
        }
        else if let lat = LocationService.currentLocation().lat, let long =  LocationService.currentLocation().long {
            camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: zoomLevelDefault)
        }
        else {
            camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoomLevelDefault)
        }
        
        self.mapView.moveCamera(GMSCameraUpdate.setCamera(camera!))
    }
    
    @objc func addTripAction(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "AddTripVC", sender: nil)
    }
    
    @objc func settingAction(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "SettingsVC", sender: nil)
    }
    
    func locationPermission() {
        if EfficientLocationManager.isLocationServiceEnabled() == .notDetermine {
            APP_DELEGATE?.efficientLocationManager.askPermissionForLocationAccess()
        }
        else if LocationService.isLocationServiceEnabled() == .disabled {
            let cameraAlert = UIAlertController (title: LocalizeString.Location_permission_Title.localized(), message: LocalizeString.Location_permission_message.localized(), preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: LocalizeString.settings.localized(), style: .default) { (_) -> Void in
                if  let settingsUrl = URL(string:UIApplicationOpenSettingsURLString){
                    DispatchQueue.main.async {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    }
                }
            }
            cameraAlert .addAction(settingsAction)
            self.present(cameraAlert, animated: true, completion: nil)
        }
        else {
            APP_DELEGATE?.efficientLocationManager.startDMLocationManager()
        }
    }
    
    @objc func infoAction(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "InfoVC", sender: nil)
    }

    @IBAction func arrowDownButtonAction(_ sender: Any) {
        let frame = self.view.convert(arrowDownButton.frame, from: nil)
        var top = CGAffineTransform(translationX: 0, y: 0)
        if self.dateMainBgView.frame.origin.y < 0 {
             top = CGAffineTransform(translationX: 0, y: 0)
        }
        else {
             top = CGAffineTransform(translationX: 0, y: -(frame.origin.y + 30))
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
            self.dateMainBgView.transform = top
        }, completion: nil)
    }
}

extension HomeScreen : UITextFieldDelegate {
    func showCustomDateAlert(){
        let alertController = UIAlertController(title: LocalizeString.enter_date_range, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = LocalizeString.from_date
            textField.delegate = self
            textField.tag = 1

        }
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = LocalizeString.to_date
            textField.delegate = self
            textField.tag = 2
        }
        
        let cancelAction = UIAlertAction(title: LocalizeString.cancel, style: UIAlertActionStyle.default, handler: {[unowned self] (action : UIAlertAction!) -> Void in
            let _ = self
        })
        
        let saveAction = UIAlertAction(title: LocalizeString.done, style: UIAlertActionStyle.default, handler: {  [unowned self] alert -> Void in
            let firstTextField = alertController.textFields![0]
            let secondTextField = alertController.textFields![1]
            if firstTextField.text?.isEmpty == true {
                Utility.showAlertWithDisappearingTitle(LocalizeString.enter_date_range)
            }
            else if secondTextField.text?.isEmpty == true {
                Utility.showAlertWithDisappearingTitle(LocalizeString.enter_date_range)
            }
            else {
                let startDate = Date.init(fromString: firstTextField.text!, format: DateFormatType.isoDate)
                let endDate = Date.init(fromString: secondTextField.text!, format: DateFormatType.isoDate)
                self.dateType = .customDays
                self.drawPolylineOnMap(startDate: startDate, endDate: endDate)
                self.arrowDownButtonAction(self.customDayButton)
            }
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- textFiled Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.tempTextField = textField
        self.pickUpDate(textField: textField)
    }
    
    func pickUpDate(textField:UITextField){
        
        // DatePicker
        datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 216))
        datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = UIDatePickerMode.date
        //datePicker.minimumDate = Date()
        datePicker.maximumDate = Date()
        textField.inputView = datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        toolBar.tintColor = UIColor.appRedColor
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: LocalizeString.done, style: .plain, target: self, action: #selector(HomeScreen.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: LocalizeString.cancel, style: .plain, target: self, action: #selector(HomeScreen.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    // MARK:- Button Done and Cancel
    @objc func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .none
        self.tempTextField?.text = datePicker.date.toString(format: .isoDate) //dateFormatter1.string(from: datePicker.date)
        self.tempTextField?.resignFirstResponder()
    }
    
    @objc func cancelClick() {
        self.tempTextField?.resignFirstResponder()
    }
}

extension HomeScreen {
    @objc func locNotification(_ notification: NSNotification) {
        self.tripValidatedLbl.text =  "\(UserDefaults.getTripValidatedCount)"
        self.drawPolylineOnMap()
    }
    
    /*@objc func loadPromptScreenNotification(_ notification: NSNotification) {
        
        let dict = notification.userInfo as! [String:Any]
        let loc = CLLocation.init(latitude: dict.numberValue(key: "lat").doubleValue, longitude: dict.numberValue(key: "long").doubleValue)
        let promptQuesVC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "PromptQuesVC") as! PromptQuesVC
        promptQuesVC.tripModel = TripModel()
        promptQuesVC.location = loc
        self.navigationController?.pushViewController(promptQuesVC, animated: true)
        
    }*/
}
