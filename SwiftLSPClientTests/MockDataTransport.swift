//
//  MockDataTransport.swift
//  SwiftLSPClientTests
//
//  Created by Matt Massicotte on 2019-02-07.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation
import JSONRPC

class MockDataTransport: DataTransport {
    var writtenData: [Data]
    var readHandler: ReadHandler?

    init() {
        self.writtenData = []
        self.readHandler = nil
    }

    func write(_ data: Data) {
        writtenData.append(data)
    }

    func setReaderHandler(_ handler: @escaping ReadHandler) {
        readHandler = handler
    }

    func close() {
    }

    func mockRead(_ data: Data) {
        self.readHandler?(data)
    }

    func mockRead(_ string: String) {
        mockRead(string.data(using: .utf8)!)
    }
}
