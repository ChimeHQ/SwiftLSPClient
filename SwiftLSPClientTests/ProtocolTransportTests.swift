//
//  ProtocolTransportTests.swift
//  SwiftLSPClientTests
//
//  Created by Matt Massicotte on 2019-02-07.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import XCTest
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
            let value = try? result.get()
            XCTAssertEqual(value?.result, TextDocumentIdentifier(uri: "goodbye"))

            expectation.fulfill()
        }

        let response = JSONRPCResultResponse(id: 1, result: TextDocumentIdentifier(uri: "goodbye"))
        let responseData = try! response.encodeToProtocolData()

        dataTransport.mockRead(responseData)

        wait(for: [expectation], timeout: 1.0)
    }

    func testManySendRequestsWithResponsesDeliveredOnABackgroundQueueTest() {
        let dataTransport = MockDataTransport()
        let messageTransport = MessageTransport(dataTransport: dataTransport)
        let transport = ProtocolTransport(messageTransport: messageTransport)

        let iterations = 1000
        let expectation = XCTestExpectation(description: "Response Message")
        expectation.expectedFulfillmentCount = iterations

        let request = TextDocumentIdentifier(uri: "hello")
        let queue = DispatchQueue(label: "SimluatedFileHandleQueue")

        // be sure to start at 1, to match ProtocolTransport's id generation
        for i in 1...iterations {
            let responseDocIdentifier = TextDocumentIdentifier(uri: "goodbye-\(i)")

            transport.sendRequest(request, method: "mymethod") { (result: TestResult) in
                let value = try? result.get()
                XCTAssertEqual(value?.result, responseDocIdentifier)

                expectation.fulfill()
            }

            let response = JSONRPCResultResponse<TextDocumentIdentifier>(id: i, result: responseDocIdentifier)
            let responseData = try! response.encodeToProtocolData()

            // this must happen asynchronously to match the behavior of NSFileHandle
            queue.async {
                dataTransport.mockRead(responseData)
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testSendNotification() {
        let dataTransport = MockDataTransport()
        let messageTransport = MessageTransport(dataTransport: dataTransport)
        let transport = ProtocolTransport(messageTransport: messageTransport)

        let expectation = XCTestExpectation(description: "Notification Message")

        let request = TextDocumentIdentifier(uri: "hello")

        transport.sendNotification(request, method: "mynotification") { (error) in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        let result = JSONRPCNotificationParams(method: "mynotification", params: request)
        let resultData = try! result.encodeToProtocolData()

        XCTAssertEqual(dataTransport.writtenData, [resultData])
    }

    func testServerToClientNotification() {
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

        let response = JSONRPCNotificationParams<String>(method: "iamnotification", params: "iamstring")
        let responseData = try! response.encodeToProtocolData()

        dataTransport.mockRead(responseData)

        wait(for: [expectation], timeout: 1.0)
    }
}
