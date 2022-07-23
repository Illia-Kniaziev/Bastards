//
//  DayInfoCell.swift
//  Bastards
//
//  Created by Illia Kniaziev on 23.07.2022.
//

import UIKit

class DayInfoCell: UITableViewCell {
    
    static let identifier = "DayInfoCell"

    //MARK: outlets
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hottestDirectionLabel: UILabel!
    
    @IBOutlet var infoStack: [UIStackView]!
    
    @IBOutlet weak var eliminatedAmountLabel: UILabel!
    @IBOutlet weak var tanksAmountLabel: UILabel!
    @IBOutlet weak var trucksAmountLabel: UILabel!
    @IBOutlet weak var planesAmountLabel: UILabel!
 
    func configure(withModel model: DayInfo) {
        dayNumberLabel.text = "day #\(model.day)"
        dateLabel.text = model.dateString
        
        eliminatedAmountLabel.text = "+\(model.eliminated)"
        tanksAmountLabel.text = "+\(model.tanks)"
        trucksAmountLabel.text = "+\(model.trucks)"
        planesAmountLabel.text = "+\(model.planes)"
        
        if let hottestDirection = model.hottestDirection {
            hottestDirectionLabel.text = hottestDirection + "🔥"
        } else {
            //to avoid incorrect data after reuse
            hottestDirectionLabel.text = nil
        }
        
        infoStack.forEach {
            $0.layer.cornerRadius = 10
        }
        
    }
    
}
