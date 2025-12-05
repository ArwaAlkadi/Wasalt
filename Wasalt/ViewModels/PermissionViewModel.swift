//
//  PermissionViewModel.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//

// أذونات ومنطق الإشعارات والموقع

import MapKit
import Combine
import UserNotifications


/*
 🔴 File Contents | محتوى الكود
     •    PermissionsViewModel → Handles all permission–related logic required for the app to function safely.
     •    LocationManager → continuously tracks the user’s real GPS location.
     •    LocalNotificationManager → sends local notifications (arrival/approaching + backup timers).
 */


//MARK: -PermissionsViewModel → Handles all permission–related logic required for the app to function safely.
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
        let status = CLLocationManager.authorizationStatus()
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

















//MARK: -LocationManager → continuously tracks the user’s real GPS location.
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if let modes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String],
           modes.contains("location") {
            manager.allowsBackgroundLocationUpdates = true
            manager.pausesLocationUpdatesAutomatically = false
        }
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func start() {
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }
}



















//MARK: -LocalNotificationManager → sends local notifications (arrival/approaching + backup timers).
final class LocalNotificationManager {
    
    static let shared = LocalNotificationManager()
    private init() {}
    
    func requestAuthIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in }
    }
    
    func cancelTripNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [
                "approaching_notification",
                "arrival_notification"
            ]
        )
    }
    
    func scheduleApproachingNotification(inMinutes minutes: Int, stationName: String) {
        guard minutes > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "استعد! قربنا من محطتك \(stationName)"
        content.sound = .default
        
        let seconds = TimeInterval(minutes * 60)
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(seconds, 1), // ضمان > 0
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "approaching_notification",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["approaching_notification"]
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func scheduleArrivalNotification(inMinutes minutes: Int, stationName: String) {
        let content = UNMutableNotificationContent()
        content.title = "وصلت محطتك \(stationName)!"
        content.sound = .default
        
        let clampedMinutes = max(minutes, 0)
        let seconds = clampedMinutes == 0 ? 1.0 : TimeInterval(clampedMinutes * 60)
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: seconds,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "arrival_notification",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["arrival_notification"]
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

