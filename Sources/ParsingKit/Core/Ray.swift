//
//  Ray.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.10.2025.
//

import simd

public enum HitKind: Int32 { case none = -1, triangle = 0, sphere = 1, plane = 2 }

public struct Ray {
    public var origin: Vec3
    public var dir: Vec3
    public var invDir: Vec3
    public var sign: SIMD3<Int32>
    public var tMax: Scalar              // current closest t

    // --- hit payload written by intersectors ---
    public var kind: HitKind = .none
    public var prim: Int32   = -1        // triangle index or sphere index
    public var obj:  Int32   = -1        // owning object index (Triangle/Mesh/Sphere)
    public var mat:  Int32   = -1        // material index
    public var normal: Vec3  = .zero
    public var bary: SIMD3<Scalar> = .zero   // (u, v, w) for triangles

    public init(origin: Vec3, dir: Vec3, invDir: Vec3, sign: SIMD3<Int32>, tMax: Scalar, kind: HitKind = .none, prim: Int32 = -1, obj: Int32 = -1, mat: Int32 = -1, normal: Vec3 = .zero, bary: SIMD3<Scalar> = .zero) {
        self.origin = origin
        self.dir = dir
        self.invDir = invDir
        self.sign = sign
        self.tMax = tMax
        self.kind = kind
        self.prim = prim
        self.obj = obj
        self.mat = mat
        self.normal = normal
        self.bary = bary
    }
}

@inline(__always)
public func makeRay(origin: Vec3, dir: Vec3, tMax: Scalar = .greatestFiniteMagnitude) -> Ray {
    let inv = 1.0 / dir
    let sgn = SIMD3<Int32>(dir.x < 0 ? 1 : 0,
                           dir.y < 0 ? 1 : 0,
                           dir.z < 0 ? 1 : 0)
    return Ray(origin: origin,
               dir: normalize(dir),
               invDir: inv,
               sign: sgn,
               tMax: tMax)
}

@inline(__always)
public func makeShadowRay(from p: Vec3, normal n: Vec3, to light: Vec3) -> (Ray, Scalar) {
    let origin = offsetPoint(p, n)
    let L = light - origin
    let dist = simd_length(L)
    let dir = L / dist
    let inv = 1.0 / dir
    let sgn = SIMD3<Int32>(dir.x < 0 ? 1 : 0,
                           dir.y < 0 ? 1 : 0,
                           dir.z < 0 ? 1 : 0)
    var r = Ray(origin: origin, dir: dir, invDir: inv, sign: sgn, tMax: dist)
    // Zero/clear any hit fields if your Ray struct carries them
    r.kind = .none; r.prim = -1; r.obj = -1; r.mat = -1
    return (r, dist)
}

@inline(__always)
func offsetPoint(_ p: Vec3, _ n: Vec3) -> Vec3 {
    // Tweak constant based on your scene scale / Scalar type
    let k: Scalar = 1e-4
    return p + n * k
}

