//
//  SafetyZoneAnnotationView.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/12/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation
import UIKit

final class SafetyZoneAnnotationView: UIView {
    @IBOutlet weak var showDetailButton: UIButton!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationPhone: UILabel!
    @IBOutlet weak var locationAddress: UILabel!
    
    @IBOutlet weak var annotationView: UIView! {
        didSet {
            annotationView.layer.borderColor = UIColor.black.cgColor
            annotationView.layer.borderWidth = 1
            annotationView.layer.cornerRadius = 5
            annotationView.layer.shadowColor = UIColor.black.cgColor
            annotationView.layer.shadowOpacity = 0.5
            annotationView.layer.shadowRadius = 1
            annotationView.layer.shadowOffset = CGSize(width: 3, height: 3)
        }
    }
}
