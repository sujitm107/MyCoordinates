//
//  namedCoordinate.swift
//  Locations
//
//  Created by Sujit Molleti on 7/2/20.
//  Copyright © 2020 Sujit Molleti. All rights reserved.
//

import Foundation
import MapKit

class namedCoordinate {
    
    let name: String
    let coordinate: CLLocationCoordinate2D
    
    init(name: String, coordinate: CLLocationCoordinate2D){
        self.name = name
        self.coordinate = coordinate
    }
    
}
