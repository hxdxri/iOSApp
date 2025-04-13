import Foundation
import SwiftUI
import UserNotifications

class MockDataStore: ObservableObject {
    @Published var currentUser: User?
    @Published var users: [User] = []
    @Published var farms: [Farm] = []
    @Published var requests: [Request] = []
    @Published var conversations: [Conversation] = []
    @Published var searchText: String = ""
    @Published var selectedFarmFilters: Set<String> = []
    
    init() {
        requestNotificationPermission()
        loadData()
    }
    
    func loadData() {
        loadFromJSON()
        
        // If JSON loading failed, use hardcoded mock data
        if users.isEmpty || farms.isEmpty || requests.isEmpty {
            loadMockData()
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func loadFromJSON() {
        // Load Users
        if let usersData = loadJSON(filename: "users") {
            do {
                users = try JSONDecoder().decode([User].self, from: usersData)
                print("Loaded \(users.count) users from JSON")
            } catch {
                print("Error decoding users: \(error)")
            }
        }
        
        // Load Farms
        if let farmsData = loadJSON(filename: "farms") {
            do {
                farms = try JSONDecoder().decode([Farm].self, from: farmsData)
                print("Loaded \(farms.count) farms from JSON")
            } catch {
                print("Error decoding farms: \(error)")
            }
        }
        
        // Load Requests
        if let requestsData = loadJSON(filename: "requests") {
            do {
                requests = try JSONDecoder().decode([Request].self, from: requestsData)
                print("Loaded \(requests.count) requests from JSON")
            } catch {
                print("Error decoding requests: \(error)")
            }
        }
        
        // Set default user for testing
        if let firstConsumer = users.first(where: { $0.userType == .consumer }) {
            currentUser = firstConsumer
        }
    }
    
    func loadJSON(filename: String) -> Data? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "Resources") else {
            print("Could not find \(filename).json in Resources directory")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error loading \(filename).json: \(error)")
            return nil
        }
    }
    
    // Original mock data loading function, kept as a fallback
    func loadMockData() {
        // Mock Users
        let farmer1 = User(
            id: UUID(),
            email: "john@greenpastures.com",
            name: "John Smith",
            userType: .farmer,
            location: "Greenville, CA",
            phone: "555-123-4567",
            bio: "Third-generation family farm raising grass-fed beef and pastured pork since 1952."
        )
        
        let farmer2 = User(
            id: UUID(),
            email: "mary@hillsidefarm.com",
            name: "Mary Johnson",
            userType: .farmer,
            location: "Riverview, CA",
            phone: "555-987-6543",
            bio: "Sustainable farm specializing in heritage breed chickens and turkey."
        )
        
        let consumer1 = User(
            id: UUID(),
            email: "alex@example.com",
            name: "Alex Rodriguez",
            userType: .consumer,
            location: "San Francisco, CA",
            phone: "555-234-5678",
            bio: "Food enthusiast looking for high-quality, locally raised meat."
        )
        
        let consumer2 = User(
            id: UUID(),
            email: "sarah@example.com",
            name: "Sarah Chen",
            userType: .consumer,
            location: "Oakland, CA",
            phone: "555-876-5432",
            bio: "Health-conscious parent looking to buy in bulk for my family."
        )
        
        users = [farmer1, farmer2, consumer1, consumer2]
        
        // Mock Farms
        let farm1 = Farm(
            id: UUID(),
            name: "Green Pastures Farm",
            ownerId: farmer1.id,
            location: "Greenville, CA",
            coordinates: Coordinates(latitude: 37.773972, longitude: -122.431297),
            description: "Family-owned farm focused on sustainable practices. We raise grass-fed beef, pastured pork, and free-range chickens without antibiotics or hormones.",
            meatOfferings: [
                MeatOffering(type: "Beef", price: 8.99, unit: "per pound", description: "Grass-fed and finished beef, dry-aged for 21 days."),
                MeatOffering(type: "Pork", price: 7.50, unit: "per pound", description: "Heritage breed pork raised on pasture and non-GMO feed.")
            ],
            rating: 4.8,
            reviewCount: 24,
            deliveryAvailable: true,
            pickupAvailable: true
        )
        
        let farm2 = Farm(
            id: UUID(),
            name: "Hillside Poultry Farm",
            ownerId: farmer2.id,
            location: "Riverview, CA",
            coordinates: Coordinates(latitude: 37.733972, longitude: -122.391297),
            description: "Specializing in pasture-raised poultry. Our birds are moved to fresh grass daily and have access to natural forage plus organic feed.",
            meatOfferings: [
                MeatOffering(type: "Chicken", price: 6.99, unit: "per pound", description: "Pasture-raised broilers, processed on farm."),
                MeatOffering(type: "Turkey", price: 9.50, unit: "per pound", description: "Heritage breed turkeys, available seasonally.")
            ],
            rating: 4.6,
            reviewCount: 18,
            deliveryAvailable: false,
            pickupAvailable: true
        )
        
        farms = [farm1, farm2]
        
        // Mock Requests
        let request1 = Request(
            id: UUID(),
            consumerId: consumer1.id,
            consumerName: consumer1.name,
            meatType: "Beef",
            quantity: 25,
            unit: "pounds",
            budget: 200,
            deliveryOption: .either,
            preferredTime: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
            location: "San Francisco, CA",
            coordinates: Coordinates(latitude: 37.7749, longitude: -122.4194),
            additionalInfo: "Looking for a mix of steaks, ground beef, and roasts."
        )
        
        let request2 = Request(
            id: UUID(),
            consumerId: consumer2.id,
            consumerName: consumer2.name,
            meatType: "Chicken",
            quantity: 15,
            unit: "pounds",
            budget: 100,
            deliveryOption: .pickup,
            preferredTime: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
            location: "Oakland, CA",
            coordinates: Coordinates(latitude: 37.8044, longitude: -122.2711),
            additionalInfo: "Prefer whole chickens if possible."
        )
        
        requests = [request1, request2]
        
        // Mock Conversations
        let conversation1 = Conversation(
            id: UUID(),
            participants: [farmer1.id, consumer1.id],
            messages: [
                Message(senderId: consumer1.id, receiverId: farmer1.id, content: "Hi, I'm interested in your beef. Do you have any quarter cow packages available?", timestamp: Date().addingTimeInterval(-86400)),
                Message(senderId: farmer1.id, receiverId: consumer1.id, content: "Yes, we have quarter cow packages available. They're about 110-125 pounds of meat for $850.", timestamp: Date().addingTimeInterval(-82800))
            ]
        )
        
        conversations = [conversation1]
        
        // Set default user for testing
        currentUser = consumer1
    }
    
    func login(email: String, userType: UserType) -> Bool {
        if let user = users.first(where: { $0.email.lowercased() == email.lowercased() && $0.userType == userType }) {
            currentUser = user
            
            // Send welcome back notification
            sendNotification(title: "Welcome Back!", body: "Hello \(user.name), welcome back to LocalMeat!")
            return true
        }
        
        // For prototype: create a new user if email doesn't exist
        let newUser = User(
            id: UUID(),
            email: email,
            name: email.components(separatedBy: "@").first ?? "User",
            userType: userType,
            location: "California"
        )
        
        users.append(newUser)
        currentUser = newUser
        
        // Send welcome notification
        sendNotification(title: "Welcome to LocalMeat!", body: "Thank you for joining our platform!")
        return true
    }
    
    func logout() {
        currentUser = nil
    }
    
    func addRequest(_ request: Request) {
        var newRequest = request
        if newRequest.id == UUID() {
            newRequest.id = UUID() // Ensure unique ID
        }
        requests.append(newRequest)
        
        // Send notification
        sendNotification(title: "Request Posted", body: "Your request for \(request.meatType) has been posted successfully!")
    }
    
    func respondToRequest(requestId: UUID, farmerId: UUID, farmerName: String, offerAmount: Double, message: String) {
        guard let index = requests.firstIndex(where: { $0.id == requestId }) else { return }
        
        let response = RequestResponse(
            farmerId: farmerId,
            farmerName: farmerName,
            offerAmount: offerAmount,
            message: message
        )
        
        requests[index].responses.append(response)
        
        // Find the consumer to notify
        if let consumer = users.first(where: { $0.id == requests[index].consumerId }) {
            // Send notification to consumer
            sendNotification(
                title: "New Offer on Your Request",
                body: "\(farmerName) has made an offer on your \(requests[index].meatType) request!"
            )
        }
    }
    
    func acceptRequest(requestId: UUID, responseIndex: Int) {
        guard let requestIndex = requests.firstIndex(where: { $0.id == requestId }),
              responseIndex < requests[requestIndex].responses.count else { return }
        
        requests[requestIndex].isOpen = false
        
        let response = requests[requestIndex].responses[responseIndex]
        
        // Find the farmer to notify
        if let farmer = users.first(where: { $0.id == response.farmerId }) {
            // Send notification to farmer
            sendNotification(
                title: "Request Accepted!",
                body: "Your offer on the \(requests[requestIndex].meatType) request has been accepted!"
            )
        }
        
        // Create a conversation if it doesn't exist
        let farmerId = response.farmerId
        let consumerId = requests[requestIndex].consumerId
        
        if !conversationExists(between: farmerId, and: consumerId) {
            let newConversation = Conversation(
                id: UUID(),
                participants: [farmerId, consumerId],
                messages: [
                    Message(
                        senderId: consumerId,
                        receiverId: farmerId,
                        content: "I've accepted your offer on my \(requests[requestIndex].meatType) request. Let's discuss the details.",
                        timestamp: Date()
                    )
                ]
            )
            
            conversations.append(newConversation)
        }
    }
    
    func conversationExists(between user1: UUID, and user2: UUID) -> Bool {
        return conversations.contains { conversation in
            conversation.participants.contains(user1) && conversation.participants.contains(user2)
        }
    }
    
    func getFarmsFiltered(by searchText: String = "", filters: Set<String> = []) -> [Farm] {
        var filteredFarms = farms
        
        // Apply text search if not empty
        if !searchText.isEmpty {
            filteredFarms = filteredFarms.filter { farm in
                farm.name.lowercased().contains(searchText.lowercased()) ||
                farm.location.lowercased().contains(searchText.lowercased()) ||
                farm.meatOfferings.contains(where: { $0.type.lowercased().contains(searchText.lowercased()) })
            }
        }
        
        // Apply meat type filters if any
        if !filters.isEmpty {
            filteredFarms = filteredFarms.filter { farm in
                farm.meatOfferings.contains { offering in
                    filters.contains(offering.type)
                }
            }
        }
        
        return filteredFarms
    }
    
    func getAllMeatTypes() -> [String] {
        var meatTypes = Set<String>()
        
        for farm in farms {
            for offering in farm.meatOfferings {
                meatTypes.insert(offering.type)
            }
        }
        
        return Array(meatTypes).sorted()
    }
    
    func getOpenRequests() -> [Request] {
        return requests.filter { $0.isOpen }
    }
    
    func getMyRequests() -> [Request] {
        guard let currentUserId = currentUser?.id else { return [] }
        return requests.filter { $0.consumerId == currentUserId }
    }
    
    func getMyFarm() -> Farm? {
        guard let currentUserId = currentUser?.id else { return nil }
        return farms.first { $0.ownerId == currentUserId }
    }
    
    func getConversationsForCurrentUser() -> [Conversation] {
        guard let currentUserId = currentUser?.id else { return [] }
        return conversations.filter { $0.participants.contains(currentUserId) }
    }
    
    func sendMessage(to receiverId: UUID, content: String) {
        guard let currentUserId = currentUser?.id else { return }
        
        // Find existing conversation or create a new one
        if let conversationIndex = conversations.firstIndex(where: { 
            $0.participants.contains(currentUserId) && $0.participants.contains(receiverId)
        }) {
            let newMessage = Message(senderId: currentUserId, receiverId: receiverId, content: content)
            conversations[conversationIndex].messages.append(newMessage)
            conversations[conversationIndex].lastMessageTimestamp = Date()
            
            // Find receiver to send notification
            if let receiver = users.first(where: { $0.id == receiverId }) {
                sendNotification(
                    title: "New Message",
                    body: "You have a new message from \(currentUser?.name ?? "a user")"
                )
            }
        } else {
            let newConversation = Conversation(
                id: UUID(),
                participants: [currentUserId, receiverId],
                messages: [Message(senderId: currentUserId, receiverId: receiverId, content: content)],
                lastMessageTimestamp: Date()
            )
            conversations.append(newConversation)
            
            // Find receiver to send notification
            if let receiver = users.first(where: { $0.id == receiverId }) {
                sendNotification(
                    title: "New Conversation",
                    body: "\(currentUser?.name ?? "A user") has started a conversation with you"
                )
            }
        }
    }
    
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
} 