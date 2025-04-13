import Foundation
import CoreLocation

struct MeatOffering: Identifiable, Codable {
    var id: UUID = UUID()
    var type: String
    var price: Double
    var unit: String // e.g., "per pound", "per package"
    var description: String
    var available: Bool = true
}

struct Coordinates: Codable {
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct Farm: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var ownerId: UUID
    var location: String
    var coordinates: Coordinates?
    var description: String
    var meatOfferings: [MeatOffering]
    var rating: Double = 0.0
    var reviewCount: Int = 0
    var deliveryAvailable: Bool = false
    var pickupAvailable: Bool = true
    var imageName: String = "farm"
} 