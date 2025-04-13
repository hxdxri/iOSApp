import SwiftUI

struct FarmDetailView: View {
    let farm: Farm
    @EnvironmentObject var dataStore: MockDataStore
    @State private var isMessageSheetPresented = false
    @State private var messageText = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Farm header
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(height: 200)
                    
                    Image(systemName: farm.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.green)
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(farm.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(farm.location)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                
                                Text(String(format: "%.1f", farm.rating))
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                        }
                        .padding()
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                }
                
                // About section
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                    
                    Text(farm.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Meat offerings
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meat Offerings")
                        .font(.headline)
                    
                    ForEach(farm.meatOfferings) { offering in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(offering.type)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text(offering.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(String(format: "$%.2f %@", offering.price, offering.unit))
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // Delivery options
                VStack(alignment: .leading, spacing: 8) {
                    Text("Delivery & Pickup")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        VStack {
                            Image(systemName: farm.deliveryAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(farm.deliveryAvailable ? .green : .red)
                                .font(.title3)
                            
                            Text("Delivery")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider().frame(height: 40)
                        
                        VStack {
                            Image(systemName: farm.pickupAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(farm.pickupAvailable ? .green : .red)
                                .font(.title3)
                            
                            Text("On-farm Pickup")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        isMessageSheetPresented = true
                    } label: {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Message Farmer")
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    
                    Button {
                        // Handle ordering action
                    } label: {
                        HStack {
                            Image(systemName: "bag.fill")
                            Text("Place Bulk Order")
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .padding(.bottom, 16)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isMessageSheetPresented) {
            MessageSheetView(farm: farm, isPresented: $isMessageSheetPresented)
                .environmentObject(dataStore)
        }
    }
}

struct MessageSheetView: View {
    let farm: Farm
    @Binding var isPresented: Bool
    @EnvironmentObject var dataStore: MockDataStore
    @State private var messageText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Send Message to \(farm.name)")
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
                    if !messageText.isEmpty, let farmOwner = dataStore.users.first(where: { $0.id == farm.ownerId }) {
                        dataStore.sendMessage(to: farmOwner.id, content: messageText)
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
    NavigationStack {
        if let sampleFarm = MockDataStore().farms.first {
            FarmDetailView(farm: sampleFarm)
                .environmentObject(MockDataStore())
        } else {
            Text("No farm data available")
        }
    }
} 