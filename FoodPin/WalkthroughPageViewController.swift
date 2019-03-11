//
//  WalkthroughPageViewController.swift
//  FoodPin
//
//  Created by William Kpabitey Kwabla on 3/10/19.
//  Copyright © 2019 William Kpabitey Kwabla. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var pageHeadings = ["Personalize", "Locate", "Discover"]
    var pageImages = ["foodpin-intro-1", "foodpin-intro-2", "foodpin-intro-3"]
    var pageContent = ["Pin your favorite restaurants and create your own food guide", "Search and locate your favourite restaurant on Maps", "Find restaurants pinned by your friends and other foodies around the world"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Set the data source to itself
        dataSource = self
        
        // Create the first walkthrough screen
        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Page View Controller Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        return contentViewController(at: index)
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        return contentViewController(at: index)
    }
    
    
    func contentViewController(at index: Int) -> WalkthroughContentViewController?
    {
        if index < 0 || index >= pageHeadings.count {
            return nil
        }
        // Create a new view controller and pass suitable data.
        if let pageContentViewController =
            storyboard?.instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController {
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.content = pageContent[index]
            pageContentViewController.index = index
            return pageContentViewController
        }
        return nil
    }
    
    
    func forward(index: Int) {
        if let nextViewController = contentViewController(at: index + 1) {
            setViewControllers([nextViewController], direction: .forward, animated:
                true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

