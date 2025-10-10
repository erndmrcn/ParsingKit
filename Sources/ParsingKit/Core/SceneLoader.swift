//
//  SceneLoader.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.10.2025.
//

import Foundation

public enum SceneSource {
    case data(Data, format: Format)
    case url(URL)
    public enum Format { case json, xml, auto }
}

public enum SceneLoadError: Error {
    case unreadable
    case decodingFailed(Error)
}

enum ScopedReadError: LocalizedError {
    case noSecurityScope, providerFailed(underlying: Error), emptyData
    var errorDescription: String? {
        switch self {
        case .noSecurityScope: return "Could not start security-scoped access."
        case .providerFailed(let e): return "File provider denied read: \(e.localizedDescription)"
        case .emptyData: return "Read returned empty data."
        }
    }
}

@discardableResult
func readSecurityScopedData(from url: URL) throws -> Data {
    let didStart = url.startAccessingSecurityScopedResource()
    guard didStart else { throw ScopedReadError.noSecurityScope }
    defer { url.stopAccessingSecurityScopedResource() }

    let coordinator = NSFileCoordinator(filePresenter: nil)
    var coordError: NSError?
    var payload: Data?

    coordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: &coordError) { readableURL in
        payload = try? Data(contentsOf: readableURL, options: [.mappedIfSafe])
    }

    if let err = coordError { throw ScopedReadError.providerFailed(underlying: err) }
    guard let data = payload, !data.isEmpty else { throw ScopedReadError.emptyData }
    return data
}

public enum SceneLoader {
    /// Load a scene from data/URL. If format is `.auto`, it detects by file extension or leading char.
    public static func load(_ source: SceneSource, rootKey: String = "Scene") throws -> Scene {
        let data: Data
        let format: SceneSource.Format

        switch source {
        case .data(let d, let f): data = d; format = f
        case .url(let url):
            do {
                data = try readSecurityScopedData(from: url)
            } catch {
                throw error
            }

            let ext = url.pathExtension.lowercased()
            format = (ext == "json") ? .json : (ext == "xml" ? .xml : .auto)
        }

        let jsonData: Data
        switch format {
        case .json:
            jsonData = data
        case .xml:
            jsonData = XML2JSON.convert(data)
        case .auto:
            if data.firstNonWhitespace() == UInt8(ascii: "{") {
                jsonData = data
            } else {
                jsonData = XML2JSON.convert(data)
            }
        }

        // Decode with same model from a synthetic JSON { "Scene": ... } OR direct root
        // Try { "Scene": ... } first:
        let decoder = JSONDecoder()
        decoder.userInfo[.init(rawValue: "rootKey")!] = rootKey

        // First attempt: { "Scene": ... }
        if let top = try? decoder.decode([String: Scene].self, from: jsonData), let sc = top[rootKey] {
            return sc
        }

        // Second attempt: direct scene body
        do {
            return try decoder.decode(Scene.self, from: jsonData)
        } catch {
            throw SceneLoadError.decodingFailed(error)
        }
    }
}

private extension Data {
    func firstNonWhitespace() -> UInt8? {
        for b in self {
            if !Character(UnicodeScalar(b)).isWhitespace { return b }
        }
        return nil
    }
}
