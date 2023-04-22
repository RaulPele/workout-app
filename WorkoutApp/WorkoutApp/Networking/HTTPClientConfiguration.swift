//
//  HTTPClientConfiguration.swift
//  WorkoutApp
//
//  Created by Raul Pele on 22.04.2023.
//

import Foundation

protocol HTTPClientConfiguration {
    
    var serverURL: URL { get }
    var validStatusCodes: ClosedRange<Int> { get }
    var timeoutInterval: TimeInterval { get }
    
}

extension HTTPClientConfiguration {
    
    var timeoutInterval: TimeInterval {
        return 30.0
    }
    
    func isValidStatusCode(_ statusCode: Int) -> Bool {
        return validStatusCodes.contains(statusCode)
    }
}

struct DefaultClientConfiguration: HTTPClientConfiguration {
    
    let serverURL: URL
    let validStatusCodes: ClosedRange<Int> = (200...299)
    
    init(serverURL: URL) {
        self.serverURL = serverURL
    }
    
    init() {
        self.serverURL = .init(string: "")! //TODO: replace
    }
}
