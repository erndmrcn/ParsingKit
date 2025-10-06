//
//  PropertyWrapper.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.10.2025.
//

import Foundation
import simd

// MARK: - Flexible scalars (decode number OR numeric string)
@propertyWrapper
public struct Flexible<T: LosslessStringConvertible & Decodable>: Decodable {
    public var wrappedValue: T

    public init(wrappedValue: T) { self.wrappedValue = wrappedValue }

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let v = try? c.decode(T.self) {
            wrappedValue = v
            return
        }
        if let s = try? c.decode(String.self), let v = T(s.trimmingCharacters(in: .whitespaces)) {
            wrappedValue = v
            return
        }
        throw PKDecodingError.expectedValue("Flexible<\(T.self)> expected number or numeric string")
    }
}

public typealias FlexibleInt = Flexible<Int>
//public typealias FlexibleDouble = Flexible<Double>

// MARK: - OneOrMany: decode T or [T] as [T]

public struct OneOrMany<T: Decodable>: Decodable {
    public var values: [T]
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let arr = try? c.decode([T].self) { values = arr; return }
        if let single = try? c.decode(T.self) { values = [single]; return }
        values = []
    }
}

// MARK: - Vec3Constructible + FlexibleVec3
public protocol Vec3Constructible {
    init(_ x: Double, _ y: Double, _ z: Double)
}

extension SIMD3: Vec3Constructible where Scalar == Double {
    public static func makeVec3(x: Double, y: Double, z: Double) -> SIMD3<Double> { .init(x, y, z) }
}

extension SIMD3 where Scalar == Float {
    public static func makeVec3(x: Double, y: Double, z: Double) -> SIMD3<Float> { .init(Float(x), Float(y), Float(z)) }
}

@propertyWrapper
public struct FlexibleVec3<T: Vec3Constructible>: Decodable {
    public var wrappedValue: T
    public init(wrappedValue: T) { self.wrappedValue = wrappedValue }
    public init(from decoder: Decoder) throws {
        // string "x y z"
        if let s = try? decoder.singleValueContainer().decode(String.self) {
            let nums = s.split(whereSeparator: \.isWhitespace).compactMap { Double($0) }
            if nums.count == 3 { wrappedValue = T(nums[0], nums[1], nums[2]); return }
        }
        // array [x,y,z]
        if var c = try? decoder.unkeyedContainer() {
            let x = (try? c.decode(Double.self)) ?? 0
            let y = (try? c.decode(Double.self)) ?? 0
            let z = (try? c.decode(Double.self)) ?? 1
            wrappedValue = T(x, y, z); return
        }
        // dict {"x":..,"y":..,"z":..}
        if let c = try? decoder.container(keyedBy: AnyKey.self) {
            let x = (try? c.decode(Double.self, forKey: AnyKey("x"))) ?? 0
            let y = (try? c.decode(Double.self, forKey: AnyKey("y"))) ?? 0
            let z = (try? c.decode(Double.self, forKey: AnyKey("z"))) ?? 1
            wrappedValue = T(x, y, z); return
        }
        wrappedValue = T(0, 0, 1)
    }
    private struct AnyKey: CodingKey {
        var stringValue: String; init(_ s: String) { stringValue = s }
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int? = nil; init?(intValue: Int) { return nil }
    }
}
