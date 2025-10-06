//
//  SafeDecoding.swift
//  ParsingKit
//
//  Created by Eren Demircan on 6.10.2025.
//

import Foundation

// MARK: - Defaultable protocol and common defaults
public protocol DefaultValue {
    associatedtype Value: Codable
    static var defaultValue: Value { get }
}

public enum Defaults {
    public enum ZeroInt: DefaultValue { public static let defaultValue = 0 }
    public enum ZeroDouble: DefaultValue { public static let defaultValue = 0.0 }
    public enum UnitVec3: DefaultValue { public static let defaultValue = [0.0, 0.0, 1.0] as [Double] }
    public enum EmptyString: DefaultValue { public static let defaultValue = "" }
    public enum EmptyArray<T: Codable>: DefaultValue { public static var defaultValue: [T] { [] } }
    public enum False: DefaultValue { public static let defaultValue = false }
    public enum True: DefaultValue { public static let defaultValue = true }
}

/// Property wrapper that supplies a default when decoding fails or value is absent.
@propertyWrapper
public struct Default<D: DefaultValue>: Codable {
    public var wrappedValue: D.Value
    public init() { wrappedValue = D.defaultValue }
    public init(wrappedValue: D.Value) { self.wrappedValue = wrappedValue }
    public init(from decoder: Decoder) throws {
        let c = try? decoder.singleValueContainer()
        self.wrappedValue = (try? c?.decode(D.Value.self)) ?? D.defaultValue
    }
}

/// Lossy array — drops elements that fail to decode instead of throwing.
@propertyWrapper
public struct LossyArray<Element: Codable>: Codable {
    public var wrappedValue: [Element] = []
    public init() {}
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var items: [Element] = []
        while !container.isAtEnd {
            do { items.append(try container.decode(Element.self)) }
            catch { _ = try? container.decode(DummyDecodable.self) } // advance
        }
        self.wrappedValue = items
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.unkeyedContainer()
        try wrappedValue.forEach { try c.encode($0) }
    }
    private struct DummyDecodable: Decodable {}
}

/// Flexible number decoding: accepts String or Number.
@propertyWrapper
public struct FlexibleDouble: Codable {
    public var wrappedValue: Double
    public init(wrappedValue: Double) { self.wrappedValue = wrappedValue }
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let d = try? c.decode(Double.self) { wrappedValue = d; return }
        if let s = try? c.decode(String.self), let d = Double(s.trimmingCharacters(in: .whitespacesAndNewlines)) {
            wrappedValue = d; return
        }
        wrappedValue = 0.0 // safe default
    }
}


public struct Vec3: Codable, Vec3Constructible {
    public let x: Double, y: Double, z: Double
    public init(_ x: Double, _ y: Double, _ z: Double) { self.x = x; self.y = y; self.z = z }
}



// MARK: - Decoding error with path (for logs/tests, not to crash)

public struct ParsingIssue: CustomStringConvertible, Sendable {
    public let path: String
    public let message: String
    public var description: String { "[\(path)] \(message)" }
}

public final class IssueCollector: @unchecked Sendable {
    public private(set) var issues: [ParsingIssue] = []
    public func record(_ path: [CodingKey], _ message: String) {
        let p = path.map(\.stringValue).joined(separator: ".")
        issues.append(.init(path: p, message: message))
    }
}
