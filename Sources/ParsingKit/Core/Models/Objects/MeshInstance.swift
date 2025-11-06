//
//  MeshInstance.swift
//  ParsingKit
//
//  Created by Eren Demircan on 2.11.2025.
//

// MARK: - MeshInstance object type
public class MeshInstance: SceneObject, Sendable {
    public var baseMeshID: String = ""
    public var resetTransform: Bool = true
    public var transformTokens: String?

    public required init(from decoder: any Decoder) throws {
        super.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id       = (try? c.decode(String.self, forKey: .id)) ?? self.id
        self.baseMeshID = (try? c.decode(String.self, forKey: .baseMeshID)) ?? self.baseMeshID
        self.material = (try? c.decode(String.self, forKey: .material)) ?? ""
        self.transformTokens = (try? c.decode(String.self, forKey: .transformTokens)) ?? ""
        self.resetTransform = try c.decode(Bool.self, forKey: .resetTransform)
    }

    public required init() {
        super.init()
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
    }
}
