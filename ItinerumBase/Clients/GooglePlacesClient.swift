//
//  GooglePlaces.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/8/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import Foundation
import Foundation
import GooglePlaces
import GoogleMaps

typealias CompletionHandler = (_ googlePlace:[GooglePlaces]) -> Void

public class GooglePlacesClient: NSObject
{
   static func autocompleteQueryApi(searchString:String, success:@escaping CompletionHandler )
    {
        //let filter = GMSAutocompleteFilter()
        //filter.type = GMSPlacesAutocompleteTypeFilter.noFilter
        
        //let center = CLLocationCoordinate2D(latitude: LocationService.currentLocation().lat ?? 0.0, longitude: LocationService.currentLocation().long ?? 0.0)
        
//        let northEast = CLLocationCoordinate2D(latitude: 45.8619221,
//                                               longitude: -75.0249357)
//        let southWest = CLLocationCoordinate2D(latitude: 45.018075,
//                                               longitude: -74.380251)
//        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        
        let filter = GMSAutocompleteFilter()
        //filter.type = GMSPlacesAutocompleteTypeFilter.address
        filter.country = "CA"


        GMSPlacesClient.shared().findAutocompletePredictions(fromQuery: searchString, filter: filter, sessionToken: nil) { (results, error) in
           
            var placeArray:[GooglePlaces] = [GooglePlaces]()
            print(results ?? "")
            if let tempResult = results {
                for result in tempResult
                {
                    let autocompletePlaces = GooglePlaces()
                    autocompletePlaces.name  = result.attributedPrimaryText.string
                    autocompletePlaces.formattedAddress = (result.attributedSecondaryText?.string)!
                    autocompletePlaces.placeID = result.placeID
                    placeArray.append(autocompletePlaces)
                }
            }
            
            DispatchQueue.main.async {
                    success(placeArray)
            }
        }
    }
    
   static func getPlaceDetailsWithPlaceID(placeId:String, success:@escaping CompletionHandler)
    {
        GMSPlacesClient.shared().lookUpPlaceID(placeId) { (place, error) in
            var placeArray:[GooglePlaces] = [GooglePlaces]()
            if let place = place {
                let googlePlaces = GooglePlaces()
                googlePlaces.name = String(place.name!)
                googlePlaces.formattedAddress = (place.formattedAddress) ?? ""
                googlePlaces.placeID = (place.placeID)!
                googlePlaces.placeLatitude = (place.coordinate.latitude) as Double
                googlePlaces.placeLongitude = (place.coordinate.longitude) as Double
                placeArray.append(googlePlaces)
            }
            
            DispatchQueue.main.async {
                success(placeArray)
            }
        }
    }
    
    
    func getPlaceDetailsFromCoordinates(coordinate: CLLocationCoordinate2D, success:@escaping CompletionHandler)
    {
        let geocoder: GMSGeocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate)
        { (result, error) in
            
        }
    }
    
    static func getPlaceDetailsFromCoordinates(coordinate: CLLocationCoordinate2D,  success:@escaping CompletionHandler)
    {
        let geocoder: GMSGeocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate)
        { (result, error) in
            
        }
    }
    
    static func getPlaceDetailsFromCoordinates(coordinate: CLLocationCoordinate2D, successBlock:((_ locationName:String,_ error:Error?) -> Void)? = nil)
    {
        
        //        var coord = CLLocationCoordinate2DMake(0.0, 0.0)
        //
        //        if coordinate == nil {
        //            if let latitude = LocationService.currentLocation().lat, let longitude = LocationService.currentLocation().long  {
        //                coord = CLLocationCoordinate2DMake(latitude, longitude)
        //            }
        //        }
        //        else {
        //            coord = coordinate!
        //        }
        
        let geocoder: GMSGeocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate)
        { (result, error) in
            
            DispatchQueue.main.async {
            }
            
            guard error == nil, let resultObj = result, let addressObj = resultObj.firstResult() else {
                if let block = successBlock {
                    block("", error)
                }
                return
            }
            
            
            //            print("coordinate.latitude=%f", addressObj.coordinate.latitude);
            //            print("coordinate.longitude=%f", addressObj.coordinate.longitude);
            //            print("thoroughfare=%@", addressObj.thoroughfare);
            //            print("locality=%@", addressObj.locality);
            //            print("subLocality=%@", addressObj.subLocality);
            //            print("administrativeArea=%@", addressObj.administrativeArea);
            //            print("postalCode=%@", addressObj.postalCode);
            //            print("country=%@", addressObj.country);
            //            print("lines=%@", addressObj.lines);
            
            //let address = (addressObj.locality ?? addressObj.administrativeArea ?? "") + ", " + (addressObj.country ?? "")
            let address = addressObj.lines?.joined(separator: ",")
            //UserDefaults.standard.set(addressObj.lines, forKey: "nearbyLocationName")
            UserDefaults.standard.synchronize()
            
            if let block = successBlock {
                block(address ?? "", error)
            }
            
        }
    }
}
