//
//  Scalar.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.10.2025.
//

import simd

#if PARSINGKIT_SCALAR_FLOAT
public typealias Scalar = Float
#else
public typealias Scalar = Double
#endif

