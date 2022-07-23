//
//  NetworkingService.swift
//  Bastards
//
//  Created by Illia Kniaziev on 23.07.2022.
//

import Combine
import Foundation

final class NetworkingService: NetworkingServiceProtocol {
    
    enum NetworkingError: Error {
        case error(Error)
        case noResponse
        case unacceptableStatusCode(Int)
        case incompleteJWTResponse
    }
    
    var requestTimeout: TimeInterval = 30
    
    func request<T>(_ request: T) -> AnyPublisher<Data, Error> where T : NetworkingRequest {
        do {
            let urlRequest = try request.buildRequest()
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = requestTimeout
            
            return URLSession(configuration: config)
                .dataTaskPublisher(for: urlRequest)
                .tryMap { data, response in
                    guard let response = response as? HTTPURLResponse
                    else { throw NetworkingError.noResponse }
                    
                    if !(200...299 ~= response.statusCode) {
                        throw NetworkingError.unacceptableStatusCode(response.statusCode)
                    }
                    
                    return data
                }
                .eraseToAnyPublisher()
                
        } catch let e {
            return Fail(outputType: Data.self, failure: NetworkingError.error(e))
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
}
