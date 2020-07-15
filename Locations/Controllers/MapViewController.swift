//
//  MapViewController.swift
//  Locations
//
//  Created by Sujit Molleti on 7/2/20.
//  Copyright © 2020 Sujit Molleti. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager() //coming from CoreLocation
    let regionInMeters: Double = 10000
    
    //var savedLocations: [CLLocationCoordinate2D] = []
    
    var savedLocations: [namedCoordinate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1 Get Permission -- Did Change Location
        checkLocationServices()
        
        mapView.delegate = self
        
        savedLocations = [
            namedCoordinate(name: "Harvard University", coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: 42.3770)!, longitude: CLLocationDegrees(exactly: -71.1167)!)),
            namedCoordinate(name: "Google NY Building", coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: 40.7284)!, longitude: CLLocationDegrees(exactly: -74.0099)!)),
            namedCoordinate(name: "Apple Spaceship", coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: 37.3318)!, longitude: CLLocationDegrees(exactly: -122.0312)!)),
            namedCoordinate(name: "Rutgers University", coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: 40.5008)!, longitude: CLLocationDegrees(exactly: -74.4474)!)),
            namedCoordinate(name: "Disney World", coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: 28.3852)!, longitude: CLLocationDegrees(exactly: -81.5639)!)),
            namedCoordinate(name: "McGill University", coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: 45.5048)!, longitude: CLLocationDegrees(exactly: -73.5772)!))
        ]
        
        LocationList.getInstance().loadLocations()
        
    }
        
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() { //Privacy -> Location Services, checking switch
            setUpLocationManager()
            checkLocationAuthorization()
        } else {
            //show alert
        }
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            //Do Map stuff
            //2 Show
            mapView.showsUserLocation = true
            zoomToUserLocation()
            locationManager.startUpdatingLocation()
        case .denied:
            //Show alert
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization() //ask for when in use auth
            //now didChangeAuthWillBeCalled
            break
        case .restricted:
            //Show alert, let them know what's up
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
        

    }
    
    func zoomToUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "mapToSaved"){
            let vc = segue.destination as! SavedListScreen
            vc.savedLocations = sender as? [namedCoordinate]
            vc.directionsDelegate = self
        }
    }
    
    @IBAction func heartButtonTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "mapToSaved", sender: savedLocations)
        
    }
    @IBAction func addButtonTapped(_ sender: Any) {
        
        guard let location = locationManager.location?.coordinate else { return }
        
        for i in savedLocations {
            if(equalCoordinates(i.coordinate, location)){
                return
            }
        }
        
        let alert = UIAlertController(title: "New Coordinate", message: "Enter a name", preferredStyle: .alert)
        
        let defaultString = "(\(location.latitude), \(location.longitude))"
        
        alert.addTextField { (textField) in
            textField.placeholder = defaultString
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (UIAlertAction) in
            
            var string: String = (alert.textFields?[0].text)?.trimmingCharacters(in: .whitespaces) ?? defaultString
            if string.count == 0 {
                string = defaultString
            }
            DispatchQueue.main.async {
                let temp: namedCoordinate = namedCoordinate(name: string, coordinate: location)
                self.savedLocations.append(temp)
                LocationList.getInstance().saveLocation(coordinate: temp)
            }
                
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
            print("pressed Cancel")
        }))
        
        self.present(alert, animated: true)
        
    }
    
    func equalCoordinates(_ l1: CLLocationCoordinate2D,_ l2: CLLocationCoordinate2D) -> Bool {
        
        if(l1.longitude == l2.longitude && l1.latitude == l2.latitude){
            return true
        }
        return false
    }
    
    func resetMapView(){
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    //3 Update -- DidUpdateLocation -- removed for now, it was recentering too much
    
    //Who's calling these methods? -- system
    //these are optional funcs, do they not have to implemented?
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //We'll be back
        guard let location = locations.last else { return } // so locations is an array that is updating, do any of the locations terminate after a period of time? -- Yes A: multiple locations can come at a time, the most recent is at the end, hence, last

        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//
//        mapView.setRegion(region, animated: true)

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //We'll be back
        checkLocationAuthorization()
    }
    
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
    
}

extension MapViewController: DirectionsDelegate {
    
    func setDirections(destination: namedCoordinate){
        print("setting directions to \(destination.name)")
        
        resetMapView()
        
        guard let userLocation = locationManager.location?.coordinate else { return }
        
        let request = createDirectionsRequest(from: userLocation, to: destination.coordinate) //calling helper method
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            guard let response = response else { return }
            
            for route in response.routes { //could have multiple routes, in this case only one because we have set requestsAltRoutes to false
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
            }

        }
        
        let destAnnotation = MKPointAnnotation()
        destAnnotation.coordinate = destination.coordinate
        destAnnotation.title = destination.name
        
        mapView.addAnnotation(destAnnotation)
        
    }
    
    //helper method
    func createDirectionsRequest(from start: CLLocationCoordinate2D, to dest: CLLocationCoordinate2D) -> MKDirections.Request {
        
        //need start and dest placemarks
        let startingLocation = MKPlacemark(coordinate: start)
        let destination = MKPlacemark(coordinate: dest)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        return request
    }
}
