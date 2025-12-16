//
//  Triangle.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.11.2025.
//

public final class Triangle: SceneObject {
    public var indices: [Int] = [1,2,3] // default
    public var v0: Vec3 = .zero
    public var v1: Vec3 = .zero
    public var v2: Vec3 = .zero
    public var n0: Vec3 = .zero
    public var n1: Vec3 = .zero
    public var n2: Vec3 = .zero
    public var e1: Vec3 = .zero           // v1 - v0
    public var e2: Vec3 = .zero           // v2 - v0
    public var uv0: Vec2 = .zero
    public var uv1: Vec2 = .zero
    public var uv2: Vec2 = .zero
    public var ltw: Mat4 = .identity
    public var centroid: Vec3 = .zero
    public var resetTransform: Bool = false
    public var transformTokens: String?
    public var motionBlur: Vec3 = .zero
    public var textures: String = ""

    public required init(from decoder: Decoder) throws {
        super.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id       = (try? c.decode(String.self, forKey: .id)) ?? self.id
        self.material = (try? c.decode(String.self, forKey: .material)) ?? ""

        if let arr = try? c.decode([Int].self, forKey: .indices), arr.count >= 3 {
            indices = Array(arr.prefix(3))
        } else if let s = try? c.decode(String.self, forKey: .indices) {
            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap{ Int($0) }
            if comps.count >= 3 { indices = Array(comps.prefix(3)) }
        }

        self.transformTokens = (try? c.decode(String.self, forKey: .transformTokens)) ?? ""
        self.resetTransform = ((try? c.decode(String.self, forKey: .resetTransform)) ?? "false") == "true" ? true : false
    }

    public required init() {
        super.init()
    }

    public init(_ v0: Vec3, _ v1: Vec3, _ v2: Vec3, _ n0: Vec3, _ n1: Vec3, _ n2: Vec3) {
        super.init()
        self.v0 = v0
        self.v1 = v1
        self.v2 = v2
        self.n0 = n0
        self.n1 = n1
        self.n2 = n2
        self.e1 = v1 - v0
        self.e2 = v2 - v0
        self.centroid = (v0 + v1 + v2) * 0.33333

    }
}

// MARK: - Coding Keys
extension Triangle {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case material = "Material"
        case indices = "Indices"
        case resetTransform = "_resetTransform"
        case transformTokens = "Transformations"
    }
}
