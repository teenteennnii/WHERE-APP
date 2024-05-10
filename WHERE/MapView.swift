//
//  MapView.swift
//  WHERE
//
//  Created by Jitpanu Nopwijit on 14/4/2567 BE.
//

import SwiftUI
import MapKit
import Firebase

struct MapView: View {

    @StateObject private var viewModel = MapViewModel()
    let fromId: String
    let toId: String
    @State private var isLocationNotFoundAlertPresented = false
        
    init(fromId: String, toId: String) {
        self.fromId = fromId
        self.toId = toId
    }
    
    var body: some View {
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.annotations) { annotation in
                    MapPin(coordinate: annotation.coordinate, tint: .red)
                }
                .onAppear() {
                    viewModel.checkIfLocationServiceIsEnabled(fromId: fromId, toId: toId)
                }

    }
    
}

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 13.745394, longitude: 100.534455), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @Published var annotations: [Annotation] = []
    
    var locationManager: CLLocationManager?
    var firestoreListener: ListenerRegistration?
    
    func checkIfLocationServiceIsEnabled(fromId: String, toId: String) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
        } else {
            print("Please turn on location")
        }
        
        fetchRecentLocation(fromId: fromId, toId: toId)
    }
    
    private func fetchRecentLocation(fromId: String, toId: String) {
        FirebaseManager.shared.firestore
                .collection("recent_location")
                .document(toId)
                .collection("location")
                .document(fromId)
                .getDocument { document, error in
                    if let error = error {
                        print("Error fetching recent location document: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let document = document, document.exists else {
                        print("Recent location document not found")
                        return
                    }
                    
                    guard let locationData = document.data(),
                          let latitude = locationData["latitude"] as? CLLocationDegrees,
                          let longitude = locationData["longitude"] as? CLLocationDegrees else {
                        print("Error parsing recent location data")

                        return
                    }
                    
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    self.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    let annotation = Annotation(coordinate: coordinate)
                    self.annotations = [annotation]
                }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location is restricted")
        case .denied:
            print("This application's location is denied")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            
        @unknown default:
            break
            
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

struct Annotation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

#Preview {
    MainView()
}
