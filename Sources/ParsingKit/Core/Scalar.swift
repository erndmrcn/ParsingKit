//
//  Scalar.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.10.2025.
//

import Foundation
import simd

#if PARSINGKIT_SIMD_DOUBLE
public typealias PKScalar = Double
#else
public typealias PKScalar = Float
#endif

public typealias PKFloat3 = SIMD3<PKScalar>

@inlinable public func pkScalar(from s: String) -> PKScalar? {
#if PARSINGKIT_SIMD_DOUBLE
return Double(s)
#else
return Float(s)
#endif
}
