//
//  Scaling.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.11.2025.
//

public struct Scale {
    public var id: String = ""
    public var data: String = ""

}

// MARK: - Coding Keys
extension Scale {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case data = "_data"
    }
}

// MARK: - Decodable
extension Scale: Decodable {
    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(String.self, forKey: .id)) ?? ""
        data = (try? c.decode(String.self, forKey: .data)) ?? ""
    }
}
