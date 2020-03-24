//
//  WorkspaceEdit.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2020-03-17.
//  Copyright © 2020 Chime Systems. All rights reserved.
//

import Foundation

public struct CreateFileOptions: Codable, Equatable {
    public let overwrite: Bool?
    public let ignoreIfExists: Bool?
}

public struct CreateFile: Codable, Equatable {
   public  let kind: String
    public let uri: DocumentUri
    public let options: CreateFileOptions?
}

public typealias RenameFileOptions = CreateFileOptions

public struct RenameFile: Codable, Equatable {
    public let kind: String
    public let oldUri: DocumentUri
    public let newUri: DocumentUri
    public let options: RenameFileOptions
}

public struct DeleteFileOptions: Codable, Equatable {
    public let recursive: Bool?
    public let ignoreIfNotExists: Bool?
}

public struct DeleteFile: Codable, Equatable {
    public let kind: String
    public let uri: DocumentUri
    public let options: DeleteFileOptions
}

public struct TextDocumentEdit: Codable, Equatable {
    public let textDocument: VersionedTextDocumentIdentifier
    public let edits: [TextEdit]
}

public enum WorkspaceEditDocumentChange: Codable, Equatable {
    case textDocumentEdit(TextDocumentEdit)
    case createFile(CreateFile)
    case renameFile(RenameFile)
    case deleteFile(DeleteFile)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(TextDocumentEdit.self) {
            self = .textDocumentEdit(value)
        } else if let value = try? container.decode(CreateFile.self) {
            self = .createFile(value)
        } else if let value = try? container.decode(RenameFile.self) {
            self = .renameFile(value)
        } else {
            let value = try container.decode(DeleteFile.self)
            self = .deleteFile(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .textDocumentEdit(let value):
            try container.encode(value)
        case .createFile(let value):
            try container.encode(value)
        case .renameFile(let value):
            try container.encode(value)
        case .deleteFile(let value):
            try container.encode(value)
        }
    }
}

public struct WorkspaceEdit: Codable, Equatable {
    public let changes: [DocumentUri : [TextEdit]]?
    public let documentChanges: [WorkspaceEditDocumentChange]?
}
