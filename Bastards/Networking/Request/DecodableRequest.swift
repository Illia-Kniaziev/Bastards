//
//  DecodableRequest.swift
//  Bastards
//
//  Created by Illia Kniaziev on 23.07.2022.
//

import Combine
import Foundation

class DecodableRequest<T: Decodable>: NetworkingRequest {
    
    typealias ReturnType = T

    var endpoint: String
    var method: HTTPMethod
    var headers: Headers
    var queryItems: [URLQueryItem]?
    var body: Data?
    var decoder: JSONDecoder
    
    init(
        endpoint: String,
        method: HTTPMethod,
        headers: Headers = [:],
        queryItems: [URLQueryItem]? = nil,
        body: Body? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.endpoint = endpoint
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = try? JSONEncoder().encode(body)
        self.decoder = decoder
        
        self.headers = ["Content-Type" : "application/json"]
        headers.forEach { key, value in
            self.headers[key] = value
        }
    }
    
    func perform(byService service: NetworkingServiceProtocol) -> AnyPublisher<ReturnType, Error> {
        service.request(self)
            .decode(type: ReturnType.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func buildRequest() throws -> URLRequest {
        guard var components = URLComponents(string: endpoint)
        else { throw RequestError.failedToCreateUrl }
        
        components.queryItems = queryItems
        
        guard let url = components.url
        else { throw RequestError.failedToCreateUrl }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers

        if method != .get {
            request.httpBody = body
        }
        
        return request
    }
    
}
