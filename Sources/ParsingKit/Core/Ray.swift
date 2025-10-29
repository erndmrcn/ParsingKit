//
//  Ray.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.10.2025.
//

import simd

public enum HitKind: Int { case none = -1, triangle = 0, sphere = 1, plane = 2 }

public struct Ray {
    public var origin: Vec3
    public var dir: Vec3
    public var invDir: Vec3
    public var sign: SIMD3<Int>
    public var tMax: Scalar

    // --- hit payload written by intersectors ---
    public var kind: HitKind = .none
    public var prim: Int   = -1
    public var obj:  Int   = -1
    public var mat:  Int   = -1
    public var normal: Vec3  = .zero
    public var bary: SIMD3<Scalar> = .zero   // (u, v, w) for triangles

    public init(origin: Vec3, dir: Vec3, invDir: Vec3 = .zero, sign: SIMD3<Int> = .zero, tMax: Scalar = .infinity, kind: HitKind = .none, prim: Int = -1, obj: Int = -1, mat: Int = -1, normal: Vec3 = .zero, bary: SIMD3<Scalar> = .zero) {
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
public func makeRay(origin: Vec3, dir: Vec3, tMax: Scalar = .infinity) -> Ray {
    let inv = 1.0 / dir
    let sgn = SIMD3<Int>(dir.x < 0 ? 1 : 0,
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
    let sgn = SIMD3<Int>(dir.x < 0 ? 1 : 0,
                           dir.y < 0 ? 1 : 0,
                           dir.z < 0 ? 1 : 0)
    var r = Ray(origin: origin, dir: dir, invDir: inv, sign: sgn, tMax: dist)
    r.kind = .none; r.prim = -1; r.obj = -1; r.mat = -1
    return (r, dist)
}

@inline(__always)
func offsetPoint(_ p: Vec3, _ n: Vec3) -> Vec3 {
    let k: Scalar = 1e-4
    return p + n * k
}

