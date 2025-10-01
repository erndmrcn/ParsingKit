//
//  FlexibleDecoding.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.10.2025.
//

import Foundation

public enum PKDecodingError: Error, LocalizedError {
    case expectedValue(String)
    case expectedVector(String)
    case invalidVertexData(String)

    public var errorDescription: String? {
        switch self {
        case .expectedValue(let msg): return msg
        case .expectedVector(let msg): return msg
        case .invalidVertexData(let msg): return msg
        }
    }
}

public extension KeyedDecodingContainer {
    @inlinable func pkString(forKey key: K) throws -> String {
        if let s = try? decode(String.self, forKey: key) { return s }
        if let i = try? decode(Int.self, forKey: key) { return String(i) }
        if let d = try? decode(Double.self, forKey: key) { return String(d) }
        throw PKDecodingError.expectedValue("Expected string-like value for \(key.stringValue)")
    }

    @inlinable func pkInt(forKey key: K) throws -> Int {
        if let i = try? decode(Int.self, forKey: key) { return i }
        if let s = try? decode(String.self, forKey: key), let i = Int(s.trimmingCharacters(in: .whitespaces)) { return i }
        if let d = try? decode(Double.self, forKey: key) { return Int(d) }
        throw PKDecodingError.expectedValue("Expected int-like value for \(key.stringValue)")
    }

    @inlinable func pkDouble(forKey key: K) throws -> Double {
        if let d = try? decode(Double.self, forKey: key) { return d }
        if let s = try? decode(String.self, forKey: key), let d = Double(s.trimmingCharacters(in: .whitespaces)) { return d }
        if let i = try? decode(Int.self, forKey: key) { return Double(i) }
        throw PKDecodingError.expectedValue("Expected double-like value for \(key.stringValue)")
    }

    /// Returns either: space-separated string → [String], or JSON array → [String]
    @inlinable func pkVectorStrings(forKey key: K) throws -> [String] {
        if let s = try? decode(String.self, forKey: key) {
            return s.split { $0.isWhitespace }.map(String.init)
        }
        if var arr = try? nestedUnkeyedContainer(forKey: key) {
            var out: [String] = []
            while !arr.isAtEnd {
                if let d = try? arr.decode(Double.self) { out.append(String(d)) }
                else if let i = try? arr.decode(Int.self) { out.append(String(i)) }
                else if let s = try? arr.decode(String.self) { out.append(s) }
                else { _ = try? arr.decode(Empty.self) }
            }
            return out
        }
        throw PKDecodingError.expectedVector("Expected vector-like value for \(key.stringValue)")
    }

    struct Empty: Decodable {}
}
