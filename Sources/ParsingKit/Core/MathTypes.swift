//
//  MathTypes.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.10.2025.
//

import Foundation
import simd

public typealias Vec3 = SIMD3<Scalar>

@inlinable public func makeVec3(_ x: Scalar, _ y: Scalar, _ z: Scalar) -> Vec3 { .init(x, y, z) }
