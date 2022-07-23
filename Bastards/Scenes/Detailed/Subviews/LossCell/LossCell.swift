//
//  LossCell.swift
//  Bastards
//
//  Created by Illia Kniaziev on 23.07.2022.
//

import UIKit

class LossCell: UITableViewCell {

    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    func configureWith(icon: String, title: String, amount: Int) {
        iconLabel.text = icon
        titleLabel.text = title
        amountLabel.text = "+\(amount)"
    }
    
}
