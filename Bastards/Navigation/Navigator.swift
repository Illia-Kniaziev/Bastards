//
//  Navigator.swift
//  Bastards
//
//  Created by Illia Kniaziev on 22.07.2022.
//

import UIKit

final class Navigator {
    
    //MARK: - Helper objects
    struct ModalNavigationConfig {
        let presentationStyle: UIModalPresentationStyle = .fullScreen
        let transition: UIModalTransitionStyle = .coverVertical
        let rootVC: UIViewController? = nil
    }
    
    enum NavigationType {
        case push
        case launch(window: UIWindow?)
        case modal(config: ModalNavigationConfig)
    }
    
    //MARK: - public properties
    var topViewController: UIViewController? {
        guard let window = window,
              var topVC = window.rootViewController
        else { return nil }
        
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        
        if let topVC = topVC as? UINavigationController {
            return topVC.topViewController
        }
        
        return topVC
    }
    
    var topNavigationController: UINavigationController? {
        topViewController?.navigationController
    }
    
    //MARK: - public methods
    func navigate(withNavigation navigation: NavigationType, controller: UIViewController, animated: Bool) {
        switch navigation {
        case .push:
            if let topNavigationController = topNavigationController {
                topNavigationController.pushViewController(controller, animated: animated)
            } else {
                print("⚠️ top vc is not embeded into a nc")
            }
        case .launch(let launchWindow):
            launchWindow?.rootViewController = controller
            launchWindow?.makeKeyAndVisible()
        case .modal(let config):
            let rootVC = config.rootVC == nil ? topViewController : config.rootVC
            
            controller.modalPresentationStyle = config.presentationStyle
            controller.modalTransitionStyle = config.transition
            
            rootVC?.present(controller, animated: animated)
        }
    }
        
    //MARK: - private properties
    private var window: UIWindow? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first
    }
}
