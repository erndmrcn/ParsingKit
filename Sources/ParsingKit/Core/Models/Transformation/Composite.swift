//
//  Composite.swift
//  ParsingKit
//
//  Created by Eren Demircan on 17.12.2025.
//

public struct CompositeTransform: Decodable {
    public var id: String = ""
    public var matrix: Mat4 = .identity

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case data = "_data"
    }

    public init() {

    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        let dataString = try container.decode(String.self, forKey: .data)
        matrix = try Mat4(fromString: dataString)
    }
}
