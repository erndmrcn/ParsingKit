//
//  Matrix+Extension.swift
//  ParsingKit
//
//  Created by Eren Demircan on 2.11.2025.
//

import simd
import SwiftUI

extension Mat4 {
    init(translation v: Vec3) {
        self.init(columns: (
            Vec4(1, 0, 0, 0),
            Vec4(0, 1, 0, 0),
            Vec4(0, 0, 1, 0),
            Vec4(v.x, v.y, v.z, 1)
        ))
    }

    init(scaling s: Vec3) {
        self.init(diagonal: Vec4(s, 1.0))
    }

    init(rotation angleDeg: Scalar, axis: Vec3) {
        let n = normalize(axis)
        let a = n.x, b = n.y, c = n.z

        // ✅ correct conversion
        let rad = angleDeg * .pi / 180.0

        let cosA = cos(rad)
        let sinA = sin(rad)
        let K: Scalar = 1.0 - cosA

        let r00 = cosA + a*a*K
        let r01 = a*b*K - c*sinA
        let r02 = a*c*K + b*sinA

        let r10 = a*b*K + c*sinA
        let r11 = cosA + b*b*K
        let r12 = b*c*K - a*sinA

        let r20 = a*c*K - b*sinA
        let r21 = b*c*K + a*sinA
        let r22 = cosA + c*c*K

        self.init(columns: (
            Vec4(r00, r10, r20, 0),
            Vec4(r01, r11, r21, 0),
            Vec4(r02, r12, r22, 0),
            Vec4(0,   0,   0,   1)
        ))
    }
}
