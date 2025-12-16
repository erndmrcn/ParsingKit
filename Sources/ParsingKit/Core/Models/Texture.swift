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

public enum DecalMode: String, Decodable {
    case replace_kd
    case replace_ks
    case replace_normal
    case replace_all
    case blend_kd
    case bump_normal
}

public enum Interpolation: String, Decodable {
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
    public let type: String
    public let imageId: String
    public let decalMode: DecalMode
    public let interpolation: Interpolation
    public let noiseConversion: NoiseConversion
    public let noiseScale: Scalar
    public let normalizer: Scalar

    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        self.id   = (try? root.decode(String.self, forKey: .id)) ?? ""
        self.type = (try? root.decode(String.self, forKey: .type)) ?? ""
        self.imageId = (try? root.decode(String.self, forKey: .imageId)) ?? ""
        self.decalMode = (try? root.decode(DecalMode.self, forKey: .decalMode)) ?? .replace_kd
        self.interpolation = (try? root.decode(Interpolation.self, forKey: .interpolation)) ?? .nearest
        self.noiseConversion = (try? root.decode(NoiseConversion.self, forKey: .noiseConversion)) ?? .linear
        self.noiseScale = (try? root.decode(Scalar.self, forKey: .noiseScale)) ?? 1
        self.normalizer = (Scalar((try? root.decode(String.self, forKey: .normalizer)) ?? "255")) ?? 1
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
