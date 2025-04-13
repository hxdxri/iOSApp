import Foundation

enum DeliveryOption: String, Codable, CaseIterable {
    case pickup = "Pickup"
    case delivery = "Delivery"
    case either = "Either"
}

struct RequestResponse: Identifiable, Codable {
    var id: UUID = UUID()
    var farmerId: UUID
    var farmerName: String
    var offerAmount: Double
    var message: String
    var timestamp: Date = Date()
}

struct Request: Identifiable, Codable {
    var id: UUID = UUID()
    var consumerId: UUID
    var consumerName: String
    var meatType: String
    var quantity: Double
    var unit: String // e.g., "pounds", "kg"
    var budget: Double
    var deliveryOption: DeliveryOption
    var preferredTime: Date
    var location: String
    var coordinates: Coordinates?
    var additionalInfo: String = ""
    var datePosted: Date = Date()
    var isOpen: Bool = true
    var responses: [RequestResponse] = []
} 