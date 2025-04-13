import SwiftUI

struct FarmListingView: View {
    @EnvironmentObject var dataStore: MockDataStore
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search farms or meat types", text: $searchText)
                    .padding(.vertical, 10)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding()
            
            List {
                ForEach(dataStore.getFarmsFiltered(by: searchText)) { farm in
                    NavigationLink(destination: FarmDetailView(farm: farm)) {
                        FarmListItem(farm: farm)
                    }
                }
                
                if dataStore.getFarmsFiltered(by: searchText).isEmpty {
                    Text("No farms match your search")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Farm Listings")
    }
}

struct FarmListItem: View {
    let farm: Farm
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(width: 80, height: 80)
                
                Image(systemName: farm.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(farm.name)
                    .font(.headline)
                
                Text(farm.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text(String(format: "%.1f (%d)", farm.rating, farm.reviewCount))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(farm.meatOfferings.map { $0.type }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    if farm.deliveryAvailable {
                        Label("Delivery", systemImage: "car.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    
                    if farm.pickupAvailable {
                        Label("Pickup", systemImage: "bag.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        FarmListingView()
            .environmentObject(MockDataStore())
    }
} 