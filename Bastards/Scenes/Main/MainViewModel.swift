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
    
    enum SortingStrategy: String {
        case ascending = "Ascending"
        case descending = "Descending"
        case topEliminated = "Top eliminated"
    }
    
    //MARK: - published properties
    @Published var state: FetchingState = .initial
    @Published var lossesInfo: [DayInfo] = []
    
    @Published var lossBounds: (Int, Int)? = nil
    @Published var currentLoss: Int = 0
    @Published var progress: Float = 0
    
    //MARK: - private properties
    private let lossStep = 5000.0
    private let router: MainRouter
    private let networkingService: NetworkingServiceProtocol
    private var subscriptions = Set<AnyCancellable>()
    
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
    init(router: MainRouter, networkingService: NetworkingServiceProtocol) {
        self.router = router
        self.networkingService = networkingService
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
    
    func openDetails(forIndex index: Int) {
        let model = lossesInfo[index]
        router.toDetails(usingDayInfo: model)
    }
    
    //MARK: - sorting
    func sort(usingStrategy strategy: SortingStrategy) {
        switch strategy {
        case .ascending:
            lossesInfo.sort { lhs, rhs in
                lhs.day < rhs.day
            }
        case .descending:
            lossesInfo.sort { lhs, rhs in
                lhs.day > rhs.day
            }
        case .topEliminated:
            lossesInfo.sort { lhs, rhs in
                lhs.eliminated > rhs.eliminated
            }
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
        
        let losses: [DayLosses] = eq
            .compactMap { equipment in
                if let personnel = personnelLookupTable[equipment.day] {
                    return DayLosses(day: equipment.day, date: equipment.date, equipment: equipment, personnel: personnel)
                }
                
                return nil
            }
        
        let lossesLookupTable = losses.reduce(into: [Int : DayLosses]()) { dict, info in
            dict[info.day] = info
        }
        
        self.lossesInfo = losses
            .compactMap { self.prepareDayInfo(forDay: $0.day, userLossesLookupTable: lossesLookupTable) }
            .sorted { lhs, rhs in
                lhs.day > rhs.day
            }
        
        if let amount = personnel.last?.personnel {
            self.processLosses(forAmount: amount)
        }
        
        self.state = .succeded
    }
    
    //MARK: - daily stats
    ///creates day losses model
    private func prepareDayInfo(forDay day: Int, userLossesLookupTable lossesLookupTable: [Int : DayLosses]) -> DayInfo? {
        guard let todayLosses = lossesLookupTable[day] else { return nil }
        
        let dateString: String = {
            if Calendar.current.isDateInToday(todayLosses.date) {
                return "today"
            } else if Calendar.current.isDateInYesterday(todayLosses.date) {
                return "yesterday"
            }
            
            return dateFormatter.string(from: todayLosses.date)
        }()
        
        if let previousLosses = lossesLookupTable[day - 1] {
            let trucks = getDailyIncrease(basedOnToday: todayLosses.equipment.vehiclesAndFuelTanks,
                                          yesterday: previousLosses.equipment.vehiclesAndFuelTanks)
            let specialEquipment = getDailyIncrease(basedOnToday: todayLosses.equipment.specialEquipment,
                                                    yesterday: previousLosses.equipment.specialEquipment)
            let cruiseMissiles = getDailyIncrease(basedOnToday: todayLosses.equipment.cruiseMissiles,
                                                  yesterday: previousLosses.equipment.cruiseMissiles)
            return DayInfo(
                day: day,
                dateString: dateString,
                hottestDirection: todayLosses.equipment.greatestLossesDirection,
                eliminated: todayLosses.personnel.personnel - previousLosses.personnel.personnel,
                tanks: todayLosses.equipment.tank - previousLosses.equipment.tank,
                trucks: trucks ?? 0,
                planes: todayLosses.equipment.aircraft - previousLosses.equipment.aircraft,
                helicopter: todayLosses.equipment.helicopter - previousLosses.equipment.helicopter,
                fieldArtillery: todayLosses.equipment.fieldArtillery - previousLosses.equipment.fieldArtillery,
                mrl: todayLosses.equipment.mrl - previousLosses.equipment.mrl,
                drone: todayLosses.equipment.drone - previousLosses.equipment.drone,
                navalShip: todayLosses.equipment.navalShip - previousLosses.equipment.navalShip,
                antiAircraftWarfare: todayLosses.equipment.antiAircraftWarfare - previousLosses.equipment.antiAircraftWarfare,
                specialEquipment: specialEquipment,
                cruiseMissiles: cruiseMissiles
            )
        }
        return DayInfo(
            day: day,
            dateString: dateString,
            hottestDirection: todayLosses.equipment.greatestLossesDirection,
            eliminated: todayLosses.personnel.personnel,
            tanks: todayLosses.equipment.tank,
            trucks: todayLosses.equipment.vehiclesAndFuelTanks ?? 0,
            planes: todayLosses.equipment.aircraft,
            helicopter: todayLosses.equipment.helicopter,
            fieldArtillery: todayLosses.equipment.fieldArtillery,
            mrl: todayLosses.equipment.mrl,
            drone: todayLosses.equipment.drone,
            navalShip: todayLosses.equipment.navalShip,
            antiAircraftWarfare: todayLosses.equipment.antiAircraftWarfare,
            specialEquipment: todayLosses.equipment.specialEquipment,
            cruiseMissiles: todayLosses.equipment.cruiseMissiles
        )
        
    }
    
    private func getDailyIncrease(basedOnToday today: Int?, yesterday: Int?) -> Int? {
        if let today = today {
            if let yesterday = yesterday {
                return today - yesterday
            }
            return today
        }
        return nil
    }
    
    private func processLosses(forAmount amount: Int) {
        currentLoss = amount
        let lowerBound = floor(Double(currentLoss) / lossStep) * lossStep
        let upperBound = lowerBound + lossStep
        lossBounds = (Int(lowerBound), Int(upperBound))
        progress = Float((Double(currentLoss) - lowerBound) / lossStep)
    }
    
}
