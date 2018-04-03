//
//  PopoutMenuCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 10/30/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation

final class PopoutMenuCoordinator: NSObject {
    private typealias ViewModel = PopoutMenuViewController.ViewModel
    @IBOutlet weak private var viewController: PopoutMenuViewController!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        ViewModel.cellInfo = populateCellInfo()
    }
    
    private func populateCellInfo() -> [[[String: String]]] {
        let configPath = Bundle.main.path(forResource: "menu_config", ofType: "json")
        
        let configData = try! String(contentsOfFile: configPath!, encoding: .utf8).data(using: .utf8)
    
        let deserializedConfig = try! JSONSerialization.jsonObject(with: configData!, options: .allowFragments) as! [[Any]]
        
        let expectedConfig: [[[String: String]]] = deserializedConfig.flatMap {
            $0.flatMap { $0 as? [String: String] }
        }
        
        return expectedConfig
    }
}