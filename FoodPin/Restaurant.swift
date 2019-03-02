//
//  Restaurant.swift
//  FoodPin
//
//  Created by William Kpabitey Kwabla on 3/2/19.
//  Copyright © 2019 William Kpabitey Kwabla. All rights reserved.
//

import Foundation


class Restaurant {
    var name = ""
    var type = ""
    var location = ""
    var image = ""
    var isVisited = false
    
    init(name: String, type: String, location: String, image: String, isVisited: Bool) {
        self.name = name
        self.type = type
        self.location = location
        self.image = image
        self.isVisited = isVisited
    }
}
