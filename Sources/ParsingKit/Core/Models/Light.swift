//
//  Light.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.11.2025.
//

public struct Lights {
    public var ambient: Vec3 = .zero

    public var points: [PointLight] = []
}

// MARK: - Coding Keys
extension Lights {
    enum CodingKeys: String, CodingKey {
        case ambient = "AmbientLight"
        case pointLight = "PointLight"
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
            points = arr
        } else if let one = try? c.decode(PointLight.self, forKey: .pointLight) {
            points = [one]
        }
    }
}

// MARK: - Point Light
public struct PointLight {
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
extension PointLight: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try? c.decode(String.self, forKey: .id)
        position = Self.decodeVec3(c, .position) ?? .zero
        intensity = (Self.decodeVec3(c, .intensity) ?? .zero) / Constants.pi4
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
