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
    
    //MARK: - published properties
    @Published var state: FetchingState = .initial
    @Published var losses: [DayLosses] = []
    
    //MARK: - private properties
    private var lossesLookupTable = [Int : DayLosses]()
    private var subscriptions = Set<AnyCancellable>()
    private let router: MainRouter
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()
    
    //MARK: - init
    init(router: MainRouter) {
        self.router = router
    }
    
    //MARK: - public methods
    ///starts consequent fetching of equipment and personnel and triggers processing pipe
    func fetchModels() {
        state = .ongoing
        
        EquipmentRequest(decoder: decoder)
            .perform(byService: NetworkingService())
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print(error)
                    self?.state = .failed
                }
            } receiveValue: { [weak self] equipment in
                self?.fetchPersonnel(keepingEquipment: equipment)
            }
            .store(in: &subscriptions)
        
    }
    
    ///creates day losses increase model
    func prepareDayInfo(forDay day: Int) -> DayInfo? {
        guard let todayLosses = lossesLookupTable[day] else { return nil }
        
        let dateString = dateFormatter.string(from: todayLosses.date)
        
        if let previousLosses = lossesLookupTable[day - 1] {
            let trucks: Int = {
                if let todayVehiclesAndFuelTanks = todayLosses.equipment.vehiclesAndFuelTanks {
                    if let prevVehiclesAndFuelTanks = previousLosses.equipment.vehiclesAndFuelTanks {
                        return todayVehiclesAndFuelTanks - prevVehiclesAndFuelTanks
                    }
                    
                    return todayVehiclesAndFuelTanks
                }
                
                return 0
            }()
            
            return DayInfo(
                day: day,
                dateString: dateString,
                hottestDirection: todayLosses.equipment.greatestLossesDirection,
                eliminated: todayLosses.personnel.personnel - previousLosses.personnel.personnel,
                tanks: todayLosses.equipment.tank - previousLosses.equipment.tank,
                trucks: trucks,
                planes: todayLosses.equipment.aircraft - previousLosses.equipment.aircraft
            )
        } else {
            return DayInfo(
                day: day,
                dateString: dateString,
                hottestDirection: todayLosses.equipment.greatestLossesDirection,
                eliminated: todayLosses.personnel.personnel,
                tanks: todayLosses.equipment.tank,
                trucks: todayLosses.equipment.vehiclesAndFuelTanks ?? 0,
                planes: todayLosses.equipment.aircraft
            )
        }
        
    }
    
    //MARK: - private methods
    private func fetchPersonnel(keepingEquipment equipment: [Equipment]) {
        PersonnelRequest(decoder: decoder)
            .perform(byService: NetworkingService())
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print(error)
                    self?.state = .failed
                }
            } receiveValue: { [weak self] personnel in
                self?.processLossesData(personnel: personnel, equipment: equipment)
            }
            .store(in: &subscriptions)
    }
    
    ///maps given personnel and equipment losses and publishes them into `losses`
    private func processLossesData(personnel: [Personnel], equipment: [Equipment]) {
        let eq = equipment.filter { $0.day != 0 }
        
        let personnelLookupTable = personnel.reduce(into: [Int : Personnel]()) { dict, personnel in
            dict[personnel.day] = personnel
        }
        
        self.losses = eq
            .compactMap { equipment in
                if let personnel = personnelLookupTable[equipment.day] {
                    return DayLosses(day: equipment.day, date: equipment.date, equipment: equipment, personnel: personnel)
                }
                
                return nil
            }
            .sorted { rhs, lhs in
                rhs.day < rhs.day
            }
        
        self.state = .succeded
        
        self.lossesLookupTable = self.losses.reduce(into: [Int : DayLosses]()) { dict, info in
            dict[info.day] = info
        }
    }
    
}
