//
//  DataTransport.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-15.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public protocol DataTransport {
    typealias ReadHandler = (Data) -> Void
    
    func write(_ data: Data)
    func setReaderHandler(_ handler: @escaping ReadHandler)
}
