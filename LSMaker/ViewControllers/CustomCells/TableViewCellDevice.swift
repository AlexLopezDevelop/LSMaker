//
//  TableViewCellDevice.swift
//  LSMaker
//
//  Created by Alex Lopez on 28/10/2020.
//  Copyright © 2020 Alex Lopez. All rights reserved.
//

import UIKit

class TableViewCellDevice: UITableViewCell {

    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var serialNumber: UILabel!
    @IBOutlet weak var rssiNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
