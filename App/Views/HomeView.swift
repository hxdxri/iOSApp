import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var dataStore: MockDataStore
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var selectedMapItem: Farm?
    @State private var viewMode: ViewMode = .map
    
    enum ViewMode {
        case map
        case list
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and filter bar
                searchFilterBar
                
                // View mode selector
                viewModeSelector
                
                // Main content area
                if viewMode == .map {
                    mapView
                } else {
                    listView
                }
            }
            .navigationTitle("LocalMeat")
            .sheet(item: $selectedMapItem) { farm in
                NavigationStack {
                    FarmDetailView(farm: farm)
                        .navigationBarItems(trailing: Button("Close") {
                            selectedMapItem = nil
                        })
                }
            }
            .sheet(isPresented: $showingFilters) {
                filterSheet
            }
        }
    }
    
    private var searchFilterBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search farms, locations, or meat types", text: $searchText)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: { showingFilters = true }) {
                Image(systemName: "line.3.horizontal.decrease.circle\(dataStore.selectedFarmFilters.isEmpty ? "" : ".fill")")
                    .foregroundColor(.green)
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var viewModeSelector: some View {
        Picker("View Mode", selection: $viewMode) {
            Image(systemName: "map").tag(ViewMode.map)
            Image(systemName: "list.bullet").tag(ViewMode.list)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
    
    private var mapView: some View {
        Map(coordinateRegion: $mapRegion, annotationItems: dataStore.getFarmsFiltered(by: searchText, filters: dataStore.selectedFarmFilters)) { farm in
            MapAnnotation(coordinate: farm.coordinates?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)) {
                Button {
                    selectedMapItem = farm
                } label: {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        
                        Text(farm.name)
                            .font(.caption)
                            .padding(5)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(5)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(dataStore.getFarmsFiltered(by: searchText, filters: dataStore.selectedFarmFilters)) { farm in
                    NavigationLink(destination: FarmDetailView(farm: farm)) {
                        HomeMapFarmItem(farm: farm)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if dataStore.getFarmsFiltered(by: searchText, filters: dataStore.selectedFarmFilters).isEmpty {
                    Text("No farms match your search")
                        .foregroundStyle(.secondary)
                        .padding(.top, 50)
                }
            }
            .padding()
        }
    }
    
    private var filterSheet: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Filter by Meat Type")
                    .font(.headline)
                    .padding()
                
                ForEach(dataStore.getAllMeatTypes(), id: \.self) { meatType in
                    Button(action: {
                        if dataStore.selectedFarmFilters.contains(meatType) {
                            dataStore.selectedFarmFilters.remove(meatType)
                        } else {
                            dataStore.selectedFarmFilters.insert(meatType)
                        }
                    }) {
                        HStack {
                            Text(meatType)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if dataStore.selectedFarmFilters.contains(meatType) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                Spacer()
                
                Button(action: {
                    dataStore.selectedFarmFilters.removeAll()
                }) {
                    Text("Clear All")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingFilters = false
                    }
                }
            }
        }
    }
}

struct HomeMapFarmItem: View {
    let farm: Farm
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(farm.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(farm.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    StarRatingView(rating: farm.rating)
                    
                    Text("(\(farm.reviewCount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(farm.meatOfferings.map { $0.type }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct StarRatingView: View {
    let rating: Double
    let maxRating: Int = 5
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: starType(for: star))
                    .foregroundColor(.yellow)
            }
        }
    }
    
    private func starType(for position: Int) -> String {
        if Double(position) <= rating {
            return "star.fill"
        } else if Double(position) - 0.5 <= rating {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(MockDataStore())
} 