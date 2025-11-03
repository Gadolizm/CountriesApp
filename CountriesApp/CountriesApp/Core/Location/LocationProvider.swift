//
//  LocationProvider.swift
//  CountriesApp
//
//  Created by Haitham Gado on 01/11/2025.
//


import CoreLocation

@MainActor
final class LocationProvider: NSObject, CLLocationManagerDelegate, LocationProvidingProtocol {
    private let manager = CLLocationManager()
    private var completion: ((String?) -> Void)?

    func requestCountryCode(_ completion: @escaping (String?) -> Void) {
        self.completion = completion
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .restricted, .denied: complete(with: nil)
        default: manager.requestLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: manager.requestLocation()
        case .denied, .restricted: complete(with: nil)
        default: break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        complete(with: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return complete(with: nil) }
        Task {
            do {
                let placemarks = try await CLGeocoder().reverseGeocodeLocation(loc)
                complete(with: placemarks.first?.isoCountryCode)
            } catch {
                complete(with: nil)
            }
        }
    }

    private func complete(with code: String?) {
        completion?(code)
        completion = nil
    }
}
