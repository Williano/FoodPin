//
//  WebViewController.swift
//  FoodPin
//
//  Created by William Kpabitey Kwabla on 3/11/19.
//  Copyright © 2019 William Kpabitey Kwabla. All rights reserved.
//

import UIKit
import WebKit


class WebViewController: UIViewController {
    
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let url = URL(string: "https://madewithreactjs.com/") else {return}
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    override func loadView() {
        webView = WKWebView()
        view = webView
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
