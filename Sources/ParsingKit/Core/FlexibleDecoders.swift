//
//  FlexibleDecoders.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.10.2025.
//

import Foundation

@propertyWrapper
public struct FlexibleDouble: Codable {
    public var wrappedValue: Scalar
    public init(wrappedValue: Scalar = 0) { self.wrappedValue = wrappedValue }
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let d = try? c.decode(Scalar.self) {
            wrappedValue = d
        } else if let s = try? c.decode(String.self) {
            wrappedValue = Scalar(s.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        } else {
            wrappedValue = 0
        }
    }
}

@propertyWrapper
public struct FlexibleInt: Codable {
    public var wrappedValue: Int
    public init(wrappedValue: Int = 0) { self.wrappedValue = wrappedValue }
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let i = try? c.decode(Int.self) {
            wrappedValue = i
        } else if let s = try? c.decode(String.self) {
            wrappedValue = Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        } else {
            wrappedValue = 0
        }
    }
}

// MARK: - Vec3 support: accept "x y z", [x,y,z], or a single index that’s resolved later.
public enum FlexibleVec3Value: Equatable {
    public static func == (lhs: FlexibleVec3Value, rhs: FlexibleVec3Value) -> Bool {
        if case let .xyz(l) = lhs, case let .xyz(r) = rhs { return l == r }
        if case let .vertexIndex(l) = lhs, case let .vertexIndex(r) = rhs { return l == r }
        return false
    }
    
    case xyz(Vec3)
    case vertexIndex(Int) // 1-based index referencing VertexData
}

@propertyWrapper
public struct FlexibleVec3<T>: Decodable {
    public var wrappedValue: FlexibleVec3Value
    public init(wrappedValue: FlexibleVec3Value = .xyz(.zero)) { self.wrappedValue = wrappedValue }

    public var toVec3: T {
        switch wrappedValue {
        case .xyz(let v): return v as! T
        case .vertexIndex(let i): return Vec3(Scalar(i - 1), 0, 0) as! T
        }
    }
    
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()

        // 1) If it's a plain number -> interpret as vertex index (supports both "6" and 6)
        if let i = try? c.decode(Int.self) {
            wrappedValue = .vertexIndex(i)
            return
        }
        if let sIndex = try? c.decode(String.self), let i = Int(sIndex.trimmingCharacters(in: .whitespacesAndNewlines)) {
            wrappedValue = .vertexIndex(i)
            return
        }

        // 2) If it's an array -> [x,y,z]
        if let arr = try? c.decode([Scalar].self), arr.count >= 3 {
            wrappedValue = .xyz(Vec3(arr[0], arr[1], arr[2]))
            return
        }

        // 3) If it's a string "x y z"
        if let s = try? c.decode(String.self) {
            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap { Scalar($0) }
            if comps.count >= 3 {
                wrappedValue = .xyz(Vec3(comps[0], comps[1], comps[2]))
                return
            }
        }

        wrappedValue = .xyz(.zero) // default safe value
    }
}
