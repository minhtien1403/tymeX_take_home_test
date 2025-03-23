//
//  String+Encrypt.swift
//  TymeX
//
//  Created by Trần Tiến on 20/3/25.
//

import Foundation
import CommonCrypto

extension String {
    
    func sha256() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
