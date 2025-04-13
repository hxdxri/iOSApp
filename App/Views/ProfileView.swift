import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var dataStore: MockDataStore
    @State private var showingLogoutAlert = false
    @State private var isEditProfilePresented = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let user = dataStore.currentUser {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Profile header
                            VStack(spacing: 16) {
                                Image(systemName: user.profileImageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.green)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                                
                                VStack(spacing: 4) {
                                    Text(user.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text(user.userType.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(6)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                                
                                Button {
                                    isEditProfilePresented = true
                                } label: {
                                    Text("Edit Profile")
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(16)
                                }
                            }
                            .padding()
                            
                            // Profile info
                            VStack(alignment: .leading, spacing: 16) {
                                infoSection(title: "Contact Info", items: [
                                    ("Email", user.email),
                                    ("Phone", user.phone.isEmpty ? "Not provided" : user.phone),
                                    ("Location", user.location)
                                ])
                                
                                if !user.bio.isEmpty {
                                    infoSection(title: "About", items: [("Bio", user.bio)])
                                }
                                
                                // For demonstration - would show past orders/saved farms/etc.
                                if user.userType == .consumer {
                                    placeholderSection(title: "Past Orders", systemImage: "cart", message: "Your order history will appear here")
                                    
                                    placeholderSection(title: "Saved Farms", systemImage: "heart", message: "Farms you save will appear here")
                                } else {
                                    placeholderSection(title: "Your Farm", systemImage: "house", message: "Your farm information will appear here")
                                    
                                    placeholderSection(title: "Orders to Fulfill", systemImage: "shippingbox", message: "Orders to fulfill will appear here")
                                }
                            }
                            .padding(.horizontal)
                            
                            Button {
                                showingLogoutAlert = true
                            } label: {
                                Text("Log Out")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 16)
                            .alert("Log Out", isPresented: $showingLogoutAlert) {
                                Button("Cancel", role: .cancel) { }
                                Button("Log Out", role: .destructive) {
                                    dataStore.logout()
                                }
                            } message: {
                                Text("Are you sure you want to log out?")
                            }
                        }
                        .padding(.bottom)
                    }
                } else {
                    Text("Please log in")
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $isEditProfilePresented) {
                if let user = dataStore.currentUser {
                    EditProfileView(user: user)
                        .environmentObject(dataStore)
                }
            }
        }
    }
    
    private func infoSection(title: String, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(items, id: \.0) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.0)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(item.1)
                            .font(.body)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func placeholderSection(title: String, systemImage: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.secondary)
                    .padding(.top, 12)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct EditProfileView: View {
    let user: User
    @EnvironmentObject var dataStore: MockDataStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var phone: String
    @State private var location: String
    @State private var bio: String
    
    init(user: User) {
        self.user = user
        _name = State(initialValue: user.name)
        _phone = State(initialValue: user.phone)
        _location = State(initialValue: user.location)
        _bio = State(initialValue: user.bio)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Location", text: $location)
                }
                
                Section(header: Text("About")) {
                    TextEditor(text: $bio)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        // In a real app, this would update the user in the database
        // For this prototype, we just update the mock data
        if let index = dataStore.users.firstIndex(where: { $0.id == user.id }) {
            dataStore.users[index].name = name
            dataStore.users[index].phone = phone
            dataStore.users[index].location = location
            dataStore.users[index].bio = bio
            
            // Update current user if this is the current user
            if dataStore.currentUser?.id == user.id {
                dataStore.currentUser = dataStore.users[index]
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(MockDataStore())
} 