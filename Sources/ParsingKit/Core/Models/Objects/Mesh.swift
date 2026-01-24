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
    public var textures: String = ""
    public var transformTokens: String?
    public var resetTransform: Bool = false
    public var transformationMatrix: Mat4 = .identity
    public var motionBlur: Vec3 = .zero

    public required init(from decoder: any Decoder) throws {
        super.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id       = (try? c.decode(String.self, forKey: .id)) ?? self.id
        self.shadingMode = (try? c.decode(String.self, forKey: .shadingMode)) ?? self.shadingMode
        self.material = (try? c.decode(String.self, forKey: .material)) ?? ""
        self.textures = (try? c.decode(String.self, forKey: .textures)) ?? ""
        self.transformTokens = (try? c.decode(String.self, forKey: .transformations)) ?? ""
        self.resetTransform = ((try? c.decode(String.self, forKey: .resetTransform)) ?? "false") == "true" ? true : false
        self.faces = try c.decode(Face.self, forKey: .faces)
        self.motionBlur = Self.decodeVec3(c, .motionBlur) ?? .zero
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
        case resetTransform = "_resetTransform"
        case transformations = "Transformations"
        case motionBlur = "MotionBlur"
        case textures = "Textures"
    }
}

public final class LightMesh: SceneObject {
    public var faces: Face  = .init() // [[i,j,k]] 1-based
    public var shadingMode: String = "flat"
    public var triangles: [Triangle] = []
    public var textures: String = ""
    public var transformTokens: String?
    public var resetTransform: Bool = false
    public var transformationMatrix: Mat4 = .identity
    public var motionBlur: Vec3 = .zero
    public var radiance: Vec3 = .zero

    public required init(from decoder: any Decoder) throws {
        super.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        var id = (try? c.decode(String.self, forKey: .id)) ?? self.id
        self.id = "LightMesh \(id)";
        self.shadingMode = (try? c.decode(String.self, forKey: .shadingMode)) ?? self.shadingMode
        self.material = (try? c.decode(String.self, forKey: .material)) ?? ""
        self.textures = (try? c.decode(String.self, forKey: .textures)) ?? ""
        self.transformTokens = (try? c.decode(String.self, forKey: .transformations)) ?? ""
        self.resetTransform = ((try? c.decode(String.self, forKey: .resetTransform)) ?? "false") == "true" ? true : false
        self.faces = try c.decode(Face.self, forKey: .faces)
        self.motionBlur = Self.decodeVec3(c, .motionBlur) ?? .zero
        self.radiance = Self.decodeVec3(c, .radiance) ?? .zero
//        self.radiance.normalizeIfNeeded()
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

    public required init() {
        super.init()
    }
}

// MARK: - Coding Keys
extension LightMesh {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case material = "Material"
        case faces = "Faces"
        case shadingMode = "_shadingMode"
        case resetTransform = "_resetTransform"
        case transformations = "Transformations"
        case motionBlur = "MotionBlur"
        case textures = "Textures"
        case radiance = "Radiance"
    }
}
