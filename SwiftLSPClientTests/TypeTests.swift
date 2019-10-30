//
//  TypeTests.swift
//  SwiftLSPClientTests
//
//  Created by Matt Massicotte on 2019-02-08.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import XCTest
@testable import SwiftLSPClient

class TypeTests: XCTestCase {
    func testSymbolInformation() {
        let json = """
{"id":2,"result":[{"name":"something","kind":12,"location":{"uri":"file:///hello.go","range":{"start":{"line":19,"character":5},"end":{"line":19,"character":13}}}}],"jsonrpc":"2.0"}
"""
        let data = json.data(using: .utf8)!
        let response = try! JSONDecoder().decode(JSONRPCResultResponse<DocumentSymbolResponse>.self, from: data)

        let location = Location(uri: "file:///hello.go", range: LSPRange(startPair: (19, 5), endPair: (19, 13)))
        let symbolInfo = SymbolInformation(name: "something", kind: 12, deprecated: nil, location: location, containerName: nil)
        XCTAssertEqual(response.result, DocumentSymbolResponse.symbolInformation([symbolInfo]))
    }
}
