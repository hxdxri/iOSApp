import SwiftUI

struct RequestsView: View {
    @EnvironmentObject var dataStore: MockDataStore
    
    var body: some View {
        NavigationStack {
            VStack {
                if let user = dataStore.currentUser {
                    if user.userType == .consumer {
                        consumerRequestsView
                    } else {
                        farmerRequestBoardView
                    }
                } else {
                    Text("Please log in")
                }
            }
            .navigationTitle("Requests")
        }
    }
    
    private var consumerRequestsView: some View {
        VStack {
            if let currentUser = dataStore.currentUser {
                let userRequests = dataStore.requests.filter { $0.consumerId == currentUser.id }
                
                if userRequests.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "clipboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        
                        Text("No Requests Yet")
                            .font(.headline)
                        
                        Text("Post a request and connect with local farmers")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: PostRequestView()) {
                            Text("Post Your First Request")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .padding(.top, 16)
                        
                        Spacer()
                    }
                } else {
                    VStack {
                        HStack {
                            Text("Your Requests")
                                .font(.headline)
                            
                            Spacer()
                            
                            NavigationLink(destination: PostRequestView()) {
                                Image(systemName: "plus")
                                    .foregroundColor(.green)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.horizontal)
                        
                        List {
                            ForEach(userRequests) { request in
                                RequestListItem(request: request)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
        }
    }
    
    private var farmerRequestBoardView: some View {
        VStack {
            Text("Request Board")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            if dataStore.getOpenRequests().isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "clipboard")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    
                    Text("No Open Requests")
                        .font(.headline)
                    
                    Text("Check back later for new customer requests")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                }
            } else {
                List {
                    ForEach(dataStore.getOpenRequests()) { request in
                        NavigationLink(destination: RequestDetailView(request: request)) {
                            RequestListItem(request: request)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

struct RequestListItem: View {
    let request: Request
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(String(format: "%@ - %.0f %@", request.meatType, request.quantity, request.unit))
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: "$%.0f budget", request.budget))
                    .font(.subheadline)
                    .padding(6)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Text(request.location)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                
                Text("Preferred by: \(formatDate(request.preferredTime))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(request.deliveryOption.rawValue)
                    .font(.caption)
                    .padding(4)
                    .background(Color(.systemGray6))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct RequestDetailView: View {
    let request: Request
    @EnvironmentObject var dataStore: MockDataStore
    @State private var isMessageSheetPresented = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Request Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(request.meatType) Request")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("From \(request.consumerName) in \(request.location)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                }
                .padding(.horizontal)
                
                // Request Details
                VStack(alignment: .leading, spacing: 12) {
                    detailRow(title: "Meat Type", value: request.meatType)
                    detailRow(title: "Quantity", value: String(format: "%.0f %@", request.quantity, request.unit))
                    detailRow(title: "Budget", value: String(format: "$%.0f", request.budget))
                    detailRow(title: "Preferred By", value: formatDate(request.preferredTime))
                    detailRow(title: "Delivery Option", value: request.deliveryOption.rawValue)
                    
                    if !request.additionalInfo.isEmpty {
                        Text("Additional Info")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Text(request.additionalInfo)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // Action buttons
                if let currentUser = dataStore.currentUser, currentUser.userType == .farmer {
                    VStack(spacing: 12) {
                        Button {
                            isMessageSheetPresented = true
                        } label: {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Contact Customer")
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                        }
                        
                        Button {
                            // Handle fulfillment action
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Fulfill Request")
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Request Details")
        .sheet(isPresented: $isMessageSheetPresented) {
            ConsumerMessageSheet(request: request, isPresented: $isMessageSheetPresented)
                .environmentObject(dataStore)
        }
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title + ":")
                .font(.headline)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(.body)
            
            Spacer()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct ConsumerMessageSheet: View {
    let request: Request
    @Binding var isPresented: Bool
    @EnvironmentObject var dataStore: MockDataStore
    @State private var messageText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Send Message to \(request.consumerName)")
                    .font(.headline)
                    .padding()
                
                TextEditor(text: $messageText)
                    .padding(4)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .padding()
                
                Button {
                    if !messageText.isEmpty {
                        dataStore.sendMessage(to: request.consumerId, content: messageText)
                        isPresented = false
                    }
                } label: {
                    Text("Send")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(messageText.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(10)
                }
                .disabled(messageText.isEmpty)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    RequestsView()
        .environmentObject(MockDataStore())
} 