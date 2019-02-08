//
//  ProtocolTransportTests.swift
//  SwiftLSPClientTests
//
//  Created by Matt Massicotte on 2019-02-07.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import XCTest
import Result
@testable import SwiftLSPClient

class ProtocolTransportTests: XCTestCase {
    typealias TestResult = Result<JSONRPCResultResponse<TextDocumentIdentifier>, ProtocolTransportError>

    func testSendRequest() {
        let dataTransport = MockDataTransport()
        let messageTransport = MessageTransport(dataTransport: dataTransport)
        let transport = ProtocolTransport(messageTransport: messageTransport)

        let expectation = XCTestExpectation(description: "Response Message")

        let request = TextDocumentIdentifier(uri: "hello")
        transport.sendRequest(request, method: "mymethod") { (result: TestResult) in
            XCTAssertNil(result.error)
            XCTAssertEqual(result.value?.result, TextDocumentIdentifier(uri: "goodbye"))

            expectation.fulfill()
        }

        dataTransport.mockRead("Content-Length: 51\r\n\r\n")
        dataTransport.mockRead("""
{"jsonrpc":"2.0","id":1,"result":{"uri":"goodbye"}}
""")

        wait(for: [expectation], timeout: 1.0)
    }

    func testNotification() {
        let dataTransport = MockDataTransport()
        let messageTransport = MessageTransport(dataTransport: dataTransport)
        let transport = ProtocolTransport(messageTransport: messageTransport)
        let transportDelegate = MockProtocolTransportDelegate()

        transport.delegate = transportDelegate

        let expectation = XCTestExpectation(description: "Notification Message")

        transportDelegate.notificationHandler = { (method, data) in
            XCTAssertEqual(method, "iamnotification")

            let result = try? JSONDecoder().decode(JSONRPCNotificationParams<String>.self, from: data)

            XCTAssertEqual(result?.params, "iamstring")
            expectation.fulfill()
        }

        dataTransport.mockRead("Content-Length: 65\r\n\r\n")
        dataTransport.mockRead("""
{"jsonrpc":"2.0","method":"iamnotification","params":"iamstring"}
""")

        wait(for: [expectation], timeout: 1.0)
    }
}
