import Foundation

enum UserType: String, Codable, CaseIterable {
    case farmer = "Farmer"
    case consumer = "Consumer"
}

struct User: Identifiable, Codable {
    var id: UUID = UUID()
    var email: String
    var name: String
    var userType: UserType
    var location: String
    var phone: String = ""
    var bio: String = ""
    var profileImageName: String = "person.circle"
} 