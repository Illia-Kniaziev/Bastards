//
//  DetailedRouter.swift
//  Bastards
//
//  Created by Illia Kniaziev on 23.07.2022.
//

import Foundation

final class DetailedRouter: Router {
    
    var navigator: Navigator
    var dayInfo: DayInfo
    
    init(dayInfo: DayInfo, navigator: Navigator) {
        self.navigator = navigator
        self.dayInfo = dayInfo
    }
    
    func toSelf() {
        let viewModel = DetailedViewModel(dayInfo: dayInfo, router: self)
        let controller = DetailedViewController(viewModel: viewModel)
        navigator.navigate(withNavigation: .push, controller: controller, animated: true)
    }
    
}
