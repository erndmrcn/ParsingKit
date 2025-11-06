//
//  DynamicCodingKeys.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.10.2025.
//

import Foundation

public struct DynamicCodingKeys: CodingKey {
    public var stringValue: String
    public var intValue: Int? { nil }
    public init(_ string: String) { self.stringValue = string }
    public init?(stringValue: String) { self.stringValue = stringValue }
    public init?(intValue: Int) { return nil }
}
