import Foundation
import CryptoKit

actor EncryptionService {
    private let symmetricKey: SymmetricKey
    
    init(keyData: Data? = nil) {
        if let keyData = keyData {
            self.symmetricKey = SymmetricKey(data: keyData)
        } else {
            self.symmetricKey = SymmetricKey(size: .bits256)
        }
    }
    
    func encrypt(_ string: String) throws -> Data {
        guard let data = string.data(using: .utf8) else {
            throw EncryptionError.encodingFailed
        }
        return try encrypt(data)
    }
    
    func encrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: symmetricKey)
        guard let combined = sealedBox.combined else {
            throw EncryptionError.encryptionFailed
        }
        return combined
    }
    
    func decrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: symmetricKey)
    }
    
    func decryptToString(_ data: Data) throws -> String {
        let decryptedData = try decrypt(data)
        guard let string = String(data: decryptedData, encoding: .utf8) else {
            throw EncryptionError.decodingFailed
        }
        return string
    }
    
    func generateKeyData() -> Data {
        let key = SymmetricKey(size: .bits256)
        return key.withUnsafeBytes { Data(/bin/sh) }
    }
}

enum EncryptionError: Error, LocalizedError {
    case encodingFailed
    case encryptionFailed
    case decryptionFailed
    case decodingFailed
    case keyNotFound
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed: return "Failed to encode data"
        case .encryptionFailed: return "Encryption operation failed"
        case .decryptionFailed: return "Decryption operation failed"
        case .decodingFailed: return "Failed to decode decrypted data"
        case .keyNotFound: return "Encryption key not found"
        }
    }
}
