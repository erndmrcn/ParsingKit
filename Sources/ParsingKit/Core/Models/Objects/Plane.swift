//
//  Plane.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.11.2025.
//

public final class Plane: SceneObject {
    public var centerIdx: Int = 1
    public var center: Vec3 = .zero
    public var normal: Vec3 = .zero

    public required init(from decoder: Decoder) throws {
        super.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id       = (try? c.decode(String.self, forKey: .id)) ?? self.id
        self.material = (try? c.decode(String.self, forKey: .material)) ?? ""
        self.centerIdx  = Int((try? c.decode(String.self, forKey: .centerIdx)) ?? "1") ?? 1
        self.normal  = Self.decodeVec3(c, .normal) ?? .zero
    }

    public required init() {
        super.init()
    }
}

// MARK: - Coding Keys
extension Plane {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case material = "Material"
        case centerIdx = "Point"
        case normal = "Normal"
    }
}

// MARK: - Decodable
extension Plane {
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
