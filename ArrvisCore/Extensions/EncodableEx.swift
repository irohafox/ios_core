//
//  EncodableEx.swift
//  ArrvisCore
//
//  Created by Yutaka Izumaru on 2018/02/16.
//  Copyright © 2018年 Arrvis Co., Ltd. All rights reserved.
//

import Foundation

extension Encodable {

    /// dictionary
    public var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
            .flatMap { $0 as? [String: Any] }
    }

    /// JSON文字列
    public var jsonString: String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(bytes: data, encoding: .utf8)
    }

    /// CSV用
    public var toCSVJsonString: String? {
        return "\"\(jsonString?.replacingOccurrences(of: "\"", with: "\"\"") ?? "")\""
    }
}
