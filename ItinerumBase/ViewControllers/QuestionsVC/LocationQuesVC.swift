//
//  LocationQuesVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/1/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit
import GoogleMaps

let zoomLevelDefault:Float = 16.0
let autoCompleteCellHeight:Float = 48

class LocationCell: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!

}

class LocationQuesVC: BaseVC {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: CustomButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    var questionModel:Question = Question()
    var placeArray:[GooglePlaces] = [GooglePlaces]()
    
    @IBOutlet weak var searchTableHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.setTitle(LocalizeString.next, for: .normal)
        self.setupMapView()
        self.searchTableHeight.constant = 0.0
        self.searchBar.placeholder = LocalizeString.map_search_bar_placeholder
        
        self.titleLbl.text = self.questionModel.questionTitle.localized()
        self.subTitleLbl.text = self.questionModel.question.localized()
    }
    
    func setupMapView() {
        let camera:GMSCameraPosition?
        if LocationService.isCurrentLocationValid {
            camera = GMSCameraPosition.camera(withLatitude: LocationService.currentLocation().lat ?? 0.0, longitude: LocationService.currentLocation().long ?? 0.0, zoom: zoomLevelDefault)
        }
        else {
            
            camera = GMSCameraPosition.camera(withLatitude: (mapView.myLocation?.coordinate.latitude) ?? 0.0, longitude: (mapView.myLocation?.coordinate.longitude) ?? 0.0, zoom: zoomLevelDefault)
        }
        
        self.mapView.moveCamera(GMSCameraUpdate.setCamera(camera!))
        self.mapView.isMyLocationEnabled = true
    }
    
    func changeCameraPosition(place:GooglePlaces) {
        let camera = GMSCameraPosition.camera(withLatitude: place.placeLatitude, longitude: place.placeLongitude, zoom: zoomLevelDefault)
        self.mapView.moveCamera(GMSCameraUpdate.setCamera(camera))
    }
    
    @IBAction override func backButtonAction(_ sender: Any) {
        super.backButtonAction(sender)
        self.questionModel.answer = ""
        
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        self.loadNextViewController()
    }
}

extension LocationQuesVC : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar .resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        GooglePlacesClient.autocompleteQueryApi(searchString: searchText) {[unowned self] (googlePlaceArray) in
            let _ = self
            self.placeArray = googlePlaceArray
            
            self.view.layoutIfNeeded()
            self.searchTableHeight.constant = CGFloat(Float(googlePlaceArray.count) * autoCompleteCellHeight)
            self.tableView.reloadData()
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            
        }
    }
}

extension LocationQuesVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(autoCompleteCellHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = placeArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
        cell.titleLbl.text = place.name
        cell.subTitleLbl.text = place.formattedAddress
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = placeArray[indexPath.row]
        
        self.placeArray.removeAll()
        self.searchTableHeight.constant = 0
        self.tableView.reloadData()
        self.searchBar.resignFirstResponder()
        
        GooglePlacesClient.getPlaceDetailsWithPlaceID(placeId: place.placeID) { (placeArray) in
            if placeArray.count > 0 {
                place.placeLatitude = (placeArray.first?.placeLatitude) ?? 0.0
                place.placeLongitude = placeArray.first?.placeLongitude ?? 0.0
            }
            
            self.questionModel.answer = "\(place.placeLatitude), \(place.placeLongitude)"
            self.changeCameraPosition(place: place)
        }
    }
}

extension LocationQuesVC : GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        let centerMapCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.questionModel.answer = "\(latitude), \(longitude)"
        GooglePlacesClient.getPlaceDetailsFromCoordinates(coordinate: centerMapCoordinate) { (address, error) in
            if error == nil {
                self.searchBar.text = address
                
            }
        }
    }
    
//    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        let point = self.mapView.center
//        let location = self.mapView.projection.coordinate(for: point)
//        //self.searchBar.text = "\(location.latitude), \(location.longitude)"
//        self.questionModel.answer = "\(location.latitude), \(location.longitude)"
//        GooglePlacesClient.getPlaceDetailsFromCoordinates(coordinate: CLLocationCoordinate2D.init(latitude: location.latitude, longitude: location.longitude)) { (address, error) in
//            if error == nil {
//                self.searchBar.text = address
//
//            }
//        }
//    }
}
