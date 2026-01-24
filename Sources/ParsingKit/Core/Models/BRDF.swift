//
//  BRDF.swift
//  ParsingKit
//
//  Created by Eren Demircan on 13.01.2026.
//

public protocol BRDFTypes {
    var id: String? { get set }
}

public struct BRDF: @unchecked Sendable {
    public var brdfs: [BRDFTypes] = []
}

// MARK: - Coding Keys
extension BRDF {
    enum CodingKeys: String, CodingKey {
        case originalBlinnPhong = "OriginalBlinnPhong"
        case modifiedPhong = "ModifiedPhong"
        case torrenceSparrow = "TorranceSparrow"
    }
}

// MARK: - Decodable
extension BRDF: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let arr = try? c.decode([OriginalBlinnPhong].self, forKey: .originalBlinnPhong) {
            brdfs += arr
        } else if let one = try? c.decode(OriginalBlinnPhong.self, forKey: .originalBlinnPhong) {
            brdfs += [one]
        }

        if let arr = try? c.decode([ModifiedPhong].self, forKey: .modifiedPhong) {
            brdfs += arr
        } else if let one = try? c.decode(ModifiedPhong.self, forKey: .modifiedPhong) {
            brdfs += [one]
        }

        if let arr = try? c.decode([TorrenceSparrow].self, forKey: .torrenceSparrow) {
            brdfs += arr
        } else if let one = try? c.decode(TorrenceSparrow.self, forKey: .torrenceSparrow) {
            brdfs += [one]
        }
    }
}

public struct OriginalBlinnPhong: @unchecked Sendable, BRDFTypes {
    public var id: String?
    public var exponent: Scalar = .zero
}

// MARK: - Coding Keys
extension OriginalBlinnPhong {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case exponent = "Exponent"
    }
}

// MARK: - Decodable
extension OriginalBlinnPhong: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id     = try? c.decode(String.self, forKey: .id)
        exponent     = Scalar((try? c.decode(String.self, forKey: .exponent)) ?? "0.0") ?? self.exponent
    }

//    static func decodeVec3(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) -> Vec3? {
//        if let s = try? c.decode(String.self, forKey: k) {
//            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap(Scalar.init)
//            if comps.count >= 3 { return Vec3(comps[0], comps[1], comps[2]) }
//        } else if let arr = try? c.decode([Scalar].self, forKey: k), arr.count >= 3 {
//            return Vec3(arr[0], arr[1], arr[2])
//        }
//        return nil
//    }
}

public struct TorrenceSparrow: @unchecked Sendable, BRDFTypes {
    public var id: String?
    public var kdFresnel: Bool = false
    public var exponent: Scalar = .zero
}

// MARK: - Coding Keys
extension TorrenceSparrow {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case kdFresnel = "_kdfresnel"
        case exponent = "Exponent"
    }
}

// MARK: - Decodable
extension TorrenceSparrow: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id     = try? c.decode(String.self, forKey: .id)
        exponent     = Scalar((try? c.decode(String.self, forKey: .exponent)) ?? "0.0") ?? self.exponent
        kdFresnel     = Bool((try? c.decode(String.self, forKey: .kdFresnel)) ?? "false") ?? self.kdFresnel
    }

//    static func decodeVec3(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) -> Vec3? {
//        if let s = try? c.decode(String.self, forKey: k) {
//            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap(Scalar.init)
//            if comps.count >= 3 { return Vec3(comps[0], comps[1], comps[2]) }
//        } else if let arr = try? c.decode([Scalar].self, forKey: k), arr.count >= 3 {
//            return Vec3(arr[0], arr[1], arr[2])
//        }
//        return nil
//    }
}

public struct ModifiedPhong: BRDFTypes {
    public var id: String?
    public var normalized: Bool = false
    public var exponent: Scalar = .zero
}

extension ModifiedPhong {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case normalized = "_normalized"
        case exponent = "Exponent"
    }
}

// MARK: - Decodable
extension ModifiedPhong: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id     = try? c.decode(String.self, forKey: .id)
        exponent     = Scalar((try? c.decode(String.self, forKey: .exponent)) ?? "0.0") ?? self.exponent
        normalized     = Bool((try? c.decode(String.self, forKey: .normalized)) ?? "false") ?? self.normalized
    }

//    static func decodeVec3(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) -> Vec3? {
//        if let s = try? c.decode(String.self, forKey: k) {
//            let comps = s.split{ $0 == " " || $0 == "\t" }.compactMap(Scalar.init)
//            if comps.count >= 3 { return Vec3(comps[0], comps[1], comps[2]) }
//        } else if let arr = try? c.decode([Scalar].self, forKey: k), arr.count >= 3 {
//            return Vec3(arr[0], arr[1], arr[2])
//        }
//        return nil
//    }
}
