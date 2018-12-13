//
//  MessageTransportTests.swift
//  SwiftLSPClientTests
//
//  Created by Matt Massicotte on 2018-10-15.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import XCTest
@testable import SwiftLSPClient

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

class MessageTransportTests: XCTestCase {
    func writeMessageAndReadResult(_ message: String) -> Data? {
        let results = writeMessagesAndReadResult([message])
        
        guard results.count == 1 else {
            return nil
        }
        
        return results[0]
    }
    
    func writeMessagesAndReadResult(_ messages: [String]) -> [Data] {
        let dataTransport = MockDataTransport()
        
        let transport = MessageTransport(dataTransport: dataTransport)
        
        var receivedData: [Data] = []
        
        transport.dataHandler = { (data) in
            receivedData.append(data)
        }
        
        for message in messages {
            dataTransport.mockRead(message)
        }
        
        return receivedData
    }
    
    func testBasicMessageDecode() {
        let content = "{\"jsonrpc\":\"2.0\",\"params\":\"Something\"}"
        let message = "Content-Length: 38\r\n\r\n\(content)"
        
        let data = writeMessageAndReadResult(message)
        
        XCTAssertEqual(data, content.data(using: .utf8)!)
    }
    
    func testMultiHeaderMessage() {
        let content = "{\"jsonrpc\":\"2.0\",\"params\":\"Something\"}"
        let header1 = "Content-Length: 38\r\n"
        let header2 = "Another-Header: Something\r\n"
        let header3 = "And-Another: third\r\n"
        let message = header1 + header2 + header3 + "\r\n" + content
        
        let data = writeMessageAndReadResult(message)
        
        XCTAssertEqual(data, content.data(using: .utf8)!)
    }
    
    func testMultiReadMessage() {
        let messages = [
            "Content-Le",
            "ngth: 30\r\n",
            "Header2: h",
            "llo\r\n\r\n",
            "abcdefghij",
            "klmnopqurs",
            "tuvwxyz123"
        ]
        
        let content = "abcdefghijklmnopqurstuvwxyz123"

        let results = writeMessagesAndReadResult(messages)
        
        guard results.count == 1 else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(results[0], content.data(using: .utf8)!)
    }
    
    func testMultiReadMessageWithSecondMessageInARead() {
        let messages = [
            "Content-Length: 6\r\n",
            "Another-Header: hello\r\n\r\n",
            "abcdefContent-Length: 10\r\n",
            "\r\nabcdefghij",
        ]
        
        let results = writeMessagesAndReadResult(messages)
        
        if results.count != 2 {
            XCTFail()
            return
        }
        
        XCTAssertEqual(results[0], "abcdef".data(using: .utf8)!)
        XCTAssertEqual(results[1], "abcdefghij".data(using: .utf8)!)
    }
    
    func testDecodeMessagePerformance() {
        let dataTransport = MockDataTransport()
        
        let transport = MessageTransport(dataTransport: dataTransport)
        
        var receiveCount: Int = 0
        
        transport.dataHandler = { (data) in
            receiveCount += 1
        }
        
        let content = "{\"jsonrpc\":\"2.0\",\"params\":\"Something\"}"
        let message = "Content-Length: 38\r\n\r\n\(content)"
        
        measure {
            for _ in 0..<1000 {
                dataTransport.mockRead(message)
            }
        }
        
        XCTAssert(receiveCount >= 1000)
    }
}
