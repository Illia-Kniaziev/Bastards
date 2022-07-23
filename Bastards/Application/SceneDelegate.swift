//
//  SceneDelegate.swift
//  Bastards
//
//  Created by Illia Kniaziev on 22.07.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let navigator = Navigator()
        let service = NetworkingService()
        let router = MainRouter(navigator: navigator, window: window, networkingService: service)
        router.toSelf()
    }
    
}

