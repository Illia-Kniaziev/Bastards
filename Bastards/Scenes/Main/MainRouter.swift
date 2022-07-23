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
    var networkingService: NetworkingServiceProtocol
    
    init(navigator: Navigator, window: UIWindow, networkingService: NetworkingServiceProtocol) {
        self.window = window
        self.navigator = navigator
        self.networkingService = networkingService
    }
    
    func toSelf() {
        let viewModel = MainViewModel(router: self, networkingService: networkingService)
        let vc = MainViewController(viewModel: viewModel)
        let nc = UINavigationController(rootViewController: vc)
        navigator.navigate(withNavigation: .launch(window: window), controller: nc, animated: false)
    }
    
    func toDetails(usingDayInfo dayInfo: DayInfo) {
        let router = DetailedRouter(dayInfo: dayInfo, navigator: navigator)
        router.toSelf()
    }
    
}
