//
//  PopoutMenuViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 10/30/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit

final class PopoutMenuViewController: UIViewController {
    
    // MARK: - View Model
    
    struct ViewModel {
        static var cellInfo: [[[String: String]]] = []
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet private var headerView: UIView! {
        didSet {
            headerView.backgroundColor = UIColor(patternImage: UIImage(named: "bg1")!)
        }
    }
    
    @IBOutlet private var nameLabel: UILabel! {
        didSet {
            nameLabel.text = UserDefaults.standard.value(forKey: "User Name") as? String
        }
    }
    
    @IBOutlet private var emailLabel: UILabel! {
        didSet {
            emailLabel.text = UserDefaults.standard.value(forKey: "User Email") as? String
        }
    }
    
    @IBOutlet private var popupView: UIView! {
        didSet {
            popupView.layer.masksToBounds = false
            popupView.layer.shadowColor = UIColor.black.cgColor
            popupView.layer.shadowOpacity = 0.5
            popupView.layer.shadowOffset = CGSize(width: 7, height: 5)
        }
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate / UITableViewDataSource

extension PopoutMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionsCell", for: indexPath) as! OptionsCell
        
        cell.optionLabel.text = ViewModel.cellInfo[indexPath.section][indexPath.row]["Label"]
        cell.optionIcon.image = UIImage(named: ViewModel.cellInfo[indexPath.section][indexPath.row]["Icon"]!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true)
        let viewController = presentingViewController!.children[0] as! SafetyZonesViewController
        viewController.modalSegue(segue: ViewModel.cellInfo[indexPath.section][indexPath.row]["Segue"]!)
    }
}

final class OptionsCell: UITableViewCell {
    @IBOutlet fileprivate var optionIcon: UIImageView!
    @IBOutlet fileprivate var optionLabel: UILabel!
}
