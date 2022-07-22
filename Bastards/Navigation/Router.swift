//
//  Router.swift
//  Bastards
//
//  Created by Illia Kniaziev on 22.07.2022.
//

protocol Router {
    
    var navigator: Navigator { get }
    
    func toSelf()
    
}
