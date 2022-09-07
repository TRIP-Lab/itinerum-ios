//
//  EditTripMapVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/22/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit
import GoogleMaps

class EditTripMapVC: LocationQuesVC {

    var tripModel:TripModel = TripModel()
    @IBOutlet var doneButton:UIButton!
    @IBOutlet var backButton:UIButton!

    override func viewDidLoad() {
        self.setupMapView()
        self.searchTableHeight.constant = 0.0
        self.doneButton.titleLabel?.text = LocalizeString.done
        self.backButton.titleLabel?.text = LocalizeString.back
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension EditTripMapVC  {
//     func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        let point = self.mapView.center
//        let location = self.mapView.projection.coordinate(for: point)
//        self.searchBar.text = "\(location.latitude), \(location.longitude)"
//        self.tripModel.latitude = "\(location.latitude)"
//        self.tripModel.longitude = "\(location.longitude)"
//    }
    
        override func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        self.tripModel.latitude = "\(latitude)"
        self.tripModel.longitude = "\(longitude)"
    }
}
