//
//  Matrix+Extension.swift
//  ParsingKit
//
//  Created by Eren Demircan on 2.11.2025.
//

import simd

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
        self.init(columns: (
            Vec4(s.x, 0, 0, 0),
            Vec4(0, s.y, 0, 0),
            Vec4(0, 0, s.z, 0),
            Vec4(0, 0, 0, 1)
        ))
    }

    init(rotation angleDeg: Double, axis: Vec3) {
        let a = normalize(axis)
        let rad = angleDeg * .pi / 180.0
        let c = cos(rad)
        let s = sin(rad)
        let ic = 1 - c

        let r00 = a.x*a.x*ic + c
        let r01 = a.x*a.y*ic - a.z*s
        let r02 = a.x*a.z*ic + a.y*s

        let r10 = a.y*a.x*ic + a.z*s
        let r11 = a.y*a.y*ic + c
        let r12 = a.y*a.z*ic - a.x*s

        let r20 = a.z*a.x*ic - a.y*s
        let r21 = a.z*a.y*ic + a.x*s
        let r22 = a.z*a.z*ic + c

        self.init(columns: (
            Vec4(r00, r10, r20, 0),
            Vec4(r01, r11, r21, 0),
            Vec4(r02, r12, r22, 0),
            Vec4(0, 0, 0, 1)
        ))
    }
}
