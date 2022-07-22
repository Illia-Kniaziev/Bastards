//
//  JSONReader.swift
//  Bastards
//
//  Created by Illia Kniaziev on 22.07.2022.
//

import Foundation

final class JSONReader {
    
    func readJson<T: Decodable>(
        forResource resource: String,
        usingDecoder decoder: JSONDecoder = JSONDecoder()
    ) -> T? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decodedValue = try? decoder.decode(T.self, from: data)
        else { return nil }
        
        return decodedValue
    }
    
}
