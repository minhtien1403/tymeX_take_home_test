//
//  Encodable.swift
//  TymeX
//
//  Created by Trần Tiến on 19/3/25.
//

import Foundation

extension Encodable {
    
    var asDictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
}
