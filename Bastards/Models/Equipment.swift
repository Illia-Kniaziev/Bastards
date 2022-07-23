//
//  Equipment.swift
//  Bastards
//
//  Created by Illia Kniaziev on 22.07.2022.
//

import Foundation

struct Equipment: Decodable, Hashable {
    
    let date: Date
    let day: Int
    let aircraft: Int
    let helicopter: Int
    let tank: Int
    let apc: Int
    let fieldArtillery: Int
    let mrl: Int
    let drone: Int
    let navalShip: Int
    let antiAircraftWarfare: Int
    
//    let militaryAuto: Int?
//    let fuelTank: Int?
    let vehiclesAndFuelTanks: Int?
    
    let specialEquipment: Int?
    let cruiseMissiles: Int?
    let greatestLossesDirection: String?
    
    enum CodingKeys: String, CodingKey {
        case date
        case day
        case aircraft
        case helicopter
        case tank
        case drone
        
        case apc = "APC"
        case fieldArtillery = "field artillery"
        case mrl = "MRL"
        case navalShip = "naval ship"
        case antiAircraftWarfare = "anti-aircraft warfare"
        
        //interchangeable fields
        case militaryAuto = "military auto"
        case fuelTank = "fuel tank"
        case vehiclesAndFuelTanks = "vehicles and fuel tanks"
        
        //optional fields
        case specialEquipment = "special equipment"
        case cruiseMissiles = "cruise missiles"
        case greatestLossesDirection = "greatest losses direction"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        date = try values.decode(Date.self, forKey: .date)
        aircraft = try values.decode(Int.self, forKey: .aircraft)
        helicopter = try values.decode(Int.self, forKey: .helicopter)
        tank = try values.decode(Int.self, forKey: .tank)
        drone = try values.decode(Int.self, forKey: .drone)
        apc = try values.decode(Int.self, forKey: .apc)
        fieldArtillery = try values.decode(Int.self, forKey: .fieldArtillery)
        mrl = try values.decode(Int.self, forKey: .mrl)
        navalShip = try values.decode(Int.self, forKey: .navalShip)
        antiAircraftWarfare = try values.decode(Int.self, forKey: .antiAircraftWarfare)
        
        specialEquipment = try? values.decode(Int.self, forKey: .specialEquipment)
        cruiseMissiles = try? values.decode(Int.self, forKey: .cruiseMissiles)
        greatestLossesDirection = try? values.decode(String.self, forKey: .greatestLossesDirection)
        
        //there are some cases when day is a string, so we need to handle this
        if let intValue = try? values.decode(Int.self, forKey: .day) {
            day = intValue
        } else if let stringValue = try? values.decode(String.self, forKey: .day),
                  let intValue = Int(stringValue) {
            day = intValue
        } else {
            day = 0
        }
        
        //generalize interchangeable fields
        if let vehiclesAndFuelTanks = try? values.decode(Int.self, forKey: .vehiclesAndFuelTanks) {
            self.vehiclesAndFuelTanks = vehiclesAndFuelTanks
        } else if let militaryAuto = try? values.decode(Int.self, forKey: .militaryAuto),
                  let fuelTank = try? values.decode(Int.self, forKey: .fuelTank) {
            self.vehiclesAndFuelTanks = militaryAuto + fuelTank
        } else {
            self.vehiclesAndFuelTanks = nil
        }
    }
    
}
