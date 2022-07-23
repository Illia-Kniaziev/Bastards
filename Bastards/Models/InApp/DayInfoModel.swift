//
//  DayInfoModel.swift
//  Bastards
//
//  Created by Illia Kniaziev on 23.07.2022.
//

import Foundation

struct DayInfo: Hashable {
    
    let day: Int
    let dateString: String
    let hottestDirection: String?
    let eliminated: Int
    let tanks: Int
    let trucks: Int
    let planes: Int
    let helicopter: Int
    let fieldArtillery: Int
    let mrl: Int
    let drone: Int
    let navalShip: Int
    let antiAircraftWarfare: Int
    let specialEquipment: Int?
    let cruiseMissiles: Int?
    
}
