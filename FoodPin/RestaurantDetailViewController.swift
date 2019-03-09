//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by William Kpabitey Kwabla on 3/2/19.
//  Copyright © 2019 William Kpabitey Kwabla. All rights reserved.
//

import UIKit
import MapKit

class RestaurantDetailViewController: UIViewController {
    @IBOutlet var restaurantImageView: UIImageView!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var mapView:MKMapView!
    
    var restaurant:RestaurantMO!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = restaurant.name
        
        // Enable self sizing cells
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableView.automaticDimension
            
        tableView.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/250.0, alpha: 0.2)
          tableView.separatorColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/250.0, alpha: 0.8)
//        tableView.tableFooterView = UIView(frame: CGRect.zero)
        restaurantImageView.image = UIImage(data: restaurant.image as! Data)
        
        // Handle tap gesture for the map view
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showMap))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(restaurant.location!) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else {return}
            // Get first placemarker
            let placemark = placemarks[0]
            
            // Add anotation
            let annotation = MKPointAnnotation()
            
            guard let location = placemark.location else {return}
            
            // Display the annotation
            annotation.coordinate = location.coordinate
            self.mapView.addAnnotation(annotation)
            
            // Set the zoom level
            let region = MKCoordinateRegion.init(center: annotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
            self.mapView.setRegion(region, animated: false)
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        navigationController?.hidesBarsOnSwipe = false
//        navigationController?.setNavigationBarHidden(false, animated: true)
//    }
    
    // MARK: - Custom methods
    @objc func showMap() {
        performSegue(withIdentifier: "showMap", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if segue.identifier == "showReview" {
            let destinationController = segue.destination as! ReviewViewController
              // Pass the selected object to the new view controller.
            destinationController.restaurant = restaurant
        } else if segue.identifier == "showMap" {
            let destinationController = segue.destination as! MapViewController
            // Pass the selected object to the new view controller.
            destinationController.restaurant = restaurant
        }
    }
    
    
    @IBAction func close(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func ratingButtonTapped(segue: UIStoryboardSegue) {
        guard let rating = segue.identifier else {return}
        restaurant.isVisited = true
        
        switch rating {
        case "great":
            restaurant.rating = "Absolutely love it! Must try it."
        case "good":
            restaurant.rating = "Pretty good."
        case "dislike":
            restaurant.rating = "I don't like it."
        default:
            break
        }
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            appDelegate.saveContext()
        }
        
        tableView.reloadData()
    }
    
}


extension RestaurantDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RestaurantDetailTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = "Name"
            cell.valueLabel.text = restaurant.name
        case 1:
            cell.fieldLabel.text = "Type"
            cell.valueLabel.text = restaurant.type
        case 2:
            cell.fieldLabel.text = "Location"
            cell.valueLabel.text = restaurant.location
        case 3:
            cell.fieldLabel.text = "Phone"
            cell.valueLabel.text = restaurant.phone
        case 4:
            cell.fieldLabel.text = "Been here"
            cell.valueLabel.text = (restaurant.isVisited) ? "Yes, I've been here before. \(restaurant.rating ?? "")" : "No"
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
}


extension RestaurantDetailViewController: UITabBarDelegate {
    
}
