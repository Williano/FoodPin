//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by William Kpabitey Kwabla on 2/28/19.
//  Copyright © 2019 William Kpabitey Kwabla. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications


class RestaurantTableViewController: UITableViewController {
    
    var restaurants:[RestaurantMO] = []
    var fetchResultController: NSFetchedResultsController<RestaurantMO>!
    var searchController: UISearchController!
    var searchResults: [RestaurantMO] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tableView.estimatedRowHeight = 80.0
//        tableView.rowHeight = UITableView.automaticDimension
        
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search restaurants..."
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Fetch data from data store
        let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil,
                              cacheName: nil)
            fetchResultController.delegate = self
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    restaurants = fetchedObjects
                }
            } catch {
                print(error)
            }
        }
        
        prepareNotification()
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        navigationController?.hidesBarsOnSwipe = true
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            return
        }
        
        if let pageViewController =
            storyboard?.instantiateViewController(withIdentifier: "WalkthroughController")
                as? WalkthroughPageViewController {
            present(pageViewController, animated: true, completion: nil)
        }
    }
    
    
    func prepareNotification() {
        // Make sure the restaurant array is not empty
        if restaurants.count <= 0 {
            return
        }
        // Pick a restaurant randomly
        let randomNum = Int(arc4random_uniform(UInt32(restaurants.count)))
        let suggestedRestaurant = restaurants[randomNum]
        // Create the user notification
        let content = UNMutableNotificationContent()
        content.title = "Restaurant Recommendation"
        content.subtitle = "Try new food today"
        content.body = "I recommend you to check out \(suggestedRestaurant.name!). The restaurant is one of your favorites. It is located at \(suggestedRestaurant.location!). Would you like to give it a try?"
        content.sound = UNNotificationSound.default
        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFileURL = tempDirURL.appendingPathComponent("suggested-restaurant.jpg")
        if let image = UIImage(data: suggestedRestaurant.image! as Data) {
            try? image.jpegData(compressionQuality: 1.0)?.write(to: tempFileURL)
            if let restaurantImage = try? UNNotificationAttachment(identifier: "restaurantImage", url: tempFileURL, options: nil) {
                content.attachments = [restaurantImage]
            }
        }
        let categoryIdentifer = "foodpin.restaurantaction"
        let makeReservationAction = UNNotificationAction(identifier: "foodpin.makeReservation", title: "Reserve a table", options: [.foreground])
        let cancelAction = UNNotificationAction(identifier: "foodpin.cancel", title: "Later", options: [])
        let category = UNNotificationCategory(identifier: categoryIdentifer, actions:
            [makeReservationAction, cancelAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = categoryIdentifer
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "foodpin.restaurantSuggestion", content: content, trigger: trigger)
        // Schedule the notification
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive {
            return searchResults.count
        } else {
            return restaurants.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantTableViewCell
        
        // Determine if we get the restaurant from search result or the original array
        let restaurant = (searchController.isActive) ? searchResults[indexPath.row] : restaurants[indexPath.row]

        // Configure the cell...
        cell.nameLabel.text = restaurant.name
        cell.locationLabel.text = restaurant.location
        cell.typeLabel.text = restaurant.type
        if let restaurantImage = restaurant.image {
            cell.thumbnailImageView.image = UIImage(data: restaurantImage as Data)
        }
        cell.accessoryType = restaurant.isVisited ? .checkmark : .none

        return cell
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if searchController.isActive {
            return false
        } else {
            return true
        }
    }

    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Social Sharing Button
        let shareAction = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) -> Void in
            let defaultText = "Just checking in at " + self.restaurants[indexPath.row].name!
            guard let imageToShare = UIImage(data: self.restaurants[indexPath.row].image!) else { return }
            let activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
        }
        
        // Delete Button
        let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Delete",handler: { (action, indexPath) -> Void in
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                    let context = appDelegate.persistentContainer.viewContext
                    let restaurantToDelete = self.fetchResultController.object(at: indexPath)
                    context.delete(restaurantToDelete)
                    appDelegate.saveContext()
                }
        })
        
        shareAction.backgroundColor = UIColor(red: 48.0/255.0, green: 173.0/255.0,
                                              blue: 99.0/255.0, alpha: 1.0)
        deleteAction.backgroundColor = UIColor(red: 202.0/255.0, green: 202.0/255.0,
                                               blue: 203.0/255.0, alpha: 1.0)
        
        return [deleteAction, shareAction]
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            restaurants.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
   

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Table View Delegate Protocol
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // Add call action
//        let callActionHandler = { (action: UIAlertAction!) -> Void in
//            let alertMessage = UIAlertController(title: "Service Unavailable", message: "Sorry, the call feature is not available yet. Please retry later.", preferredStyle: .alert)
//            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alertMessage, animated: true, completion: nil)
//
//        }
//
//        // Check-in action
//        let checkInAction = UIAlertAction(title: "Check in", style: .default, handler:
//        {
//            (action:UIAlertAction!) -> Void in
//            let cell = tableView.cellForRow(at: indexPath)
//            cell?.accessoryType = .checkmark
//            self.restauratnIsVisited[indexPath.row] = true
//        })
//
//        // Create an option Menu as an action sheet
//        let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .actionSheet)
//
//        // Add actions to the menu
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        let callAction = UIAlertAction(title: "Call " + "123-000-\(indexPath.row)", style: .default, handler: callActionHandler)
//
//        optionMenu.addAction(cancelAction)
//        optionMenu.addAction(callAction)
//        optionMenu.addAction(checkInAction)
//
//        // Display the menu
//        present(optionMenu, animated: true, completion: nil)
//
//        // Deselect the row.
//        tableView.deselectRow(at: indexPath, animated: false)
//
//    }

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if segue.identifier == "showRestaurantDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let destinationController = segue.destination as! RestaurantDetailViewController
            // Pass the selected object to the new view controller.
            destinationController.restaurant = (searchController.isActive) ? searchResults[indexPath.row] : restaurants[indexPath.row]
            searchController.isActive = false
            destinationController.hidesBottomBarWhenPushed = true
        }
    }
    
    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Search
    func filterContent(for searchText: String) {
        searchResults = restaurants.filter({ (restaurant) -> Bool in
            if let name = restaurant.name, let location = restaurant.location, let type = restaurant.type {
                let isMatch = name.localizedCaseInsensitiveContains(searchText) || location.localizedCaseInsensitiveContains(searchText) || type.localizedCaseInsensitiveContains(searchText)
                return isMatch
            }
            
            return false
        })
    }
    
    
}


extension RestaurantTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?, for type:
        NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }
        if let fetchedObjects = controller.fetchedObjects {
            restaurants = fetchedObjects as! [RestaurantMO]
        }
    }
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}


extension RestaurantTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
    
    
}
