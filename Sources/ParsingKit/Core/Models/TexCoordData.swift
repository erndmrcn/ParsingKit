//
//  TexCoordData.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.12.2025.
//

public struct TexCoordData {
    public var data: [Vec2] = []
    public var type: String = ""
    public var vertexOffset: Int = 0
    public var textureOffset: Int = 0
    public var binaryFile: String?
}

// MARK: - Coding Keys
extension TexCoordData {
    enum CodingKeys: String, CodingKey {
        case data = "_data"
        case type = "_type"
        case textureOffset = "_textureOffset"
        case vertexOffset = "_vertexOffset"
        case binaryFile = "_binaryFile"
    }
}

// MARK: - Decodable
extension TexCoordData: Decodable {
    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        type = try root.decode(String.self, forKey: .type) ?? type

        if let vStr = try? root.decode(String.self, forKey: .data) {
            let lines = vStr.split(whereSeparator: \.isWhitespace).compactMap(Scalar.init).chunked(into: 2)
            data = lines.compactMap { line in
                if line.count < 2 { return nil }
                return Vec2(line[0], line[1])
            }
        } else if let arr = try? root.decode([[Scalar]].self, forKey: .data) {
            data = arr.compactMap { $0.count >= 2 ? Vec2($0[0], $0[1]) : nil }
        }

        textureOffset = Int((try? root.decode(String.self, forKey: .textureOffset)) ?? "0") ?? textureOffset
        vertexOffset = Int((try? root.decode(String.self, forKey: .vertexOffset)) ?? "0") ?? vertexOffset
        binaryFile = (try? root.decode(String.self, forKey: .binaryFile) ?? "") ?? ""
    }
}
