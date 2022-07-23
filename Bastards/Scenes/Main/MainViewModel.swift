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
    @Published var losses: [DayLosses] = []
    
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
    
    func fetchModels() {
        state = .ongoing
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            let reader = JSONReader()
            
            if var eq: [Equipment] = reader.readJson(forResource: LocalJSONPaths.equipment.rawValue, usingDecoder: self.decoder),
               let pers: [Personnel] = reader.readJson(forResource: LocalJSONPaths.personnel.rawValue, usingDecoder: self.decoder) {
                // keeping in mind some uncertainty about the 'day' field we gotta get rid of corrupted documents
                eq = eq.filter { $0.day != 0 }
                
                let personnelLookupTable = pers.reduce(into: [Int : Personnel]()) { dict, personnel in
                    dict[personnel.day] = personnel
                }
                
                self.losses = eq
                    .compactMap { equipment in
                        if let personnel = personnelLookupTable[equipment.day] {
                            return DayLosses(day: equipment.day, equipment: equipment, personnel: personnel)
                        }
                        
                        return nil
                    }
                    .sorted { rhs, lhs in
                        rhs.day < rhs.day
                    }
                
                self.state = .succeded
            } else {
                self.state = .failed
            }
        }
        
        
    }
    
}
