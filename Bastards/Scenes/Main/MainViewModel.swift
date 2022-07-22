//
//  MainViewModel.swift
//  Bastards
//
//  Created by Illia Kniaziev on 22.07.2022.
//

import Combine
import Foundation

final class MainViewModel {
    
    enum FetchingState {
        case initial
        case ongoing
        case succeded
        case failed
    }
    
    @Published var state: FetchingState = .initial
    @Published var equipment: [Equipment] = []
    
    private let router: MainRouter
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    
    init(router: MainRouter) {
        self.router = router
    }
    
    func fetchEquipment() {
        state = .ongoing
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            let reader = JSONReader()
            if let structs: [Equipment] = reader.readJson(forResource: LocalJSONPaths.equipment.rawValue,
                                                          usingDecoder: self.decoder) {
                // keeping in mind some uncertainty about the 'day' field we gotta get rid of corrupted documents
                self.state = .succeded
                self.equipment = structs.filter { $0.day != 0 }
            } else {
                self.state = .failed
            }
            
        }
    }
    
}
