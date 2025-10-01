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
public typealias FlexibleDouble = Flexible<Double>

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
    static func makeVec3(x: Double, y: Double, z: Double) -> Self
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
        // Accept string "x y z" or array [x,y,z]
        if let s = try? decoder.singleValueContainer().decode(String.self) {
            let parts = s.split { $0.isWhitespace }
            guard parts.count >= 3, let x = Double(parts[0]), let y = Double(parts[1]), let z = Double(parts[2]) else {
                throw PKDecodingError.expectedVector("Vec3 requires 3 components")
            }
            wrappedValue = T.makeVec3(x: x, y: y, z: z)
            return
        }
        if var arr = try? decoder.unkeyedContainer() {
            func next() throws -> Double {
                if let d = try? arr.decode(Double.self) { return d }
                if let i = try? arr.decode(Int.self) { return Double(i) }
                if let s = try? arr.decode(String.self), let d = Double(s) { return d }
                throw PKDecodingError.expectedVector("Invalid vec3 element")
            }
            let x = try next(), y = try next(), z = try next()
            wrappedValue = T.makeVec3(x: x, y: y, z: z)
            return
        }
        throw PKDecodingError.expectedVector("Expected vec3 as string or array")
    }
}
