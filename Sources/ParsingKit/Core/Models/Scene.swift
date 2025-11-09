//
//  Scene.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.11.2025.
//

import Foundation
import simd

public struct Scene: @unchecked Sendable {
    public var path: URL?
    // global settings
    public var maxRecursionDepth: Int = 6
    public var backgroundColor: Vec3 = .zero
    public var shadowRayEpsilon: Scalar = 1e-3
    public var intersectionTestEpsilon: Scalar = 0

    // data
    public var cameras: [Camera] = []
    public var lights: Lights = Lights(ambient: Vec3.zero, points: [])
    public var materials: [Material] = []
    public var vertexData: VertexData
    public var transformations: Transformations

    // objects
    public var objects: [SceneObject] = []              // Sphere, Triangle, Mesh, Plane, MeshInstance
}

// MARK: - Coding Keys
extension Scene {
    enum CodingKeys: String, CodingKey {
        case maxRecursionDepth = "MaxRecursionDepth"
        case backgroundColor = "BackgroundColor"
        case shadowRayEpsilon = "ShadowRayEpsilon"
        case intersectionTestEpsilon = "IntersectionTestEpsilon"
        case cameras = "Cameras"
        case lights = "Lights"
        case materials = "Materials"
        case vertexData = "VertexData"
        case objects = "Objects"
        case transformations = "Transformations"
    }
}

// MARK: - Decodable
extension Scene: Decodable {
    public init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)

        // Background
        if let s = try? root.decode(String.self, forKey: .backgroundColor) {
            let comps = s.split { $0 == " " || $0 == "\t" }.compactMap(Scalar.init)
            if comps.count >= 3 { backgroundColor = Vec3(comps[0], comps[1], comps[2]) }
        }

        // Scalars
        maxRecursionDepth = (try? root.decode(Int.self, forKey: .maxRecursionDepth)) ?? maxRecursionDepth
        if let s = try? root.decode(String.self, forKey: .shadowRayEpsilon) { shadowRayEpsilon = Scalar(s) ?? shadowRayEpsilon }
        if let s = try? root.decode(String.self, forKey: .intersectionTestEpsilon) { intersectionTestEpsilon = Scalar(s) ?? intersectionTestEpsilon }

        // Cameras
        if let camsContainer = try? root.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .cameras) {
            if let camsArray = try? camsContainer.decode([Camera].self, forKey: .init("Camera")) {
                cameras = camsArray
            } else if let single = try? camsContainer.decode(Camera.self, forKey: .init("Camera")) {
                cameras = [single]
            }
        }

        // Lights
        lights = (try? root.decode(Lights.self, forKey: .lights)) ?? lights

        // Materials
        if let matsContainer = try? root.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .materials) {
            if let mats = try? matsContainer.decode([Material].self, forKey: .init("Material")) {
                materials = mats
            } else if let one = try? matsContainer.decode(Material.self, forKey: .init("Material")) {
                materials = [one]
            }
        }

        // VertexData & Transformations
        vertexData = try root.decode(VertexData.self, forKey: .vertexData)
        transformations = try root.decodeIfPresent(Transformations.self, forKey: .transformations) ?? .init()

        // Objects (Sphere, Triangle, Mesh, Plane, MeshInstance)
        if let objContainer = try? root.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .objects) {
            func decodeList<T: SceneObject>(_ keyName: String, _ type: T.Type) {
                let key = DynamicCodingKeys(keyName)
                if let many = try? objContainer.decode([T].self, forKey: key) {
                    objects.append(contentsOf: many)
                } else if let one = try? objContainer.decode(T.self, forKey: key) {
                    objects.append(one)
                }
            }

            decodeList("Sphere", Sphere.self)
            decodeList("Triangle", Triangle.self)
            decodeList("Mesh", Mesh.self)
            decodeList("Plane", Plane.self)
            decodeList("MeshInstance", MeshInstance.self)
        }

        for (i, camera) in self.cameras.enumerated() {
            let M = composeTransform(tokens: camera.transformTokens, reset: true)

            let scaleX = length(Vec3(M[0][0], M[1][0], M[2][0]))
            let scaleY = length(Vec3(M[0][1], M[1][1], M[2][1]))
            let scaleZ = length(Vec3(M[0][2], M[1][2], M[2][2]))
            let avgScale = (scaleX + scaleY + scaleZ) / 3.0

            let M_rot = Mat4(
                Vec4(M[0][0]/scaleX, M[0][1]/scaleY, M[0][2]/scaleZ, 0),
                Vec4(M[1][0]/scaleX, M[1][1]/scaleY, M[1][2]/scaleZ, 0),
                Vec4(M[2][0]/scaleX, M[2][1]/scaleY, M[2][2]/scaleZ, 0),
                Vec4(0, 0, 0, 1)
            )

            cameras[i].position = transformPoint(M, camera.position)

            cameras[i].gaze = normalize(transformVector(M_rot, camera.gaze))
            cameras[i].up = normalize(transformVector(M_rot, camera.up))

            if camera.type?.lowercased() == "lookat" {
                cameras[i].gazePoint = transformPoint(M, camera.gazePoint)
            }

            if camera.type?.lowercased() == "lookat" {
                if let fovy = camera.fovy {
                    cameras[i].fovy = fovy / avgScale
                }
            } else {
                cameras[i].nearDistance = camera.nearDistance * max(max(scaleX, scaleY), scaleZ)
            }

            cameras[i].transformationMatrix = M
        }
    }
}

// MARK: - Transform Composition
extension Scene {
    public func composeTransform(tokens: String?, reset: Bool, base: Mat4 = matrix_identity_double4x4) -> Mat4 {
        guard let tokens, !tokens.isEmpty else { return base }

        var M = reset ? matrix_identity_double4x4 : base

        for tok in tokens.split(separator: " ") {
            if tok.hasPrefix("t") {
                let key = String(tok.dropFirst())
                if let t = transformations.translations.first(where: { $0.id == key }) {
                    let xyz = t.data.split(separator: " ").compactMap { Double($0) }
                    if xyz.count == 3 {
                        let T = Mat4(translation: Vec3(xyz[0], xyz[1], xyz[2]))
                        M = T * M
                    }
                }
            } else if tok.hasPrefix("r") {
                let key = String(tok.dropFirst())
                if let r = transformations.rotations.first(where: { $0.id == key }) {
                    let vals = r.data.split(separator: " ").compactMap { Double($0) }
                    if vals.count == 4 {
                        let R = Mat4(rotation: vals[0], axis: Vec3(vals[1], vals[2], vals[3]))
                        M = R * M
                    }
                }
            } else if tok.hasPrefix("s") {
                let key = String(tok.dropFirst())
                if let s = transformations.scalings.first(where: { $0.id == key }) {
                    let xyz = s.data.split(separator: " ").compactMap { Double($0) }
                    if xyz.count == 3 {
                        let S = Mat4(scaling: Vec3(xyz[0], xyz[1], xyz[2]))
                        M = S * M
                    }
                }
            }
        }
        return M
    }
}

@inlinable @inline(__always)
public func transformPoint(_ M: Mat4, _ p: Vec3) -> Vec3 {
    let v = M * Vec4(p, 1.0)
    return Vec3(v.x, v.y, v.z)
}

@inlinable @inline(__always)
public func transformVector(_ M: Mat4, _ v: Vec3) -> Vec3 {
    let r = M * Vec4(v, 0.0)
    return Vec3(r.x, r.y, r.z)
}
