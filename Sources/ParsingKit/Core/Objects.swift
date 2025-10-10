//
//  Objects.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.10.2025.
//

import Foundation
import simd

open class SceneObject: @unchecked Sendable, Decodable {
    public var id: String? = nil
    public var material: String?
    public init() {}
}

public final class Plane: SceneObject {
    public var centerIdx: Int = 1
    public var center: Vec3 = .zero
    public var normal: Vec3 = .zero

    enum CodingKeys: String, CodingKey { case id = "_id"; case material = "Material"; case centerIdx = "Point"; case normal = "Normal" }

    public required init(from decoder: Decoder) throws {
        super.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id       = (try? c.decode(String.self, forKey: .id)) ?? self.id
        self.material = (try? c.decode(String.self, forKey: .material)) ?? ""
        self.centerIdx  = Int((try? c.decode(String.self, forKey: .centerIdx)) ?? "1") ?? 1
        self.normal  = Self.decodeVec3(c, .normal) ?? .zero
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

public final class Sphere: SceneObject {
    public var centerIdx: Int = 1
    public var center: Vec3 = .zero
    public var radius: Scalar = 1

    enum CodingKeys: String, CodingKey { case id = "_id"; case material = "Material"; case centerIdx = "Center"; case radius = "Radius" }

    public required init(from decoder: Decoder) throws {
        super.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id       = (try? c.decode(String.self, forKey: .id)) ?? self.id
        self.material = (try? c.decode(String.self, forKey: .material)) ?? ""
        self.centerIdx  = Int((try? c.decode(String.self, forKey: .centerIdx)) ?? "1") ?? 1
        self.radius  = Scalar((try? c.decode(String.self, forKey: .radius)) ?? "1") ?? 1
    }
}

// Triangle (by 1-based indices into vertexData)
public final class Triangle: SceneObject {
    public var indices: [Int] = [1,2,3] // default
    public var v0: Vec3 = .zero
        public var v1: Vec3 = .zero
        public var v2: Vec3 = .zero
        public var e1: Vec3 = .zero           // v1 - v0
        public var e2: Vec3 = .zero           // v2 - v0
        public var isPrepared: Bool = false   // to avoid re-filling

    enum CodingKeys: String, CodingKey { case id = "_id"; case material = "Material"; case indices = "Indices" }
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
    }
}

public struct Face: Decodable {
    public var data: [Int] = []
    public var type: String = ""

    enum CodingKeys: String, CodingKey {
        case data = "_data"
        case type = "_type"
    }

    public init() {
        data = []
        type = ""
    }

    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)

        type = try root.decode(String.self, forKey: .type) ?? type

        if let arr2D = try? root.decode([Int].self, forKey: .data) {
            data = arr2D
        } else if let s = try? root.decode(String.self, forKey: .data) {
            let lines = s.split(whereSeparator: \.isWhitespace)
            data = lines.compactMap { Int($0) }
        }
    }
}

// Mesh (faces as flattened triplets)
public final class Mesh: SceneObject {
    public var faces: Face  = .init() // [[i,j,k]] 1-based
    public var triangles: [Triangle] = []
    enum CodingKeys: String, CodingKey { case id = "_id"; case material = "Material"; case faces = "Faces" }

    public required init(from decoder: any Decoder) throws {
        super.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id       = (try? c.decode(String.self, forKey: .id)) ?? self.id
        self.material = (try? c.decode(String.self, forKey: .material)) ?? ""
        self.faces = try c.decode(Face.self, forKey: .faces)

    }
}
