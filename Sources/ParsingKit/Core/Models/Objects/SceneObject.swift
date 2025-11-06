//
//  SceneObject.swift
//  ParsingKit
//
//  Created by Eren Demircan on 7.10.2025.
//

import Foundation
import simd

open class SceneObject: @unchecked Sendable, Decodable {
    public var id: String? = nil
    public var material: String?

    public required init() {}
}
