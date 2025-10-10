//
//  SceneModel.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.10.2025.
//

import Foundation
import simd

public struct Camera: Decodable {
    public var id: String? = nil
    public var position: Vec3 = .zero
    public var gaze: Vec3 = .zero
    public var up: Vec3 = .zero
    public var nearPlane: [Scalar] = [-1, 1, -1, 1] // l r b t
    @FlexibleDouble public var nearDistance: Scalar = 1
    public var imageResolution: (Int, Int) = (512, 512)
    public var numSamples: Int = 1
    public var imageName: String = "image.png"

    enum CodingKeys: String, CodingKey {
        case id = "_id", position = "Position", gaze = "Gaze", up = "Up"
        case nearPlane = "NearPlane", nearDistance = "NearDistance"
        case imageResolution = "ImageResolution", numSamples = "NumSamples", imageName = "ImageName"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? c.decode(String.self, forKey: .id)
        self.position = Self.decodeVec3(c, .position) ?? position
        self.gaze = Self.decodeVec3(c, .gaze) ?? gaze
        self.up = Self.decodeVec3(c, .up) ?? up

        // NearPlane can be "l r b t" or "l r b t dist"
        if let s = try? c.decode(String.self, forKey: .nearPlane) {
            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap(Scalar.init); if comps.count >= 4 { nearPlane = Array(comps.prefix(4)) }
        } else if let arr = try? c.decode([Scalar].self, forKey: .nearPlane), arr.count >= 4 {
            nearPlane = Array(arr.prefix(4))
        }

        self._nearDistance = (try? c.decode(FlexibleDouble.self, forKey: .nearDistance)) ?? self._nearDistance

        // Resolution "w h"
        if let s = try? c.decode(String.self, forKey: .imageResolution) {
            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap { Int($0) }
            if comps.count >= 2 { imageResolution = (comps[0], comps[1]) }
        } else if let arr = try? c.decode([Int].self, forKey: .imageResolution), arr.count >= 2 {
            imageResolution = (arr[0], arr[1])
        }

        self.numSamples = (try? c.decode(Int.self, forKey: .numSamples)) ?? self.numSamples
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

let pi4 = 1.0 //4.0 * .pi

public struct Material: @unchecked Sendable, Decodable {
    public var id: String? = nil
    public var type: String? = nil
    public var ambient:  Vec3 = .zero
    public var diffuse:  Vec3 = .zero
    public var specular: Vec3 = .zero
    public var phong:    Scalar = 1
    public var mirror:   Vec3 = .zero
    public var ior:      Scalar = 1.5
    public var absorption: Vec3 = .zero
    enum CodingKeys: String, CodingKey {
        case id = "_id", type = "_type"
        case ambient = "AmbientReflectance", diffuse = "DiffuseReflectance", specular = "SpecularReflectance"
        case phong = "PhongExponent", mirror = "MirrorReflectance", ior = "RefractionIndex"
        case absorption = "AbsorptionCoefficient", absorptionIndex = "AbsorptionIndex"
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id   = try? c.decode(String.self, forKey: .id)
        self.type = try? c.decode(String.self, forKey: .type)
        ambient   = Self.decodeVec3(c, .ambient)   ?? ambient
        diffuse   = Self.decodeVec3(c, .diffuse)   ?? diffuse
        specular  = Self.decodeVec3(c, .specular)  ?? specular
        phong     = Scalar((try? c.decode(String.self, forKey: .phong)) ?? "1.0") ?? 1.0
        mirror    = Self.decodeVec3(c, .mirror)    ?? mirror
        ior       = (try? c.decode(Scalar.self, forKey: .ior)) ?? ior
        if let ab = Self.decodeVec3(c, .absorption) ?? Self.decodeVec3(c, .absorptionIndex) {
            absorption = ab
        }
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

public struct Lights: Decodable {
    public var ambient: Vec3 = .zero

    public var points: [PointLight] = []

    enum CodingKeys: String, CodingKey {
        case ambient = "AmbientLight"
        case pointLight = "PointLight"
    }

    public init(ambient: Vec3, points: [PointLight]) {
        self.ambient = ambient
        self.points = points
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let s = try? c.decode(String.self, forKey: .ambient) {
            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap(Scalar.init)
            if comps.count >= 3 { ambient = Vec3(comps[0], comps[1], comps[2]) }
        }
        // PointLight can be single or array
        if let arr = try? c.decode([PointLight].self, forKey: .pointLight) {
            points = arr
        } else if let one = try? c.decode(PointLight.self, forKey: .pointLight) {
            points = [one]
        }
    }
}

public struct PointLight: Decodable {
    public var id: String? = nil
    public var position: Vec3 = .zero
    public var intensity: Vec3 = .zero
    enum CodingKeys: String, CodingKey { case id = "_id"; case position = "Position"; case intensity = "Intensity" }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try? c.decode(String.self, forKey: .id)
        position = Self.decodeVec3(c, .position) ?? .zero
        intensity = (Self.decodeVec3(c, .intensity) ?? .zero) / pi4
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

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

public struct VertexData: Decodable {
    public var data: [Vec3] = []
    public var type: String = ""

    enum CodingKeys: String, CodingKey {
        case data = "_data"
        case type = "_type"
    }

    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        type = try root.decode(String.self, forKey: .type) ?? type

        if let vStr = try? root.decode(String.self, forKey: .data) {
            let lines = vStr.split(whereSeparator: \.isWhitespace).compactMap(Scalar.init).chunked(into: 3)
            data = lines.compactMap { line in
                if line.count < 3 { return nil }
                return Vec3(line[0], line[1], line[2])
            }
        } else if let arr = try? root.decode([[Scalar]].self, forKey: .data) {
            data = arr.compactMap { $0.count >= 3 ? Vec3($0[0], $0[1], $0[2]) : nil }
        }
    }
}

public struct Scene: Decodable {
    // global
    public var maxRecursionDepth: Int = 6
    public var backgroundColor: Vec3 = .zero
    public var shadowRayEpsilon: Scalar = 1e-3
    public var intersectionTestEpsilon: Scalar = 1e-6

    // data
    public var cameras: [Camera] = []
    public var lights: Lights = Lights(ambient: Vec3.zero, points: [])
    public var materials: [Material] = []
    public var vertexData: VertexData

    // objects (polymorphic)
    public var objects: [SceneObject] = []

    enum CodingKeys: String, CodingKey {
        case maxRecursionDepth = "MaxRecursionDepth"
        case backgroundColor = "BackgroundColor"
        case shadowRayEpsilon = "ShadowRayEpsilon"
        case intersectionTestEpsilon = "IntersectionTestEpsilon"
        case cameras = "Cameras"
        case lights = "Lights"
        case materials = "Materials"
        case vertexData = "VertexData"
        case objects = "Objects"
    }

    public init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)

        if let s = try? root.decode(String.self, forKey: .backgroundColor) {
            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap(Scalar.init)
            if comps.count >= 3 { backgroundColor = Vec3(comps[0], comps[1], comps[2]) }
        }
        maxRecursionDepth = (try? root.decode(Int.self, forKey: .maxRecursionDepth)) ?? maxRecursionDepth

        if let s = try? root.decode(String.self, forKey: .shadowRayEpsilon) {
            shadowRayEpsilon = Scalar(s) ?? shadowRayEpsilon
        }
        if let s = try? root.decode(String.self, forKey: .intersectionTestEpsilon) {
            intersectionTestEpsilon = Scalar(s) ?? intersectionTestEpsilon
        }

        // Cameras may nest as { "Camera": [...] } or single
        if let camsContainer = try? root.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .cameras) {
            if let camsArray = try? camsContainer.decode([Camera].self, forKey: .init("Camera")) {
                cameras = camsArray
            } else if let oneCam = try? camsContainer.decode(Camera.self, forKey: .init("Camera")) {
                cameras = [oneCam]
            }
        }

        // Lights
        lights = (try? root.decode(Lights.self, forKey: .lights)) ?? lights

        // Materials can be array or single
        if let matsContainer = try? root.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .materials) {
            if let mats = try? matsContainer.decode([Material].self, forKey: .init("Material")) {
                materials = mats
            } else if let one = try? matsContainer.decode(Material.self, forKey: .init("Material")) {
                materials = [one]
            }
        }

        vertexData = try root.decode(VertexData.self, forKey: .vertexData)

        // Objects: supported keys Sphere, Triangle, Mesh (single or arrays)
        if let objContainer = try? root.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .objects) {
            func decodeList<T: SceneObject>(_ name: String, _ type: T.Type) {
                let k = DynamicCodingKeys(name)
                if let many = try? objContainer.decode([T].self, forKey: k) {
                    objects.append(contentsOf: many)
                } else if let single = try? objContainer.decode(T.self, forKey: k) {
                    objects.append(single)
                }
            }
            decodeList("Sphere", Sphere.self)
            decodeList("Triangle", Triangle.self)
            decodeList("Mesh", Mesh.self)
            decodeList("Plane", Plane.self)
        }
    }
}

// Utility dynamic key to dig into nested containers with unknown keys.
public struct DynamicCodingKeys: CodingKey {
    public var stringValue: String
    public var intValue: Int? { nil }
    public init(_ string: String) { self.stringValue = string }
    public init?(stringValue: String) { self.stringValue = stringValue }
    public init?(intValue: Int) { return nil }
}
