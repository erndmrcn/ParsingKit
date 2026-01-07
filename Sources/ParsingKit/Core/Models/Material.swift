//
//  Material.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.11.2025.
//

import math_h

public struct Material: @unchecked Sendable {
    public var id: String? = nil
    public var type: String? = nil
    public var degamma: Bool = false
    public var ambient:  Vec3 = .zero
    public var diffuse:  Vec3 = .zero
    public var specular: Vec3 = .zero
    public var phong:    Scalar = 1
    public var mirror:   Vec3 = .zero
    /// index of refraction
    public var ior:      Scalar = 0
    public var absorption: Vec3 = .zero
    public var absorptionIndex: Scalar = .zero
    public var roughness: Scalar = 0
    public var radiance: Vec3 = .zero
    public var isEmissive: Bool { !(radiance == .zero) }
}

// MARK: - Coding Keys
extension Material {
    enum CodingKeys: String, CodingKey {
        case id = "_id", type = "_type"
        case ambient = "AmbientReflectance", diffuse = "DiffuseReflectance", specular = "SpecularReflectance"
        case phong = "PhongExponent", mirror = "MirrorReflectance", ior = "RefractionIndex"
        case absorption = "AbsorptionCoefficient"
        case absorptionIndex = "AbsorptionIndex"
        case roughness = "Roughness"
        case degamma = "_degamma"
    }
}

// MARK: - Decodable
extension Material: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id   = try? c.decode(String.self, forKey: .id)
        self.type = try? c.decode(String.self, forKey: .type)
        self.degamma = (try? c.decode(String.self, forKey: .degamma) ?? "false") == "true" ? true : false
        ambient   = Self.decodeVec3(c, .ambient)   ?? ambient
        diffuse   = Self.decodeVec3(c, .diffuse)   ?? diffuse
        specular  = Self.decodeVec3(c, .specular)  ?? specular

        if degamma {
            ambient = srgbToLinear(ambient)
            diffuse = srgbToLinear(diffuse)
            specular = srgbToLinear(specular)
        }

        phong     = Scalar((try? c.decode(String.self, forKey: .phong)) ?? "1.0") ?? 1.0
        roughness     = Scalar((try? c.decode(String.self, forKey: .roughness)) ?? "0.0") ?? self.roughness
        mirror    = Self.decodeVec3(c, .mirror)    ?? mirror
        ior       = Scalar((try? c.decode(String.self, forKey: .ior)) ?? "0.0") ?? self.ior
        absorptionIndex       = Scalar((try? c.decode(String.self, forKey: .absorptionIndex)) ?? "0.0") ?? self.absorptionIndex
        if let ab = Self.decodeVec3(c, .absorption) {
            absorption = ab
        }
    }

    @inline(__always)
    func srgbToLinear(_ c: Float) -> Float {
        pow(c, 2.2)
    }

    func srgbToLinear(_ v: SIMD3<Float>) -> SIMD3<Float> {
        SIMD3(srgbToLinear(v.x), srgbToLinear(v.y), srgbToLinear(v.z))
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
