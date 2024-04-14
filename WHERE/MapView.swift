//
//  MapView.swift
//  WHERE
//
//  Created by Jitpanu Nopwijit on 14/4/2567 BE.
//

import SwiftUI
import MapKit

//struct MapView: View {
//    @State private var userLocation: CLLocationCoordinate2D?
//    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
//    
//    var body: some View {
//        Map(position: $cameraPosition) {
////            Marker("My Location", /*systemImage: "person",*/ coordinate: .userLocation).tint(.red)
//                        
//            Annotation("My Location", coordinate: .userLocation) {
//                ZStack {
//                    Circle()
//                        .frame(width: 32, height: 32)
//                        .foregroundStyle(.blue.opacity(0.25))
//                    Circle()
//                        .frame(width: 20, height: 20)
//                        .foregroundStyle(.white)
//                    Circle()
//                        .frame(width: 12, height: 12)
//                        .foregroundStyle(.blue)
//                }
//            }
//        }
//        .mapControls {
//            MapCompass()
//            MapPitchToggle()
//            MapUserLocationButton()
//        }
//    }
//}
//
//extension CLLocationCoordinate2D {
//    static var userLocation: CLLocationCoordinate2D {
//        return .init(latitude: 13.736717, longitude: 100.523186)
//    }
//}
//
//extension MKCoordinateRegion {
//    static var userRegion: MKCoordinateRegion {
//        return .init(center: .userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
//    }
//}

struct MapView: View {
    
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
            .onAppear() {
                viewModel.checkIfLocationServiceIsEnabled()
            }
    }
    
}

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 13.745394, longitude: 100.534455), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    var locationManager: CLLocationManager?
    
    func checkIfLocationServiceIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
        } else {
            print("Please turn on location")
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


#Preview {
    MapView()
}
