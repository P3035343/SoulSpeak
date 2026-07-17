import SwiftUI
import MapKit
import CoreLocation

/// GPS-based mental health resource locator.
/// Shows nearby therapists, crisis centers, and hospitals on a map.
struct NearbyResourcesView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedCategory: ResourceCategory = .therapist
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedItem: MKMapItem?
    @State private var isSearching = false
    
    enum ResourceCategory: String, CaseIterable {
        case therapist = "Therapist"
        case crisisCenter = "Crisis Center"
        case hospital = "Hospital"
        case supportGroup = "Support Group"
        case wellness = "Wellness Center"
        
        var searchQuery: String {
            switch self {
            case .therapist: return "therapist mental health counselor"
            case .crisisCenter: return "crisis center mental health emergency"
            case .hospital: return "hospital emergency room"
            case .supportGroup: return "mental health support group"
            case .wellness: return "wellness center meditation yoga"
            }
        }
        
        var icon: String {
            switch self {
            case .therapist: return "person.fill"
            case .crisisCenter: return "cross.circle.fill"
            case .hospital: return "building.2.fill"
            case .supportGroup: return "person.3.fill"
            case .wellness: return "leaf.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .therapist: return SSColors.primary
            case .crisisCenter: return .red
            case .hospital: return .blue
            case .supportGroup: return .green
            case .wellness: return .purple
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category selector
                categoryPicker
                
                // Map
                Map(coordinateRegion: $region, annotationItems: searchResults) { item in
                    MapAnnotation(coordinate: item.placemark.coordinate) {
                        mapPin(for: item)
                    }
                }
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Results list
                resultsList
            }
            .navigationTitle("Nearby Help")
            .onAppear {
                locationManager.requestLocation()
            }
            .onChange(of: locationManager.location) { _, location in
                if let location = location {
                    region.center = location.coordinate
                    searchNearby()
                }
            }
            .onChange(of: selectedCategory) { _, _ in
                searchNearby()
            }
        }
    }
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ResourceCategory.allCases, id: \.rawValue) { category in
                    Button(action: { selectedCategory = category }) {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 12))
                            Text(category.rawValue)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(
                            Capsule().fill(
                                selectedCategory == category
                                    ? category.color.opacity(0.2)
                                    : Color.gray.opacity(0.1)
                            )
                        )
                        .foregroundColor(
                            selectedCategory == category
                                ? category.color
                                : .secondary
                        )
                        .overlay(
                            Capsule().stroke(
                                selectedCategory == category
                                    ? category.color.opacity(0.5)
                                    : Color.clear,
                                lineWidth: 1
                            )
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
    
    private func mapPin(for item: MKMapItem) -> some View {
        VStack(spacing: 2) {
            Image(systemName: selectedCategory.icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(selectedCategory.color)
                .clipShape(Circle())
                .shadow(radius: 3)
            
            if selectedItem?.placemark.coordinate.latitude == item.placemark.coordinate.latitude {
                Text(item.name ?? "")
                    .font(.system(size: 10, weight: .medium))
                    .padding(4)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .onTapGesture {
            selectedItem = item
        }
    }
    
    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isSearching {
                    ProgressView("Searching nearby...")
                        .padding()
                } else if searchResults.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        Text("No results found nearby")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text("Try a different category or expand your search area")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .padding(32)
                } else {
                    ForEach(searchResults, id: \.self) { item in
                        resourceCard(for: item)
                    }
                }
            }
            .padding()
        }
    }
    
    private func resourceCard(for item: MKMapItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: selectedCategory.icon)
                    .foregroundColor(selectedCategory.color)
                Text(item.name ?? "Unknown")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                if let distance = distanceString(to: item) {
                    Text(distance)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            if let address = item.placemark.title {
                Text(address)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack(spacing: 12) {
                if let phone = item.phoneNumber {
                    Button(action: { callNumber(phone) }) {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                            Text("Call")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(SSColors.primary.opacity(0.1))
                        .foregroundColor(SSColors.primary)
                        .clipShape(Capsule())
                    }
                }
                
                Button(action: { openDirections(to: item) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        Text("Directions")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
    
    // MARK: - Actions
    
    private func searchNearby() {
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = selectedCategory.searchQuery
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false
            if let response = response {
                searchResults = response.mapItems
            }
        }
    }
    
    private func distanceString(to item: MKMapItem) -> String? {
        guard let userLocation = locationManager.location else { return nil }
        let itemLocation = CLLocation(
            latitude: item.placemark.coordinate.latitude,
            longitude: item.placemark.coordinate.longitude
        )
        let distance = userLocation.distance(from: itemLocation)
        let miles = distance / 1609.34
        return String(format: "%.1f mi", miles)
    }
    
    private func callNumber(_ number: String) {
        let cleaned = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "tel://\(cleaned)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openDirections(to item: MKMapItem) {
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
}
