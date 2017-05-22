//
//  TradeTableCell.swift
//  EtherView
//
//  Created by James McNamee on 22/5/17.
//  Copyright © 2017 James McNamee. All rights reserved.
//

import UIKit

final class TradeTableCell: UITableViewCell {
    @IBOutlet weak var infoLabel: UILabel!
    
    var cellData: String = "" {
        didSet {
            layoutCell()
        }
    }
    
    private func layoutCell() {
        infoLabel.text = String(cellData)
    }
}
