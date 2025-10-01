//
//  VertexHelper.swift
//  ParsingKit
//
//  Created by Eren Demircan on 1.10.2025.
//

import Foundation

/// Split a multi-line string where each line is "x y z" into `[[Double]]`.
public func pkParseVertexLines(_ text: String) -> [[Double]] {
    text.split(whereSeparator: \.isNewline).map { line in
        line.split { $0.isWhitespace }.compactMap { Double($0) }
    }
}

private extension StringProtocol {
    var _isNewline: Bool {
        contains("") || contains("")
    }
}

