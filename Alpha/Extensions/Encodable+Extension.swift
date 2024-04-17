//
//  Encodable+Extension.swift
//  ChildQuestionApp
//
//  Created by alex on 08.02.2023.
//

import Foundation

extension Encodable {
    var dict : [String: Any]? {
        guard let data = try? JSONEncoder().encode(self), let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return nil }
        return json
    }
}
