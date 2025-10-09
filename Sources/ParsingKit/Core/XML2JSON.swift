//
//  XML2JSON.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.10.2025.
//

import Foundation

/// A tiny XML -> JSON-ish transformer tailored for the scene schema.
/// It converts elements into dictionaries/arrays that `JSONDecoder` can consume using the same models.
enum XML2JSON {
    static func convert(_ data: Data) -> Data {
        let parser = XMLDictParser()
        let dict = parser.parse(data: data) ?? [:]
        // If the root is <Scene>...</Scene>, wrap to { "Scene": ... } to match JSON samples.
        let jsonRoot: [String: Any]
        if let scene = dict["Scene"] {
            jsonRoot = ["Scene": scene]
        } else {
            jsonRoot = ["Scene": dict]
        }
        return (try? JSONSerialization.data(withJSONObject: jsonRoot, options: [])) ?? Data("{}".utf8)
    }
}

// Very small XML-to-dict parser (attributes "id" -> "_id", "type" -> "_type")
final class XMLDictParser: NSObject, XMLParserDelegate {
    private var stack: [[String: Any]] = []
    private var elementStack: [String] = []
    private var text: String = ""

    func parse(data: Data) -> [String: Any]? {
        let p = XMLParser(data: data)
        p.delegate = self
        p.shouldResolveExternalEntities = false
        guard p.parse() else { return nil }
        // After parsing, the stack should contain exactly one root dictionary.
        return stack.last
    }

    func parserDidStartDocument(_ parser: XMLParser) {
        stack = [[:]]
        elementStack = []
        text = ""
    }

    func parser(_ parser: XMLParser,
                didStartElement name: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attr: [String : String] = [:]) {
        elementStack.append(name)
        text = ""

        var node: [String: Any] = [:]
        // Promote common attributes to JSON-like keys
        if let id = attr["id"] { node["_id"] = id }
        if let type = attr["type"] { node["_type"] = type }

        stack.append(node)
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        text += string
    }

    func parser(_ parser: XMLParser,
                didEndElement name: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        // Child node we just finished
        let node = stack.removeLast()
        _ = elementStack.popLast()

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var out = node

        if !trimmed.isEmpty {
            // If element has only text, keep as string in a temp slot
            let existing = (out["__text"] as? String) ?? ""
            out["__text"] = existing.isEmpty ? trimmed : (existing + " " + trimmed)
        }

        // Attach to parent
        guard var parent = stack.popLast() else {
            // Should not happen, but keep a sane fallback
            stack.append(out)
            return
        }

        // Decide final representation of `out`
        let outKeys = Set(out.keys)
        let attributeKeys = Set(out.keys.filter { $0.hasPrefix("_") })

        // If node only has text and/or only attributes + text -> collapse to the text value
        let isOnlyText = outKeys == Set(["__text"])
        let isOnlyAttributesAndText = outKeys.subtracting(attributeKeys).isSubset(of: ["__text"]) && !outKeys.isEmpty

        let finalValue: Any
        if isOnlyText || isOnlyAttributesAndText, let textVal = out["__text"] as? String {
            finalValue = textVal
        } else if let textVal = out["__text"] as? String, !textVal.isEmpty, outKeys.count == attributeKeys.count + 1 {
            // Attributes + text but no other child elements -> still collapse to text
            finalValue = textVal
        } else {
            // Keep dictionary form (remove the helper key if it exists but not needed)
            var normalized = out
            if normalized.keys.contains("__text") && (normalized.keys.count > 1) {
                normalized.removeValue(forKey: "__text")
            }
            finalValue = normalized
        }

        // Insert into parent, supporting repeated elements as arrays
        if var existingArray = parent[name] as? [Any] {
            existingArray.append(finalValue)
            parent[name] = existingArray
        } else if let existingSingle = parent[name] {
            parent[name] = [existingSingle, finalValue]
        } else {
            parent[name] = finalValue
        }

        // Push updated parent back
        stack.append(parent)

        // Reset text buffer for the next sibling
        text = ""
    }
}
