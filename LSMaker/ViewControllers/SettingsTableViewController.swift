//
//  SettingsTableViewController.swift
//  LSMaker
//
//  Created by Alex Lopez on 23/5/21.
//  Copyright © 2021 Alex Lopez. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var deviceStatusLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    
    }
    
    func setupView() {
        deviceNameLabel.text = drivingDataManager.name
        if drivingDataManager.status {
            deviceStatusLabel.text = "Conectado"
            deviceStatusLabel.textColor = UIColor.green
        }
    }
    
    @IBAction func disconectDeviceButton(_ sender: Any) {
        drivingDataManager.status = false
        dismiss(animated: true, completion: nil)
    }
}
