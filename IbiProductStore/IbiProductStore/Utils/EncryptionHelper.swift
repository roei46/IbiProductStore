//
//  EncryptionHelper.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import CryptoKit
import Foundation

struct EncryptionHelper {
    
    // MARK: - Encryption
    static func encrypt(_ string: String, using key: SymmetricKey) throws -> (cipher: Data, nonce: Data) {
        let nonce = AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(Data(string.utf8), using: key, nonce: nonce)
        return (sealedBox.ciphertext + sealedBox.tag, nonce.data)
    }
    
    // MARK: - Decryption
    static func decrypt(cipher: Data, nonceData: Data, using key: SymmetricKey) throws -> String {
        let nonce = try AES.GCM.Nonce(data: nonceData)
        let tagStartIndex = cipher.count - 16
        let ciphertext = cipher.prefix(tagStartIndex)
        let tag = cipher.suffix(16)
        
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        return String(decoding: decryptedData, as: UTF8.self)
    }
}

// MARK: - Nonce Extension
extension AES.GCM.Nonce {
    var data: Data {
        return withUnsafeBytes { Data($0) }
    }
}