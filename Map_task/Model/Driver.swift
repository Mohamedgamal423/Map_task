//
//  Driver.swift
//  Map_task
//
//  Created by moh on 4/13/21.
//  Copyright © 2021 moh. All rights reserved.
//

import Foundation

struct Driver {
    
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
