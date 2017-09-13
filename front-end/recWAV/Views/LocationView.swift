//
//  LocationView.swift
//  NoisyGenX
//
//  Created by AnGie on 5/2/17.
//  Copyright © 2017 AnGie. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class LocationView: UIView {

    var mapView: GMSMapView!
    var locations:[String:[String:String]]!
    var formatter:DateFormatter!
    
    /* default when permission not granted */
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
}

