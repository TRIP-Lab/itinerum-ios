//
//  EditTripMapCell.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/22/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit
import GoogleMaps

class EditTripMapCell: UITableViewCell {
    @IBOutlet weak var mapView: GMSMapView!
    var tripModel:TripModel = TripModel()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.mapView.isUserInteractionEnabled = false
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func setupMapView(tripModel:TripModel) {
        var camera:GMSCameraPosition?
        var lat:Double = 0
        var long:Double = 0
        if tripModel.latitude.isEmpty || tripModel.longitude.isEmpty {
            lat = LocationService.currentLocation().lat ?? 0.0
            long = LocationService.currentLocation().long ?? 0.0
        }
        else {
            lat = Double(tripModel.latitude) ?? 0.0
            long = Double(tripModel.longitude) ?? 0.0
        }
        
        self.mapView.clear()
        
        camera = GMSCameraPosition.camera(withLatitude:lat, longitude:long, zoom: 14)
        self.mapView.moveCamera(GMSCameraUpdate.setCamera(camera!))
        //self.mapView.isMyLocationEnabled = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = ""
        marker.snippet = ""
        marker.map = self.mapView

    }

}
