//
//  VertexData.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.11.2025.
//

public struct VertexData {
    public var data: [Vec3] = []
    public var type: String = ""
}

// MARK: - Coding Keys
extension VertexData {
    enum CodingKeys: String, CodingKey {
        case data = "_data"
        case type = "_type"
    }
}

// MARK: - Decodable
extension VertexData: Decodable {
    public init(from decoder: any Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        type = try root.decode(String.self, forKey: .type) ?? type

        if let vStr = try? root.decode(String.self, forKey: .data) {
            let lines = vStr.split(whereSeparator: \.isWhitespace).compactMap(Scalar.init).chunked(into: 3)
            data = lines.compactMap { line in
                if line.count < 3 { return nil }
                return Vec3(line[0], line[1], line[2])
            }
        } else if let arr = try? root.decode([[Scalar]].self, forKey: .data) {
            data = arr.compactMap { $0.count >= 3 ? Vec3($0[0], $0[1], $0[2]) : nil }
        }
    }
}
