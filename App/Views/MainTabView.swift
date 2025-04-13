import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataStore: MockDataStore
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(0)
            
            if let currentUser = dataStore.currentUser {
                // Common view for all users
                FarmListingView()
                    .tabItem {
                        Label("Farms", systemImage: "house.fill")
                    }
                    .tag(1)
                
                // Dynamic tabs based on user type
                if currentUser.userType == .consumer {
                    PostRequestView()
                        .tabItem {
                            Label("New Request", systemImage: "plus.circle.fill")
                        }
                        .tag(2)
                    
                    RequestsView()
                        .tabItem {
                            Label("My Requests", systemImage: "list.bullet.clipboard")
                        }
                        .tag(3)
                } else {
                    RequestsView()
                        .tabItem {
                            Label("Requests", systemImage: "list.bullet.clipboard")
                        }
                        .tag(2)
                    
                    FarmDashboardView()
                        .tabItem {
                            Label("My Farm", systemImage: "building.2.fill")
                        }
                        .tag(3)
                }
                
                // Another common tab
                InboxView()
                    .tabItem {
                        Label("Inbox", systemImage: "message.fill")
                    }
                    .tag(4)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(5)
            }
        }
        .tint(.green)
        .navigationBarBackButtonHidden(true)
    }
}

// Placeholder view for farmer dashboard
struct FarmDashboardView: View {
    @EnvironmentObject var dataStore: MockDataStore
    
    var body: some View {
        NavigationStack {
            VStack {
                if let farm = dataStore.getMyFarm() {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Farm Statistics")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            HStack(spacing: 20) {
                                StatCard(title: "Rating", value: String(format: "%.1f", farm.rating), icon: "star.fill", color: .yellow)
                                StatCard(title: "Reviews", value: "\(farm.reviewCount)", icon: "text.bubble.fill", color: .blue)
                            }
                            .padding(.horizontal)
                            
                            Text("Active Listings")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            ForEach(farm.meatOfferings) { offering in
                                MeatOfferingCard(offering: offering)
                                    .padding(.horizontal)
                            }
                            
                            Button(action: {
                                // Add meat offering action
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add New Offering")
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                            }
                            .padding()
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Text("You haven't set up your farm yet")
                            .font(.headline)
                        
                        Button(action: {
                            // Setup farm action
                        }) {
                            Text("Set Up Farm Profile")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 50)
                }
            }
            .navigationTitle("Farm Dashboard")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct MeatOfferingCard: View {
    let offering: MeatOffering
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(offering.type)
                    .font(.headline)
                
                Text(offering.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text("$\(String(format: "%.2f", offering.price)) \(offering.unit)")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            Toggle("", isOn: .constant(offering.available))
                .labelsHidden()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    MainTabView()
        .environmentObject(MockDataStore())
} 