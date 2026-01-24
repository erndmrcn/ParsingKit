//
//  Camera.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.11.2025.
//

import Foundation
import simd

public struct PathTracerOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    static let importanceSampling = PathTracerOptions(rawValue: 1 << 0) // cosine hemisphere
    static let nextEventEstimation = PathTracerOptions(rawValue: 1 << 1)
    static let misBalance = PathTracerOptions(rawValue: 1 << 2)
    static let misPower = PathTracerOptions(rawValue: 1 << 3)
    static let mis01 = PathTracerOptions(rawValue: 1 << 4)
    static let russianRoulette = PathTracerOptions(rawValue: 1 << 5)
}

public extension PathTracerOptions {

    /// Matches ShaderTypes.h:
    /// RP_IMPORTANCE_SAMPLING = 1<<0
    /// RP_NEE                 = 1<<1
    /// RP_RUSSIAN_ROULETTE    = 1<<2
    func toGPUFlags() -> UInt32 {
        var f: UInt32 = 0
        if contains(.importanceSampling)   { f |= (1 << 0) } // RP_IMPORTANCE_SAMPLING
        if contains(.nextEventEstimation)  { f |= (1 << 1) } // RP_NEE
        if contains(.russianRoulette)      { f |= (1 << 2) } // RP_RUSSIAN_ROULETTE
        return f
    }

    /// Matches your RendererParamsGPU.misHeuristic:
    /// 0 = balance, 1 = power, 2 = 01
    func toGPUMISHeuristic() -> UInt32 {
        // If multiple are present, pick a priority deterministically
        if contains(.mis01)    { return 2 }
        if contains(.misPower) { return 1 }
        // default (including .misBalance or none)
        return 0
    }
}

public struct Res: Hashable {
    public var x: Int
    public var y: Int
}

extension Mat4: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}

public enum RendererType: String, Decodable {
    case raytracer = "RayTracing"
    case pathtracer = "PathTracing"
}

public struct Camera {
    public static func == (lhs: Camera, rhs: Camera) -> Bool {
        lhs.id == rhs.id
    }
    
    public var id: String? = nil
    public var type: String? = nil
    public var handedness: String? = nil
    public var fovy: Scalar? = .zero
    public var position: Vec3 = .zero
    public var gaze: Vec3 = .zero
    public var gazePoint: Vec3 = .zero
    public var up: Vec3 = .zero
    public var nearPlane: [Scalar] = [-1, 1, -1, 1]
    public var nearDistance: Scalar = 1
    public var imageResolution: Res = .init(x: 512, y: 512)
    public var numSamples: Int = 1
    public var maxRecursionDepth: Int = 0
    public var minRecursionDepth: Int = 0
    public var imageName: String = "image.png"
    public var transformTokens: String?
    public var transformationMatrix: Mat4 = .identity
    public var focusDistance: Scalar = .zero
    public var apertureSize: Scalar = .zero
    public var tonemap: [Tonemap] = []
    public var comment: String? = nil
    public var renderer: RendererType = .raytracer
    public var splittingFactor: Int = 1
    public var rendererParams: String? = nil
    public var pathTracerOptions: PathTracerOptions? = nil
}

// MARK: - Coding Keys
extension Camera {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type = "_type"
        case handedness = "_handedness"
        case fovy = "FovY"
        case position = "Position"
        case gaze = "Gaze"
        case gazePoint = "GazePoint"
        case up = "Up"
        case nearPlane = "NearPlane"
        case nearDistance = "NearDistance"
        case imageResolution = "ImageResolution"
        case numSamples = "NumSamples"
        case maxRecursionDepth = "MaxRecursionDepth"
        case imageName = "ImageName"
        case transformations = "Transformations"
        case focusDistance = "FocusDistance"
        case apertureSize = "ApertureSize"
        case tonemap = "Tonemap"
        case minRecursionDepth = "MinRecursionDepth"
        case comment = "Comment"
        case renderer = "Renderer"
        case rendererParams = "RendererParams"
        case splittingFactor = "SplittingFactor"
    }
}

// MARK: - Decodable
extension Camera: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? c.decode(String.self, forKey: .id)
        self.type = try? c.decode(String.self, forKey: .type)
        self.handedness = try? c.decode(String.self, forKey: .handedness)
        self.fovy = Scalar((try? c.decode(String.self, forKey: .fovy)) ?? "0") ?? .zero
        self.apertureSize = Scalar((try? c.decode(String.self, forKey: .apertureSize)) ?? "0") ?? .zero
        self.focusDistance = Scalar((try? c.decode(String.self, forKey: .focusDistance)) ?? "0") ?? .zero
        self.position = Self.decodeVec3(c, .position) ?? position
        self.gaze = Self.decodeVec3(c, .gaze) ?? gaze
        self.gazePoint = Self.decodeVec3(c, .gazePoint) ?? gazePoint
        self.up = Self.decodeVec3(c, .up) ?? up
        self.transformTokens = (try? c.decode(String.self, forKey: .transformations)) ?? ""
        if let s = try? c.decode(String.self, forKey: .nearPlane) {
            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap(Scalar.init); if comps.count >= 4 { nearPlane = Array(comps.prefix(4)) }
        } else if let arr = try? c.decode([Scalar].self, forKey: .nearPlane), arr.count >= 4 {
            nearPlane = Array(arr.prefix(4))
        }

        if let s = try? c.decode(String.self, forKey: .imageResolution) {
            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap { Int($0) }
            if comps.count >= 2 { imageResolution = .init(x: comps[0], y: comps[1]) }
        } else if let arr = try? c.decode([Int].self, forKey: .imageResolution), arr.count >= 2 {
            imageResolution = .init(x: arr[0], y: arr[1])
        }

        self.numSamples = Int((try? c.decode(String.self, forKey: .numSamples)) ?? "1") ?? numSamples
        self.maxRecursionDepth = Int((try? c.decode(String.self, forKey: .maxRecursionDepth)) ?? "1") ?? maxRecursionDepth
        self.minRecursionDepth = Int((try? c.decode(String.self, forKey: .minRecursionDepth)) ?? "1") ?? minRecursionDepth
        self.comment = try? c.decode(String.self, forKey: .comment)
        self.rendererParams = try? c.decode(String.self, forKey: .rendererParams)
        self.renderer = RendererType(rawValue: (try? c.decode(String.self, forKey: .renderer)) ?? "RayTracing") ?? .raytracer
        self.nearDistance = Scalar((try? c.decode(String.self, forKey: .nearDistance)) ?? "1") ?? self.nearDistance
        self.splittingFactor = Int((try? c.decode(String.self, forKey: .splittingFactor)) ?? "1") ?? self.splittingFactor
        self.imageName  = (try? c.decode(String.self, forKey: .imageName)) ?? self.imageName

        if let arr = try? c.decode([Tonemap].self, forKey: .tonemap) {
            tonemap += arr
        } else if let one = try? c.decode(Tonemap.self, forKey: .tonemap) {
            tonemap += [one]
        }

        self.pathTracerOptions = parseRendererParams(rendererParams)
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

    func parseRendererParams(_ s: String?) -> PathTracerOptions {
        // Missing/empty => default path tracer (uniform sampling)
        guard let s, !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }

        let tokens = s.split(whereSeparator: { $0 == " " || $0 == "\t" || $0 == "\n" })
                     .map { String($0) }

        var o: PathTracerOptions = []
        for t in tokens {
            switch t {
            case "ImportanceSampling":
                o.insert(.importanceSampling)
            case "NextEventEstimation":
                o.insert(.nextEventEstimation)
            case "MIS_BALANCE":
                o.insert(.misBalance)
            case "MIS_POWER":
                o.insert(.misPower)
            case "MIS_01":
                o.insert(.mis01)
            case "RussianRoulette":
                o.insert(.russianRoulette)
            default:
                // Unknown token: ignore (or log once)
                break
            }
        }
        return o
    }
}

// MARK: - LookAt functions
extension Camera {
    func computeBasis(aspect: Scalar) -> (origin: Vec3, u: Vec3, v: Vec3, w: Vec3, fovYRad: Scalar?) {
        let origin = position
        let forward = simd_normalize(gaze - position)
        let right = simd_normalize(simd_cross(forward, up))
        let trueUp = simd_normalize(simd_cross(right, forward))
        var fovYRad: Scalar? = nil
        if fovy != nil {
            fovYRad = fovy! * .pi / 180.0
        }

        return (origin, right, trueUp, -forward, fovYRad)
    }

    func generateRay(x: Scalar, y: Scalar, width: Int, height: Int) -> Ray {
        let aspect = Scalar(width) / Scalar(height)
        let (origin, u, v, w, fovYRad) = computeBasis(aspect: aspect)
        let tanHalfFovY = fovYRad == nil ? 1.0 : tan(fovYRad! / 2)
        let px = ( (2 * (x + 0.5) / Scalar(width)) - 1 ) * aspect * tanHalfFovY
        let py = (1 - 2 * (y + 0.5) / Scalar(height)) * tanHalfFovY

        let dir = simd_normalize(px * u + py * v + w)
        return Ray(origin: origin, dir: dir)
    }
}

public enum ToneMapOperation: String, Decodable, CaseIterable, Hashable {
    case photographic = "Photographic"
    case filmic = "Filmic"
    case aces = "ACES"
    case none = "None"
}

// MARK: - Tonemap
public struct Tonemap {
    public var operation: ToneMapOperation = .photographic
    public var options: Vec2 = .zero
    public var saturation: Scalar = .zero
    public var gamma: Scalar = .zero
    public var ext: String = ""
}

extension Tonemap {
    enum CodingKeys: String, CodingKey {
        case operation = "TMO"
        case options = "TMOOptions"
        case saturation = "Saturation"
        case gamma = "Gamma"
        case ext = "Extension"
    }
}

extension Tonemap: Identifiable {
    public var title: String {
        operation.rawValue + ext
    }

    public var id: String { title }
}

extension Tonemap: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        operation = (try? c.decode(ToneMapOperation.self, forKey: .operation) ?? .photographic) ?? .photographic
        options = Self.decodeVec2(c, .options) ?? .zero
        saturation = Scalar(try c.decode(String.self, forKey: .saturation) ?? "0") ?? 1
        gamma = Scalar(try c.decode(String.self, forKey: .gamma) ?? "0") ?? 1
        ext = (try? c.decode(String.self, forKey: .ext) ?? "") ?? ""
    }

    static func decodeVec2(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) -> Vec2? {
        if let s = try? c.decode(String.self, forKey: k) {
            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap(Scalar.init)
            if comps.count >= 2 { return Vec2(comps[0], comps[1]) }
        } else if let arr = try? c.decode([Scalar].self, forKey: k), arr.count >= 2 {
            return Vec2(arr[0], arr[1])
        }
        return nil
    }
}
