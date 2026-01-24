//
//  Sphere.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.11.2025.
//

public final class Sphere: SceneObject {
    public var centerIdx: Int = 1
    public var center: Vec3 = .zero
    public var radius: Scalar = 1
    public var resetTransform: Bool = false
    public var transformTokens: String?
    public var textures: String = ""

    public required init(from decoder: Decoder) throws {
        super.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id       = (try? c.decode(String.self, forKey: .id)) ?? self.id
        self.material = (try? c.decode(String.self, forKey: .material)) ?? ""
        self.centerIdx  = Int((try? c.decode(String.self, forKey: .centerIdx)) ?? "1") ?? 1
        self.radius  = Scalar((try? c.decode(String.self, forKey: .radius)) ?? "1") ?? 1
        self.transformTokens = (try? c.decode(String.self, forKey: .transformTokens)) ?? ""
        self.textures = (try? c.decode(String.self, forKey: .textures)) ?? ""
        self.resetTransform = ((try? c.decode(String.self, forKey: .resetTransform)) ?? "false") == "true" ? true : false
    }

    public required init() {
        super.init()
    }
}

// MARK: - Coding Keys
extension Sphere {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case material = "Material"
        case centerIdx = "Center"
        case radius = "Radius"
        case resetTransform = "_resetTransform"
        case transformTokens = "Transformations"
        case textures = "Textures"
    }
}

public final class LightSphere: SceneObject {
    public var centerIdx: Int = 1
    public var center: Vec3 = .zero
    public var radius: Scalar = 1
    public var resetTransform: Bool = false
    public var transformTokens: String?
    public var textures: String = ""
    public var radiance: Vec3 = .zero

    public required init(from decoder: Decoder) throws {
        super.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id       = (try? c.decode(String.self, forKey: .id)) ?? self.id
        self.material = (try? c.decode(String.self, forKey: .material)) ?? ""
        self.centerIdx  = Int((try? c.decode(String.self, forKey: .centerIdx)) ?? "1") ?? 1
        self.radius  = Scalar((try? c.decode(String.self, forKey: .radius)) ?? "1") ?? 1
        self.transformTokens = (try? c.decode(String.self, forKey: .transformTokens)) ?? ""
        self.textures = (try? c.decode(String.self, forKey: .textures)) ?? ""
        self.resetTransform = ((try? c.decode(String.self, forKey: .resetTransform)) ?? "false") == "true" ? true : false
        self.radiance = (Self.decodeVec3(c, .radiance) ?? .zero)
//        self.radiance.normalizeIfNeeded()
    }

    public required init() {
        super.init()
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

// MARK: - Coding Keys
extension LightSphere {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case material = "Material"
        case centerIdx = "Center"
        case radius = "Radius"
        case resetTransform = "_resetTransform"
        case transformTokens = "Transformations"
        case textures = "Textures"
        case radiance = "Radiance"
    }
}
