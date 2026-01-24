//
//  Light.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.11.2025.
//

public protocol Light { }

public struct Lights {
    public var ambient: Vec3 = .zero

    public var points: [Light] = []
}

// MARK: - Coding Keys
extension Lights {
    enum CodingKeys: String, CodingKey {
        case ambient = "AmbientLight"
        case pointLight = "PointLight"
        case areaLight = "AreaLight"
        case envLight = "SphericalDirectionalLight"
        case directional = "DirectionalLight"
        case spotLight = "SpotLight"
    }
}

// MARK: - Decodable
extension Lights: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let s = try? c.decode(String.self, forKey: .ambient) {
            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap(Scalar.init)
            if comps.count >= 3 { ambient = Vec3(comps[0], comps[1], comps[2]) }
        }
        // PointLight can be single or array
        if let arr = try? c.decode([PointLight].self, forKey: .pointLight) {
            points += arr
        } else if let one = try? c.decode(PointLight.self, forKey: .pointLight) {
            points += [one]
        }

        if let arr = try? c.decode([AreaLight].self, forKey: .areaLight) {
            points += arr
        } else if let one = try? c.decode(AreaLight.self, forKey: .areaLight) {
            points += [one]
        }

        if let arr = try? c.decode([SphericalDirectionalLight].self, forKey: .envLight) {
            points += arr
        } else if let one = try? c.decode(SphericalDirectionalLight.self, forKey: .envLight) {
            points += [one]
        }

        if let arr = try? c.decode([SpotLight].self, forKey: .spotLight) {
            points += arr
        } else if let one = try? c.decode(SpotLight.self, forKey: .spotLight) {
            points += [one]
        }

        if let arr = try? c.decode([DirectionalLight].self, forKey: .directional) {
            points += arr
        } else if let one = try? c.decode(DirectionalLight.self, forKey: .directional) {
            points += [one]
        }
    }
}

// MARK: - Point Light
public struct PointLight: @unchecked Sendable, Light {
    public var id: String? = nil
    public var position: Vec3 = .zero
    public var intensity: Vec3 = .zero
}

// MARK: Coding Keys
extension PointLight {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case position = "Position"
        case intensity = "Intensity"
    }
}

// MARK: - Decodable
extension PointLight: @unchecked Sendable, Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try? c.decode(String.self, forKey: .id)
        position = Self.decodeVec3(c, .position) ?? .zero
        intensity = (Self.decodeVec3(c, .intensity) ?? .zero)
//        intensity.normalizeIfNeeded()
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

// MARK: - Directional Light
public struct DirectionalLight: @unchecked Sendable, Light {
    public var id: String? = nil
    public var direction: Vec3 = .zero
    public var radiance: Vec3 = .zero
}

// MARK: - Coding Keys
extension DirectionalLight {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case direction = "Direction"
        case radiance = "Radiance"
    }
}

// MARK: - Decodable
extension DirectionalLight: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try? c.decode(String.self, forKey: .id)
        direction = Self.decodeVec3(c, .direction) ?? .zero
        radiance = Self.decodeVec3(c, .radiance) ?? .zero
//        radiance.normalizeIfNeeded()
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

// MARK: - Spot Light
public struct SpotLight: @unchecked Sendable, Light {
    public var id: String? = nil
    public var position: Vec3 = .zero
    public var direction: Vec3 = .zero
    public var intensity: Vec3 = .zero
    public var coverageAngle: Scalar = 0
    public var fallOfAngle: Scalar = 0
}

// MARK: - CodingKeys
extension SpotLight {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case position = "Position"
        case direction = "Direction"
        case intensity = "Intensity"
        case coverageAngle = "CoverageAngle"
        case fallOfAngle = "FalloffAngle"
    }
}

// MARK: - Decodable
extension SpotLight: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try? c.decode(String.self, forKey: .id)
        position = Self.decodeVec3(c, .position) ?? .zero
        direction = Self.decodeVec3(c, .direction) ?? .zero
        intensity = Self.decodeVec3(c, .intensity) ?? .zero
//        intensity.normalizeIfNeeded()
        coverageAngle = Scalar(try c.decode(String.self, forKey: .coverageAngle) ?? "0") ?? 1
        fallOfAngle = Scalar(try c.decode(String.self, forKey: .fallOfAngle) ?? "0") ?? 1
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

public enum EnvMapType: String, Codable {
    case latlong, probe
}

public enum EnvSampler: String, Codable {
    case cosine, nearest
}

// MARK: - Spherical Directional Light
public struct SphericalDirectionalLight: @unchecked Sendable, Light {
    public var id: String? = nil
    public var type: EnvMapType = .latlong
    public var imageId: Scalar = .zero
    public var sampler: EnvSampler = .cosine
}

// MARK: - CodingKeys
extension SphericalDirectionalLight {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type = "_type"
        case imageId = "ImageId"
        case sampler = "Sampler"
    }
}

// MARK: - Decodable
extension SphericalDirectionalLight: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try? c.decode(String.self, forKey: .id)
        type = (try? c.decode(EnvMapType.self, forKey: .type) ?? .latlong) ?? .latlong
        imageId = Scalar(try c.decode(String.self, forKey: .imageId) ?? "0") ?? 1
        sampler = (try? c.decode(EnvSampler.self, forKey: .type) ?? .cosine) ?? .cosine
    }
}

// MARK: - Area Light
public struct AreaLight: @unchecked Sendable, Light {
    public var id: String? = nil
    public var position: Vec3 = .zero
    public var normal: Vec3 = .zero
    public var size: Scalar = 1
    public var radiance: Vec3 = .zero
    public var samples: [Scalar] = []
}

// MARK: - CodingKeys
extension AreaLight {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case position = "Position"
        case normal = "Normal"
        case size = "Size"
        case radiance = "Radiance"
    }
}

// MARK: - Decodable
extension AreaLight: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try? c.decode(String.self, forKey: .id)
        position = Self.decodeVec3(c, .position) ?? .zero
        normal = Self.decodeVec3(c, .normal) ?? .zero
        size = Scalar(try c.decode(String.self, forKey: .size) ?? "0") ?? 1
        radiance = Self.decodeVec3(c, .radiance) ?? .zero
//        radiance.normalizeIfNeeded()
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
