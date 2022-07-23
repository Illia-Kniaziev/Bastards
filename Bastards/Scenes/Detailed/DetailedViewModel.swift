//
//  DetailedViewModel.swift
//  Bastards
//
//  Created by Illia Kniaziev on 23.07.2022.
//

import Combine
import UIKit

final class DetailedViewModel {
    
    @Published var lossModels = [LossModel]()
    
    private let dayInfo: DayInfo
    private let router: DetailedRouter
    
    init(dayInfo: DayInfo, router: DetailedRouter) {
        self.router = router
        self.dayInfo = dayInfo
    }
    
    func createLossModels() {
        DispatchQueue.global(qos: .userInteractive).async {
            var models = [LossModel]()
            models.append(LossModel(emoji: "🪖", title: "Bastards", amount: self.dayInfo.eliminated))
            models.append(LossModel(emoji: "🚜", title: "Tanks", amount: self.dayInfo.tanks))
            models.append(LossModel(emoji: "🚛", title: "Truks", amount: self.dayInfo.trucks))
            models.append(LossModel(emoji: "✈️", title: "Planes", amount: self.dayInfo.planes))
            models.append(LossModel(emoji: "🚁", title: "Helicopters", amount: self.dayInfo.helicopter))
            models.append(LossModel(emoji: "🧨", title: "Field artillery", amount: self.dayInfo.fieldArtillery))
            models.append(LossModel(emoji: "🚀", title: "Multiple Rocket Launchers", amount: self.dayInfo.mrl))
            models.append(LossModel(emoji: "🛸", title: "Drones", amount: self.dayInfo.drone))
            models.append(LossModel(emoji: "🚢", title: "Naval ships", amount: self.dayInfo.navalShip))
            models.append(LossModel(emoji: "💥", title: "Anti-aircraft warfare", amount: self.dayInfo.antiAircraftWarfare))
            
            if let specialEquipment = self.dayInfo.specialEquipment {
                models.append(LossModel(emoji: "⚙️", title: "Special equipment", amount: specialEquipment))
            }
            
            if let cruiseMissiles = self.dayInfo.cruiseMissiles {
                models.append(LossModel(emoji: "🚀", title: "Cruise Missiles", amount: cruiseMissiles))
            }
            
            self.lossModels = models
        }
    }
    
}
