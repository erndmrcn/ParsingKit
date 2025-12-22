//
//  Face.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.11.2025.
//

public struct Face {
    public var plyPath: String?
    public var data: [Int] = []
    public var type: String?
    public var vertexOffset: Int = 0
    public var textureOffset: Int = 0

    public init() {
        plyPath = nil
        data = []
        type = nil
    }
}

// MARK: - Coding Keys
extension Face {
    enum CodingKeys: String, CodingKey {
        case data = "_data"
        case type = "_type"
        case plyPath = "_plyFile"
        case textureOffset = "_textureOffset"
        case vertexOffset = "_vertexOffset"
    }
}

// MARK: - Decodable
extension Face: Decodable {
    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)

        type = try? root.decode(String.self, forKey: .type) ?? type
        plyPath = try? root.decode(String.self, forKey: .plyPath)

        if let arr2D = try? root.decode([Int].self, forKey: .data) {
            data = arr2D
        } else if let s = try? root.decode(String.self, forKey: .data) {
            let lines = s.split(whereSeparator: \.isWhitespace)
            data = lines.compactMap { Int($0) }
        }
        textureOffset = Int((try? root.decode(String.self, forKey: .textureOffset)) ?? "0") ?? textureOffset
        vertexOffset = Int((try? root.decode(String.self, forKey: .vertexOffset)) ?? "0") ?? vertexOffset
    }
}
