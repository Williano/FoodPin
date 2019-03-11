//
//  WalkthroughContentViewController.swift
//  FoodPin
//
//  Created by William Kpabitey Kwabla on 3/10/19.
//  Copyright © 2019 William Kpabitey Kwabla. All rights reserved.
//

import UIKit

class WalkthroughContentViewController: UIViewController {
    
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var contentImageView: UIImageView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var forwardButton: UIButton!
    
    var index = 0
    var heading = ""
    var content = ""
    var imageFile = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        headingLabel.text = heading
        contentLabel.text = content
        contentImageView.image = UIImage(named: imageFile)
        
        pageControl.currentPage = index
        
        switch index {
        case 0...1: forwardButton.setTitle("NEXT", for: .normal)
        case 2: forwardButton.setTitle("DONE", for: .normal)
        default: break
        }
    }
    @IBAction func nextButtonTapped(sender: UIButton) {
        switch index {
        case 0...1:
            let pageViewController = parent as! WalkthroughPageViewController
            pageViewController.forward(index: index)
        case 2:
            UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
            dismiss(animated: true, completion: nil)
        default: break
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
