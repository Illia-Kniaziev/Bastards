//
//  PersonnelRequest.swift
//  Bastards
//
//  Created by Illia Kniaziev on 23.07.2022.
//

import Foundation

final class PersonnelRequest: DecodableRequest<[Personnel]> {
    init(decoder: JSONDecoder) {
        super.init(endpoint: APIPath.personnel, method: .get, decoder: decoder)
    }
}
