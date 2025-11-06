//
//  Camera.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.11.2025.
//

import Foundation
import simd

public struct Camera {
    public var id: String? = nil
    public var type: String? = nil
    public var fovy: Scalar? = .zero
    public var position: Vec3 = .zero
    public var gaze: Vec3 = .zero
    public var gazePoint: Vec3 = .zero
    public var up: Vec3 = .zero
    public var nearPlane: [Scalar] = [-1, 1, -1, 1]
    public var nearDistance: Scalar = 1
    public var imageResolution: (Int, Int) = (512, 512)
    public var numSamples: Int = 1
    public var imageName: String = "image.png"
}

// MARK: - Coding Keys
extension Camera {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type = "_type"
        case fovy = "FovY"
        case position = "Position"
        case gaze = "Gaze"
        case gazePoint = "GazePoint"
        case up = "Up"
        case nearPlane = "NearPlane"
        case nearDistance = "NearDistance"
        case imageResolution = "ImageResolution"
        case numSamples = "NumSamples"
        case imageName = "ImageName"
    }
}

// MARK: - Decodable
extension Camera: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? c.decode(String.self, forKey: .id)
        self.type = try? c.decode(String.self, forKey: .type)
        self.fovy = Scalar((try? c.decode(String.self, forKey: .fovy)) ?? "0") ?? .zero
        self.position = Self.decodeVec3(c, .position) ?? position
        self.gaze = Self.decodeVec3(c, .gaze) ?? gaze
        self.gazePoint = Self.decodeVec3(c, .gazePoint) ?? gazePoint
        self.up = Self.decodeVec3(c, .up) ?? up
        if let s = try? c.decode(String.self, forKey: .nearPlane) {
            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap(Scalar.init); if comps.count >= 4 { nearPlane = Array(comps.prefix(4)) }
        } else if let arr = try? c.decode([Scalar].self, forKey: .nearPlane), arr.count >= 4 {
            nearPlane = Array(arr.prefix(4))
        }

        if let s = try? c.decode(String.self, forKey: .imageResolution) {
            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap { Int($0) }
            if comps.count >= 2 { imageResolution = (comps[0], comps[1]) }
        } else if let arr = try? c.decode([Int].self, forKey: .imageResolution), arr.count >= 2 {
            imageResolution = (arr[0], arr[1])
        }

        self.numSamples = (try? c.decode(Int.self, forKey: .numSamples)) ?? self.numSamples
        self.nearDistance = Scalar((try? c.decode(String.self, forKey: .nearDistance)) ?? "1") ?? self.nearDistance
        self.imageName  = (try? c.decode(String.self, forKey: .imageName)) ?? self.imageName
    }

    static func decodeVec3(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) -> Vec3? {
        if let s = try? c.decode(String.self, forKey: k) {
            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap(Scalar.init)
            if comps.count >= 3 { return Vec3(comps[0], comps[1], comps[2]) }
        } else if let arr = try? c.decode([Scalar].self, forKey: k), arr.count >= 3 {
            return Vec3(arr[0], arr[1], arr[2])
        }
        return nil
    }
}

// MARK: - LookAt functions
extension Camera {
    func computeBasis(aspect: Scalar) -> (origin: Vec3, u: Vec3, v: Vec3, w: Vec3, fovYRad: Scalar?) {
        let origin = position
        let forward = simd_normalize(gaze - position)
        let right = simd_normalize(simd_cross(forward, up))
        let trueUp = simd_normalize(simd_cross(right, forward))
        var fovYRad: Scalar? = nil
        if fovy != nil {
            fovYRad = fovy! * .pi / 180.0
        }

        return (origin, right, trueUp, -forward, fovYRad)
    }

    func generateRay(x: Scalar, y: Scalar, width: Int, height: Int) -> Ray {
        let aspect = Scalar(width) / Scalar(height)
        let (origin, u, v, w, fovYRad) = computeBasis(aspect: aspect)
        let tanHalfFovY = fovYRad == nil ? 1.0 : tan(fovYRad! / 2)
        let px = ( (2 * (x + 0.5) / Scalar(width)) - 1 ) * aspect * tanHalfFovY
        let py = (1 - 2 * (y + 0.5) / Scalar(height)) * tanHalfFovY

        let dir = simd_normalize(px * u + py * v + w)
        return Ray(origin: origin, dir: dir)
    }
}
