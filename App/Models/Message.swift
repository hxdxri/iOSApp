import Foundation

struct Message: Identifiable, Codable {
    var id: UUID = UUID()
    var senderId: UUID
    var receiverId: UUID
    var content: String
    var timestamp: Date = Date()
    var isRead: Bool = false
}

struct Conversation: Identifiable, Codable {
    var id: UUID = UUID()
    var participants: [UUID]
    var messages: [Message] = []
    var lastMessageTimestamp: Date = Date()
    
    var lastMessage: String? {
        messages.last?.content
    }
} 