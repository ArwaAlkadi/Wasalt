//
//  PermissionViewModel.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//

// Permissions and logic for notifications and location

import MapKit
import Combine
import UserNotifications

// MARK: - PermissionsViewModel → Handles all permission-related logic required for the app.
final class PermissionsViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var isLocationAuthorized: Bool = false
    @Published var isNotificationAuthorized: Bool = false

    @Published var showLocationSettingsAlert: Bool = false
    @Published var showNotificationSettingsAlert: Bool = false

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        checkLocationAuthorizationStatus()
        checkNotificationAuthorizationStatus()
    }

    var areAllPermissionsGranted: Bool {
        isLocationAuthorized && isNotificationAuthorized
    }

    func refreshPermissions() {
        checkLocationAuthorizationStatus()
        checkNotificationAuthorizationStatus()
    }

    // MARK: - Location
    func checkLocationAuthorizationStatus() {
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            isLocationAuthorized = true
        case .denied, .restricted, .notDetermined:
            isLocationAuthorized = false
        @unknown default:
            isLocationAuthorized = false
        }
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorizationStatus()
    }

    // MARK: - Notifications
    func checkNotificationAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    self.isNotificationAuthorized = true
                case .denied, .notDetermined:
                    self.isNotificationAuthorized = false
                @unknown default:
                    self.isNotificationAuthorized = false
                }
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async {
                    self.isNotificationAuthorized = granted

                    if !granted {
                        self.showNotificationSettingsAlert = true
                    }
                }
            }
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
