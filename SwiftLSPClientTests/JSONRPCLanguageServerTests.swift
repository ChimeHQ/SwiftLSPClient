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

        let textDocId = TextDocumentIdentifier(uri: "file://somefile.txt")
        let position = Position(line: 5, character: 5)
        let params = TextDocumentPositionParams(textDocument: textDocId, position: position)

        var result: LanguageServerResult<Hover>? = nil

        let exp = XCTestExpectation(description: "Server Result Expectation")

        server.hover(params: params) { (serverResult) in
            result = serverResult

            exp.fulfill()
        }

        // now write the response
        let serverResponse = "Content-Length: 130\r\n\r\n{\"jsonrpc\":\"2.0\",\"id\":1,\"result\":{\"contents\":\"foo\",\"range\":{\"start\":{\"line\":10,\"character\":10},\"end\":{\"line\":20,\"character\":20}}}}"
        dataTransport.mockRead(serverResponse)

        wait(for: [exp], timeout: 1.0)

        // verify the request
        let clientRequest = "Content-Length: 149\r\n\r\n{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"textDocument\\/hover\",\"params\":{\"textDocument\":{\"uri\":\"file:\\/\\/somefile.txt\"},\"position\":{\"line\":5,\"character\":5}}}"

        let writtenStrings = dataTransport.writtenData.compactMap({ String(data: $0, encoding: .utf8) })

        XCTAssertEqual(writtenStrings, [clientRequest])

        // and verify the response
        guard let hover = try result?.get() else {
            XCTFail()
            return
        }

        XCTAssertEqual(hover.contents, HoverContents.markedString(MarkedString.string("foo")))
        XCTAssertEqual(hover.range, LSPRange(startPair: (10, 10), endPair: (20, 20)))
    }
}
