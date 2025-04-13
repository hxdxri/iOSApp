import SwiftUI

struct InboxView: View {
    @EnvironmentObject var dataStore: MockDataStore
    
    var body: some View {
        NavigationStack {
            VStack {
                if let user = dataStore.currentUser {
                    let conversations = dataStore.getConversationsForCurrentUser()
                    
                    if conversations.isEmpty {
                        emptyInboxView
                    } else {
                        List {
                            ForEach(conversations) { conversation in
                                NavigationLink(destination: ConversationView(conversation: conversation)) {
                                    ConversationRow(conversation: conversation)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                } else {
                    Text("Please log in")
                }
            }
            .navigationTitle("Inbox")
        }
    }
    
    private var emptyInboxView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "message")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
            
            Text("No Messages Yet")
                .font(.headline)
            
            Text("When you connect with farmers or consumers, your conversations will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    @EnvironmentObject var dataStore: MockDataStore
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(otherUserName)
                    .font(.headline)
                
                if let lastMsg = conversation.lastMessage {
                    Text(lastMsg)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var otherUserName: String {
        guard let currentUserId = dataStore.currentUser?.id else { return "Unknown" }
        
        let otherUserId = conversation.participants.first { $0 != currentUserId } ?? UUID()
        let otherUser = dataStore.users.first { $0.id == otherUserId }
        
        return otherUser?.name ?? "Unknown"
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: conversation.lastMessageTimestamp)
    }
}

struct ConversationView: View {
    let conversation: Conversation
    @EnvironmentObject var dataStore: MockDataStore
    @State private var messageText = ""
    @State private var scrollToBottom = false
    
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(spacing: 12) {
                        ForEach(conversation.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .onChange(of: conversation.messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo("bottom")
                        }
                    }
                    .onAppear {
                        proxy.scrollTo("bottom")
                    }
                }
            }
            
            HStack {
                TextField("Type a message...", text: $messageText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(messageText.isEmpty ? .gray : .green)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .navigationTitle(otherUserName)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var otherUserName: String {
        guard let currentUserId = dataStore.currentUser?.id else { return "Conversation" }
        
        let otherUserId = conversation.participants.first { $0 != currentUserId } ?? UUID()
        let otherUser = dataStore.users.first { $0.id == otherUserId }
        
        return otherUser?.name ?? "Unknown"
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty, let currentUserId = dataStore.currentUser?.id else { return }
        
        let otherUserId = conversation.participants.first { $0 != currentUserId } ?? UUID()
        dataStore.sendMessage(to: otherUserId, content: messageText)
        messageText = ""
    }
}

struct MessageBubble: View {
    let message: Message
    @EnvironmentObject var dataStore: MockDataStore
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
                
                Text(message.content)
                    .padding(12)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                Text(message.content)
                    .padding(12)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Spacer()
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var isFromCurrentUser: Bool {
        message.senderId == dataStore.currentUser?.id
    }
}

#Preview {
    InboxView()
        .environmentObject(MockDataStore())
} 