//
//  EquipmentRequest.swift
//  Bastards
//
//  Created by Illia Kniaziev on 23.07.2022.
//

import Foundation

final class EquipmentRequest: DecodableRequest<[Equipment]> {
    init(decoder: JSONDecoder) {
        super.init(endpoint: APIPath.equipment, method: .get, decoder: decoder)
    }
}
