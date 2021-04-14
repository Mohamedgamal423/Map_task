//
//  Driverannotation.swift
//  Map_task
//
//  Created by moh on 4/14/21.
//  Copyright © 2021 moh. All rights reserved.
//

import MapKit
import UIKit

class Driverannot: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
