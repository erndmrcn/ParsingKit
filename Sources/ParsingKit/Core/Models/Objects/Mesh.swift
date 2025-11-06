//
//  Mesh.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.11.2025.
//

import simd

public final class Mesh: SceneObject {
    public var faces: Face  = .init() // [[i,j,k]] 1-based
    public var shadingMode: String = "flat"
    public var triangles: [Triangle] = []
    public var transformations: [String] = []
    public var transformationMatrix: Mat4 = .identity

    public required init(from decoder: any Decoder) throws {
        super.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id       = (try? c.decode(String.self, forKey: .id)) ?? self.id
        self.shadingMode = (try? c.decode(String.self, forKey: .shadingMode)) ?? self.shadingMode
        self.material = (try? c.decode(String.self, forKey: .material)) ?? ""
        self.faces = try c.decode(Face.self, forKey: .faces)

        if let transforms = try? c.decode(String.self, forKey: .transformations) {
            for transform in transforms.split(separator: " ") {
                transformations.append(String(transform))
            }
        }
    }
    
    public required init() {
        super.init()
    }
}

// MARK: - Coding Keys
extension Mesh {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case material = "Material"
        case faces = "Faces"
        case shadingMode = "_shadingMode"
        case transformations = "Transformations"
    }
}
