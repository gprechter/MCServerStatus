//
//  ServerTableViewCell.swift
//  MinecraftServerStatus
//
//  Created by Griffin Prechter on 7/28/18.
//  Copyright © 2018 Griffin Prechter. All rights reserved.
//

import UIKit

class ServerTableViewCell: UITableViewCell {

    @IBOutlet weak var statusIndicator: UIStatusView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var playersLabel: UILabel!
    @IBOutlet weak var motdLabel: UILabel!
    @IBOutlet weak var addressTextField: AddressTextField!

}
