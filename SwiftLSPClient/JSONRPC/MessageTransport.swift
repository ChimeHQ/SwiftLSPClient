//
//  MessageTransport.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2018-10-15.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import Foundation

public class MessageTransport {
    private let dataTransport: DataTransport
    var dataHandler: DataTransport.ReadHandler?
    private var buffer: Data
    
    private static var partSeperator = "\r\n".data(using: .utf8)!
    private static var headerSeperator = ": ".data(using: .utf8)!

    public init(dataTransport: DataTransport) {
        self.dataTransport = dataTransport
        self.buffer = Data()
        
        self.dataTransport.setReaderHandler({ [unowned self] (data) in
            guard data.count > 0 else {
                return
            }
            
            self.dataReceived(data)
        })
    }

    private func dataReceived(_ data: Data) {
        buffer.append(data)
        
        checkBuffer()
    }

    private func checkBuffer() {
        guard let contentRange = readContentRange(in: buffer) else {
            return
        }

        if buffer.endIndex < contentRange.upperBound {
            return
        }

        let content = buffer.subdata(in: contentRange)
        let messageRange = buffer.startIndex..<contentRange.upperBound

        precondition(messageRange.count > 0)
        
        buffer.removeSubrange(messageRange)

        self.dataHandler?(content)

        // call recursively *only* if we have removed some data
        if !buffer.isEmpty {
            checkBuffer()
        }
    }

    private func readContentRange(in data: Data) -> Range<Data.Index>? {
        let seperator = "\r\n\r\n".data(using: .utf8)!
        
        guard let range = data.range(of: seperator) else {
            return nil
        }
        
        let headersSectionRange = data.startIndex..<range.lowerBound
        
        let headers = readHeaders(from: data, in: headersSectionRange)
        
        guard let lengthValue = headers["Content-Length"] else {
            return nil
        }
        
        guard let length = Int(lengthValue) else {
            return nil
        }
        
        let upperLimit = length + range.upperBound
        
        return range.upperBound..<upperLimit
    }
    
    private func readHeaders(from data: Data, in range: Range<Data.Index>) -> [String: String] {
        var headers: [String: String] = [:]

        var location = range.lowerBound
        
        while location < range.upperBound {
            let searchRange = location..<range.upperBound
            
            guard let headerData = readHeader(in: data, range: searchRange) else {
                break
            }
            
            let (key, value, limit) = headerData
            
            headers[key] = value
            
            location = limit
        }
        
        return headers
    }
    
    func readHeader(in data: Data, range: Range<Data.Index>) -> (String, String, Data.Index)? {
        let seperator = "\r\n".data(using: .utf8)!
        let headerSeperator = ": ".data(using: .utf8)!
        
        guard let seperatorRange = data.range(of: headerSeperator, options: [], in: range) else {
            return nil
        }
        
        let keyRange = range.lowerBound..<seperatorRange.lowerBound
        let postSeperatorRange = seperatorRange.upperBound..<range.upperBound
        
        let terminatorRange = data.range(of: seperator, options: [], in: postSeperatorRange)
        let valueUpperBound = terminatorRange?.lowerBound ?? range.upperBound
        let valueRange = postSeperatorRange.lowerBound..<valueUpperBound
        
        let keyData = data.subdata(in: keyRange)
        let valueData = data.subdata(in: valueRange)
        
        guard let key = String(data: keyData, encoding: .utf8) else {
            return nil
        }

        guard let value = String(data: valueData, encoding: .utf8) else {
            return nil
        }
        
        let endOfHeader = terminatorRange?.upperBound ?? range.upperBound
        
        return (key, value, endOfHeader)
    }
}

extension MessageTransport: DataTransport {
    public func write(_ data: Data) {
        let length = data.count

        let header = "Content-Length: \(length)\r\n\r\n"
        guard let headerData = header.data(using: .utf8) else {
            fatalError()
        }

        let messageData = headerData + data

        dataTransport.write(messageData)
    }

    public func setReaderHandler(_ handler: @escaping DataTransport.ReadHandler) {
        self.dataHandler = handler
    }

    public func close() {
        dataTransport.close()
    }
}
