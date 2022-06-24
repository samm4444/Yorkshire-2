//
//  Global.swift
//  Yorkshire 2
//
//  Created by Samuel Miller on 19/06/2022.
//

import UIKit
import CoreLocation
import MapKit

class Global: NSObject {
        
    var yorkshirePolygon = MKPolygon()
    
    var circleOrigins = Array<CLLocationCoordinate2D>()
    
    static let Data = Global()

}
