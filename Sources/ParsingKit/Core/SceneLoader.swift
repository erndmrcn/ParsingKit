//
//  SceneLoader.swift
//  ParsingKit
//
//  Created by Eren Demircan on 6.10.2025.
//

import Foundation
import XMLCoder

public enum SceneFormat: String { case json, xml }

public struct SceneLoader {
    public struct Options: Sendable {
        public var maxBytes: Int = 10 * 1024 * 1024           // 10 MB cap
        public var allowNaN: Bool = false                     // reject NaN/Inf by default
        public var collectIssues: IssueCollector? = nil
        public init() {}
    }

    public static func load<T: Decodable>(
        _ type: T.Type,
        from url: URL,
        options: Options = .init()
    ) throws -> T {
        let data = try readSafely(url: url, maxBytes: options.maxBytes)
        let fmt = detectFormat(data)
        switch fmt {
        case .json: return try decodeJSON(T.self, data: data, options: options)
        case .xml:  return try decodeXML(T.self, data: data, options: options)
        }
    }

    public static func load<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        options: Options = .init()
    ) throws -> T {
        switch detectFormat(data) {
        case .json: return try decodeJSON(T.self, data: data, options: options)
        case .xml:  return try decodeXML(T.self, data: data, options: options)
        }
    }

    // MARK: detection & decoders

    private static func detectFormat(_ data: Data) -> SceneFormat {
        // Skip BOM/whitespace and peek first non-space char
        let prefix = String(decoding: data.prefix(64), as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return prefix.first == "<" ? .xml : .json
    }

    private static func decodeJSON<T: Decodable>(_ type: T.Type, data: Data, options: Options) throws -> T {
        let dec = JSONDecoder()
        // stricter by default
        if !options.allowNaN {
            dec.nonConformingFloatDecodingStrategy = .throw
        }
        // helpful: preserve key order if you ever re-encode for debugging
        #if !os(Linux)
        if #available(iOS 15, macOS 12, *) { dec.allowsJSON5 = true } // tolerate comments/trailing commas in authoring
        #endif
        return try dec.decode(T.self, from: data)
    }

    private static func decodeXML<T: Decodable>(_ type: T.Type, data: Data, options: Options) throws -> T {
        let dec = XMLDecoder()
        // most XML scene files use element names in PascalCase or camelCase — tweak as needed
        dec.keyDecodingStrategy = .useDefaultKeys
        dec.trimValueWhitespaces = true
        dec.shouldProcessNamespaces = false   // security: ignore external namespaces
        return try dec.decode(T.self, from: data)
    }

    private static func readSafely(url: URL, maxBytes: Int) throws -> Data {
        // Restrict to file URLs and prevent directory traversal if you later pass user paths.
        guard url.isFileURL else { throw NSError(domain: "ParsingKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Only local files are allowed"]) }
        let r = try url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
        guard r.isRegularFile == true else { throw NSError(domain: "ParsingKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Not a regular file"]) }
        let size = r.fileSize ?? 0
        guard size <= maxBytes else { throw NSError(domain: "ParsingKit", code: 3, userInfo: [NSLocalizedDescriptionKey: "File too large (\(size) bytes)"]) }
        return try Data(contentsOf: url, options: .mappedIfSafe)
    }
}
