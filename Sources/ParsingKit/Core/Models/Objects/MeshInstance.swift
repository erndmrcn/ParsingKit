//
//  MeshInstance.swift
//  ParsingKit
//
//  Created by Eren Demircan on 2.11.2025.
//

// MARK: - MeshInstance object type
public class MeshInstance: SceneObject, Sendable {
    public var baseMeshID: String = ""
    public var resetTransform: Bool = false
    public var transformTokens: String?
    public var motionBlur: Vec3 = .zero

    public required init(from decoder: any Decoder) throws {
        super.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id       = (try? c.decode(String.self, forKey: .id)) ?? self.id
        self.id = "Instance \(id)"
        self.baseMeshID = (try? c.decode(String.self, forKey: .baseMeshID)) ?? self.baseMeshID
        self.material = (try? c.decode(String.self, forKey: .material)) ?? ""
        self.transformTokens = (try? c.decode(String.self, forKey: .transformTokens)) ?? ""
        self.resetTransform = ((try? c.decode(String.self, forKey: .resetTransform)) ?? "false") == "true" ? true : false
        self.motionBlur = Self.decodeVec3(c, .motionBlur) ?? .zero
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
extension MeshInstance {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case baseMeshID = "_baseMeshId"
        case resetTransform = "_resetTransform"
        case material = "Material"
        case transformTokens = "Transformations"
        case motionBlur = "MotionBlur"
    }
}
