//
//  SafetyZoneAnnotation.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/12/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation
import MapKit

final class SafetyZoneAnnotation: NSObject, MKAnnotation {
    let location: Location
    var coordinate: CLLocationCoordinate2D
    
    init(location: Location) {
        self.location = location
        self.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
}
