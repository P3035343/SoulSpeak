import Foundation
import SwiftData

@Model
final class CrisisContact {
    @Attribute(.unique) var id: UUID
    var name: String
    var phoneNumber: String
    var relationship: String
    var isPrimary: Bool
    var isHotline: Bool
    var organizationName: String?
    var availableHours: String?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        phoneNumber: String,
        relationship: String = "personal",
        isPrimary: Bool = false,
        isHotline: Bool = false,
        organizationName: String? = nil,
        availableHours: String? = nil
    ) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.isPrimary = isPrimary
        self.isHotline = isHotline
        self.organizationName = organizationName
        self.availableHours = availableHours
        self.createdAt = Date()
    }
}
