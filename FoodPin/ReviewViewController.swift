//
//  ReviewViewController.swift
//  FoodPin
//
//  Created by William Kpabitey Kwabla on 3/3/19.
//  Copyright © 2019 William Kpabitey Kwabla. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var restaurantImageView: UIImageView!
    @IBOutlet var closeReviewButton: UIButton!
    
    var restaurant: Restaurant!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backgroundImageView.image? = UIImage(named: restaurant.image)!
        restaurantImageView.image? = UIImage(named: restaurant.image)!
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        let scaleTransform = CGAffineTransform.init(scaleX: 0, y: 0)
        let translateTransform = CGAffineTransform.init(translationX: 0, y: 1000)
        let combineTransform = scaleTransform.concatenating(translateTransform)
        containerView.transform = combineTransform
    }
    
    override func viewDidAppear(_ animated: Bool) {
        closeReviewButton.transform = CGAffineTransform(translationX: 1000, y: 0)
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = CGAffineTransform.identity
        }
        
        UIView.animate(withDuration: 1.0) {
            self.closeReviewButton.transform = CGAffineTransform.identity
        }
//        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.3,
//                       initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
//                        self.containerView.transform = CGAffineTransform.identity
//        }, completion: nil)
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
