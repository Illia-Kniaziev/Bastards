//
//  DetailedRouter.swift
//  Bastards
//
//  Created by Illia Kniaziev on 23.07.2022.
//

import Foundation

final class DetailedRouter: Router {
    
    var navigator: Navigator
    var previousLosses: DayLosses
    var losses: DayLosses
    
    init(navigator: Navigator, losses: DayLosses, previousLosses: DayLosses) {
        self.navigator = navigator
        self.previousLosses = previousLosses
        self.losses = losses
    }
    
    func toSelf() {
        
    }
    
}
