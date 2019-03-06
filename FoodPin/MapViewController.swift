//
//  MapViewController.swift
//  FoodPin
//
//  Created by William Kpabitey Kwabla on 3/4/19.
//  Copyright © 2019 William Kpabitey Kwabla. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet var mapView:MKMapView!
    @IBOutlet var segementedControl:UISegmentedControl!
    
    var restaurant:Restaurant!
    var currentTransportType = MKDirectionsTransportType.automobile
    var currentRoute: MKRoute?
    
    let locationManager = CLLocationManager()
    var currentplaceMark: CLPlacemark?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        segementedControl.isHidden = true
        
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true

        // Do any additional setup after loading the view.
        // Request for a user's authorization for location services.
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
        
        // Convert address to coordinate and annotate it on map.
        let gecoder = CLGeocoder()
        gecoder.geocodeAddressString(restaurant.location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
        
            guard let placemarks = placemarks else{return}
            // Get the first placemark
            let placemark = placemarks[0]
            self.currentplaceMark = placemark
            
            // Add annotation
            let annotation = MKPointAnnotation()
            annotation.title = self.restaurant.name
            annotation.subtitle = self.restaurant.type
            
            guard let location = placemark.location else{return}
            annotation.coordinate = location.coordinate
            
            // Display the annotation
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            
            
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showSteps" {
            // Get the new view controller using segue.destination.
            let routeTableViewController = segue.destination.children[0] as! RouteTableViewController
            guard let steps = currentRoute?.steps else {return}
           // Pass the selected object to the new view controller.
            routeTableViewController.routeSteps = steps
         }
    }
    
    
    @IBAction func showDirection(sender: AnyObject) {
        
        switch segementedControl.selectedSegmentIndex {
        case 0:
            currentTransportType = MKDirectionsTransportType.automobile
        case 1:
            currentTransportType = MKDirectionsTransportType.walking
        default:
            break
        }
        
        segementedControl.isHidden = false
        
        guard let currentplaceMark = currentplaceMark else {
            return
        }
        
        let directionRequest = MKDirections.Request()
        
        // Set the source and the destination of the route
        directionRequest.source = MKMapItem.forCurrentLocation()
        let destinationPlacemark = MKPlacemark(placemark: currentplaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = currentTransportType
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (routeResponse, routeError) -> Void in
            guard let routeResponse = routeResponse else {
                if let routeError = routeError {
                    print("Error: \(routeError)")
                }
                 return
            }
            
            let route = routeResponse.routes[0]
            self.currentRoute = route
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        mapView.mapType = MKMapType.init(rawValue: UInt(sender.selectedSegmentIndex)) ?? .standard
    }
    

}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        // Reuse the annotation if possible
        var annotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        
        let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
        leftIconView.image = UIImage(named: restaurant.image)
        annotationView?.leftCalloutAccessoryView = leftIconView
        
        // Customize pin tint color
        annotationView?.pinTintColor = UIColor.orange
        
        annotationView?.rightCalloutAccessoryView = UIButton(type: UIButton.ButtonType.detailDisclosure)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = (currentTransportType == .automobile) ? UIColor.blue : UIColor.orange
        renderer.lineWidth = 3.0
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "showSteps", sender: view)
    }
}
