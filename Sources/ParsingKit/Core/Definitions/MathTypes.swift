//
//  MathTypes.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.10.2025.
//

import Foundation
import simd

#if SCALAR_IS_FLOAT
public typealias Mat4 = simd_float4x4
public typealias Mat3 = simd_float3x3
public typealias Mat2 = simd_float2x2
public typealias Mat32 = simd_float3x2
public typealias Vec2 = SIMD2<Float>
public typealias Vec3 = SIMD3<Float>
public typealias Vec4 = SIMD4<Float>
#else
public typealias Mat4 = simd_double4x4
public typealias Mat3 = simd_double3x3
public typealias Mat2 = simd_double2x2
public typealias Mat32 = simd_double3x2
public typealias Vec2 = SIMD2<Double>
public typealias Vec3 = SIMD3<Double>
public typealias Vec4 = SIMD4<Double>
#endif

@inlinable public func makeVec2(_ x: Scalar, _ y: Scalar) -> Vec2 { .init(x, y) }
@inlinable public func makeVec3(_ x: Scalar, _ y: Scalar, _ z: Scalar) -> Vec3 { .init(x, y, z) }
@inlinable public func makeVec4(_ x: Scalar, _ y: Scalar, _ z: Scalar, _ w: Scalar) -> Vec4 { .init(x, y, z, w) }

public extension Mat4 {
    static var identity: Mat4 {
        .init(.init(1, 0, 0, 0),
              .init(0, 1, 0, 0),
              .init(0, 0, 1, 0),
              .init(0, 0, 0, 1))
    }
}

public extension Vec3 { init(repeating v: Scalar) { self.init(v, v, v) } }
@inlinable public func min(_ a: Vec3, _ b: Vec3) -> Vec3 { simd.min(a, b) }
@inlinable public func max(_ a: Vec3, _ b: Vec3) -> Vec3 { simd.max(a, b) }

@inlinable
public func normalTransformMatrix(from M: Mat4) -> Mat3 {
    let m3 = Mat3(
        SIMD3(M.columns.0.x, M.columns.0.y, M.columns.0.z),
        SIMD3(M.columns.1.x, M.columns.1.y, M.columns.1.z),
        SIMD3(M.columns.2.x, M.columns.2.y, M.columns.2.z)
    )
    return m3.inverse.transpose
}

extension Mat4 {

    init(fromString s: String) throws {
        let values: [Scalar] = s
            .split(separator: " ")
            .compactMap { Scalar($0) }

        guard values.count == 16 else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "Mat4 requires 16 values, got \(values.count)"
                )
            )
        }

        self.init(
            Vec4(values[0],  values[4],  values[8],  values[12]),
            Vec4(values[1],  values[5],  values[9],  values[13]),
            Vec4(values[2],  values[6],  values[10], values[14]),
            Vec4(values[3],  values[7],  values[11], values[15])
        )
    }
}

public extension Vec3 {
    var padded: Vec4 {
        Vec4(self, 0)
    }
}
