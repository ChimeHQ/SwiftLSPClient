//
//  SymbolKind.swift
//  SwiftLSPClient
//
//  Created by Matt Massicotte on 2019-02-07.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

public enum SymbolKind: Int, CaseIterable {
    case file = 1
    case module = 2
    case namespace = 3
    case package = 4
    case `class` = 5
    case method = 6
    case property = 7
    case field = 8
    case constructor = 9
    case `enum` = 10
    case interface = 11
    case function = 12
    case variable = 13
    case constant = 14
    case string = 15
    case number = 16
    case boolean = 17
    case array = 18
    case object = 19
    case key = 20
    case null = 21
    case enumMember = 22
    case `struct` = 23
    case event = 24
    case `operator` = 25
    case typeParameter = 26
}

extension SymbolKind: Codable {
}

extension SymbolKind: Equatable {
}
