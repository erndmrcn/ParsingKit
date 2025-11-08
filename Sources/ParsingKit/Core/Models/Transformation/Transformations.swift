//
//  Transformation.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.11.2025.
//

public struct Transformations {
    var translations: [Translation] = []
    var rotations: [Rotation] = []
    var scalings: [Scale] = []
}

// MARK: Coding Keys
extension Transformations {
    enum CodingKeys: String, CodingKey {
        case translations = "Translation"
        case rotations = "Rotation"
        case scalings = "Scaling"
    }
}

// MARK: - Decodable
extension Transformations: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.translations = (try? container.decode([Translation].self, forKey: .translations)) ?? [(try? container.decode(Translation.self, forKey: .translations)) ?? .init()]
        self.rotations = (try? container.decode([Rotation].self, forKey: .rotations)) ?? [(try? container.decode(Rotation.self, forKey: .rotations)) ?? .init()]
        self.scalings = (try? container.decode([Scale].self, forKey: .scalings)) ?? [(try? container.decode(Scale.self, forKey: .scalings)) ?? .init()]
    }
}

