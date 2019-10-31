//
//  JSONRPCLanguageServerTests.swift
//  SwiftLSPClientTests
//
//  Created by Matt Massicotte on 2019-10-30.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import XCTest
import SwiftLSPClient

class JSONRPCLanguageServerTests: XCTestCase {
    func testHoverRequest() throws {
        let dataTransport = MockDataTransport()

        let server = JSONRPCLanguageServer(dataTransport: dataTransport)

        let position = Position(line: 5, character: 5)
        let params = TextDocumentPositionParams(uri: "file://somefile.txt", position: position)

        var result: LanguageServerResult<Hover>? = nil

        let exp = XCTestExpectation(description: "Server Result Expectation")

        server.hover(params: params) { (serverResult) in
            result = serverResult

            exp.fulfill()
        }

        // now write the response
        let hoverResult = Hover(contents: HoverContents.markedString(MarkedString.string("foo")),
                                    range: LSPRange(startPair: (10, 10), endPair: (20, 20)))
        let serverResponse = JSONRPCResultResponse(id: 1, result: hoverResult)
        let serverResponseData = try! serverResponse.encodeToProtocolData()
        dataTransport.mockRead(serverResponseData)

        wait(for: [exp], timeout: 1.0)

        // verify the request
        let clientRequest = JSONRPCRequest(id: 1, method: ProtocolMethod.TextDocument.Hover, params: params)
        let clientRequestData = try! clientRequest.encodeToProtocolData()

        XCTAssertEqual(dataTransport.writtenData, [clientRequestData])

        // and verify the response
        guard let hover = try result?.get() else {
            XCTFail()
            return
        }

        XCTAssertEqual(hover.contents, HoverContents.markedString(MarkedString.string("foo")))
        XCTAssertEqual(hover.range, LSPRange(startPair: (10, 10), endPair: (20, 20)))
    }
}
