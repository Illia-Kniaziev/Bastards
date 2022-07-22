//
//  MainRouter.swift
//  Bastards
//
//  Created by Illia Kniaziev on 22.07.2022.
//

import Foundation
import UIKit

final class MainRouter: Router {
    
    var window: UIWindow?
    var navigator: Navigator
    
    init(navigator: Navigator, window: UIWindow) {
        self.window = window
        self.navigator = navigator
    }
    
    func toSelf() {
        let viewModel = MainViewModel(router: self)
        let controller = MainViewController(viewModel: viewModel)
        navigator.navigate(withNavigation: .launch(window: window), controller: controller, animated: false)
    }
    
}
