//
//  MathTypes.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.10.2025.
//

import Foundation
import simd

public typealias Vec3 = SIMD3<Scalar>
public typealias Vec4 = SIMD4<Scalar>

public typealias Mat4 = simd_double4x4

@inlinable public func makeVec3(_ x: Scalar, _ y: Scalar, _ z: Scalar) -> Vec3 { .init(x, y, z) }
@inlinable public func makeVec4(_ x: Scalar, _ y: Scalar, _ z: Scalar, _ w: Scalar) -> Vec4 { .init(x, y, z, w) }

extension Mat4 {
    static var identity: Mat4 {
        .init(.init(1, 0, 0, 0),
              .init(0, 1, 0, 0),
              .init(0, 0, 1, 0),
              .init(0, 0, 0, 1))
    }
}
