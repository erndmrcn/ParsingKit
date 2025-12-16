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
    public var textures: String = ""
    public var prim: Int = -1
    public var obj: Int = -1
    public var mat: Int = -1
    public var p: Vec3 = .zero
    public var n: Vec3 = .zero
    public var tangent: Vec3 = .zero
    public var bitangent: Vec3 = .zero
    public var uv: SIMD2<Scalar> = .zero
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

@frozen public struct Ray {
    @inline(__always) public var origin: Vec3
    @inline(__always) public var dir: Vec3 { didSet { invDir = 1.0 / dir } }
    @inline(__always) public var invDir: Vec3
    @inline(__always) public var sign: SIMD3<Int>
    @inline(__always) public var tMax: Scalar
    @inline(__always) public var hit: Hit = .init()   // ✅ Unified hit record
    @inline(__always) public var time: Scalar = 0
    @inline(__always) public var tMin = Scalar(0)
    @inline(__always) public var ltw: Mat4 = .identity

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
