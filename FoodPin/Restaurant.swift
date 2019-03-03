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
    var phone = ""
    var image = ""
    var rating = ""
    var isVisited = false
    
    init(name: String, type: String, location: String, phone: String, image: String, isVisited: Bool) {
        self.name = name
        self.type = type
        self.location = location
        self.phone = phone
        self.image = image
        self.isVisited = isVisited
    }
}
