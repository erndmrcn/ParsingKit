//
//  Texture.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.12.2025.
//

import Foundation

public struct Texture: Decodable {
    public var images: [TextureImage] = []
    public let maps: [TextureMap]

    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        if let imageContainer = try? root.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .images) {
            if let imgArray = try? imageContainer.decodeIfPresent([TextureImage].self, forKey: .init("Image")) {
                images = imgArray
            } else if let single = try? imageContainer.decode(TextureImage.self, forKey: .init("Image")) {
                images = [single]
            }
        }

        if let map = try? root.decode(TextureMap.self, forKey: .maps) {
            maps = [map]
        } else {
            maps = (try? root.decode([TextureMap].self, forKey: .maps)) ?? []
        }
    }

    enum CodingKeys: String, CodingKey {
        case images = "Images"
        case maps = "TextureMap"
    }
}

public enum TextureType: String, Decodable, Hashable {
    case image
    case checkerboard
    case perlin
}

public enum DecalMode: String, Decodable, Hashable {
    case replace_kd
    case replace_ks
    case replace_normal
    case replace_all
    case blend_kd
    case bump_normal
    case replace_background
}

public enum Interpolation: String, Decodable, Hashable {
    case bilinear
    case trilinear
    case nearest
}

public enum NoiseConversion: String, Decodable {
    case absVal = "absval"
    case linear
}

public struct TextureMap: Decodable {
    public let id: String
    public let type: TextureType
    public let imageId: String
    public let decalMode: DecalMode
    public let interpolation: Interpolation
    public let noiseConversion: NoiseConversion
    public let noiseScale: Scalar
    public let normalizer: Scalar
    public let bumpFactor: Scalar
    public let blackColor: Vec3
    public let whiteColor: Vec3
    public let scale: Scalar
    public let offset: Scalar
    public let numOctaves: Scalar
    public let degamma: Bool

    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)

        self.id   = (try? root.decode(String.self, forKey: .id)) ?? ""
        self.type = (try? root.decode(TextureType.self, forKey: .type)) ?? .image
        self.imageId = (try? root.decode(String.self, forKey: .imageId)) ?? ""
        self.decalMode = (try? root.decode(DecalMode.self, forKey: .decalMode)) ?? .replace_kd
        self.interpolation = (try? root.decode(Interpolation.self, forKey: .interpolation)) ?? .bilinear
        self.noiseConversion = (try? root.decode(NoiseConversion.self, forKey: .noiseConversion)) ?? .linear
        self.noiseScale = (Scalar((try? root.decode(String.self, forKey: .noiseScale)) ?? "1")) ?? 1.0
        self.normalizer = (Scalar((try? root.decode(String.self, forKey: .normalizer)) ?? "255")) ?? 255
        self.bumpFactor = (Scalar((try? root.decode(String.self, forKey: .bumpFactor)) ?? "1")) ?? 1
        self.scale = (Scalar((try? root.decode(String.self, forKey: .scale)) ?? "1")) ?? 1
        self.offset = (Scalar((try? root.decode(String.self, forKey: .offset)) ?? "0")) ?? 0
        self.numOctaves = (Scalar((try? root.decode(String.self, forKey: .numOctave)) ?? "1")) ?? 1
        self.degamma = (Bool((try? root.decode(String.self, forKey: .degamma)) ?? "false")) ?? false
        self.blackColor = Self.decodeVec3(root, .blackColor) ?? .zero
        self.whiteColor = Self.decodeVec3(root, .whiteColor) ?? .zero
    }
}

// CodingKeys
extension TextureMap {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type = "_type"
        case imageId = "ImageId"
        case decalMode = "DecalMode"
        case interpolation = "Interpolation"
        case noiseConversion = "NoiseConversion"
        case noiseScale = "NoiseScale"
        case normalizer = "Normalizer"
        case bumpFactor = "BumpFactor"
        case blackColor = "BlackColor"
        case whiteColor = "WhiteColor"
        case scale = "Scale"
        case offset = "Offset"
        case numOctave = "NumOctaves"
        case degamma = "_degamma"
    }
}

public struct TextureImage: Decodable {
    public let data: String
    public let id: String

    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        self.data   = (try? root.decode(String.self, forKey: .data)) ?? ""
        self.id = (try? root.decode(String.self, forKey: .id)) ?? ""
    }
}

// CodingKeys
extension TextureImage {
    enum CodingKeys: String, CodingKey {
        case data = "_data"
        case id = "_id"
    }
}

// MARK: - Decodable
extension TextureMap {
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
