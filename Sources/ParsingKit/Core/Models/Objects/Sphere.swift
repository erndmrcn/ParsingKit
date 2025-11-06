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

    public required init(from decoder: Decoder) throws {
        super.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id       = (try? c.decode(String.self, forKey: .id)) ?? self.id
        self.material = (try? c.decode(String.self, forKey: .material)) ?? ""
        self.centerIdx  = Int((try? c.decode(String.self, forKey: .centerIdx)) ?? "1") ?? 1
        self.radius  = Scalar((try? c.decode(String.self, forKey: .radius)) ?? "1") ?? 1
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
    }
}
