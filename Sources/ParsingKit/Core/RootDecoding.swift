//
//  RootDecoding.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.10.2025.
//

import Foundation

/// Decode any `Decodable` model `T` from raw JSON `Data`.
/// If `rootKey` is provided, extracts that subobject first (e.g. "Scene").
public enum ParsingKit {
    public static func decode<T: Decodable>(_ type: T.Type, from data: Data, rootKey: String? = nil, using decoder: JSONDecoder = JSONDecoder()) throws -> T {
        guard let rootKey else {
            return try decoder.decode(T.self, from: data)
        }
        // Extract object at rootKey generically via JSONSerialization to keep this target model-agnostic.
        let obj = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = obj as? [String: Any], let sub = dict[rootKey] else {
            throw PKDecodingError.expectedValue("Root key not found: \(rootKey)")
        }
        let subData = try JSONSerialization.data(withJSONObject: sub, options: [])
        return try decoder.decode(T.self, from: subData)
    }
}
