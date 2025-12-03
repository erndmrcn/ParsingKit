//
//  Ray.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.10.2025.
//

import simd

public enum HitKind: Int { case none = -1, triangle = 0, sphere = 1, plane = 2 }

public struct Hit: Sendable {
    public var t: Scalar = .infinity
    public var kind: HitKind = .none
    public var prim: Int = -1
    public var obj: Int = -1
    public var mat: Int = -1
    public var p: Vec3 = .zero
    public var n: Vec3 = .zero
    public var bary: SIMD3<Scalar> = .zero  // (u,v,w) for triangles

    @inline(__always)
    public mutating func reset() {
        t = .infinity
        kind = .none
        prim = -1
        obj = -1
        mat = -1
        p = .zero
        n = .zero
        bary = .zero
    }

    public init() {}
}

public struct Ray {
    public var origin: Vec3
    public var dir: Vec3 { didSet { invDir = 1.0 / dir } }
    public var invDir: Vec3
    public var sign: SIMD3<Int>
    public var tMax: Scalar
    public var hit: Hit = .init()   // ✅ Unified hit record
    public var time: Scalar = 0
    public var tMin = Scalar(0)

    public init(origin: Vec3, dir: Vec3, tMax: Scalar = .infinity, time: Scalar = 0) {
        self.origin = origin
        self.dir = normalize(dir)
        self.invDir = 1.0 / dir
        self.sign = SIMD3(dir.x < 0 ? 1 : 0,
                          dir.y < 0 ? 1 : 0,
                          dir.z < 0 ? 1 : 0)
        self.tMax = tMax
        self.time = time
    }
}

extension Ray {
    @inline(__always)
    public mutating func updateHit(_ h: Hit) {
        if h.t < hit.t {
            hit = h
            tMax = h.t
        }
    }

    @inline(__always)
    public mutating func setHit(t: Scalar, n: Vec3, kind: HitKind, mat: Int, prim: Int, obj: Int, p: Vec3) {
        hit.t = t
        hit.kind = kind
        hit.mat = mat
        hit.prim = prim
        hit.obj = obj
        hit.p = p
        hit.n = n
        tMax = t
    }

    @inline(__always)
    public mutating func clearHit() { hit.reset() }
}
