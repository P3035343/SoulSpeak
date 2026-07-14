import XCTest
@testable import SoulSpeak

final class EncryptionServiceTests: XCTestCase {
    func testEncryptAndDecrypt() async throws {
        let service = EncryptionService()
        let originalText = "This is a secret journal entry"
        
        let encrypted = try await service.encrypt(originalText)
        XCTAssertNotEqual(encrypted, originalText.data(using: .utf8))
        
        let decrypted = try await service.decryptToString(encrypted)
        XCTAssertEqual(decrypted, originalText)
    }
    
    func testEncryptProducesDifferentOutput() async throws {
        let service = EncryptionService()
        let text = "Same text"
        
        let encrypted1 = try await service.encrypt(text)
        let encrypted2 = try await service.encrypt(text)
        
        // GCM uses random nonces so outputs should differ
        XCTAssertNotEqual(encrypted1, encrypted2)
    }
    
    func testDecryptInvalidDataThrows() async {
        let service = EncryptionService()
        let invalidData = Data([0x00, 0x01, 0x02])
        
        do {
            _ = try await service.decrypt(invalidData)
            XCTFail("Expected decryption to throw")
        } catch {
            // Expected behavior
        }
    }
    
    func testEmptyStringEncryption() async throws {
        let service = EncryptionService()
        let encrypted = try await service.encrypt("")
        let decrypted = try await service.decryptToString(encrypted)
        XCTAssertEqual(decrypted, "")
    }
    
    func testLongTextEncryption() async throws {
        let service = EncryptionService()
        let longText = String(repeating: "This is a long journal entry. ", count: 1000)
        
        let encrypted = try await service.encrypt(longText)
        let decrypted = try await service.decryptToString(encrypted)
        XCTAssertEqual(decrypted, longText)
    }
}
