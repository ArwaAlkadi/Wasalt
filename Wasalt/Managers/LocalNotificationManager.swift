//
//  LocalNotificationManager.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 17/12/2025.
//

/*
 
==================================================
Important Note – Notification Logic
(LocalNotificationManager)
==================================================

This file is responsible for sending local notifications.

Key concept:
Location-based notifications are managed by iOS itself,
not directly by the app.

App responsibility:
- Define notification content
- Define geofence regions (approaching, arrival, wrong direction)

System responsibility:
- Monitor user location
- Trigger notifications when entering regions
- Works even if the app is backgrounded or closed

Notification types used:
1) Location-based notifications
   - UNLocationNotificationTrigger
   - Reliable in background

2) Fallback time-based notifications
   - Triggered after geofence entry
   - Used to ensure in-app delivery

Why notifications are canceled:
- When the trip ends
- Or when the trip expires
To prevent outdated or incorrect alerts.

Connection to LocationManager:
LocationManager detects geofence entry
→ then calls LocalNotificationManager
to show the appropriate notification.
 
*/

import MapKit
import UserNotifications

// MARK: - LocalNotificationManager
/// LocalNotificationManager → sends local notifications (arrival/approaching + wrongDirection).
final class LocalNotificationManager {

    // MARK: - Singleton
    static let shared = LocalNotificationManager()
    private init() {}

    // MARK: - Authorization
    func requestAuthIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            print("🔔 Notification auth granted? \(granted), error: \(String(describing: error))")
        }
    }

    // MARK: - Cancel Notifications
    func cancelTripNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [
                "approaching_notification",
                "arrival_notification",
                "approaching_notification_geofence",
                "arrival_notification_geofence",
                "wrong_direction_notification"
            ]
        )
    }

    // MARK: - Schedule Notifications
    func scheduleLocationNotifications(for station: Station) {
        cancelTripNotifications()
        scheduleApproachingNotification(for: station)
        scheduleArrivalNotification(for: station)
    }

    // MARK: - Approaching Notification
    private func scheduleApproachingNotification(for station: Station) {
        let content = UNMutableNotificationContent()
        content.title = String(format: "alert.approaching".localized, station.name)
        content.sound = .default

        let region = CLCircularRegion(
            center: station.coordinate,
            radius: TripRadius.approaching,
            identifier: "approaching_notification"
        )
        region.notifyOnEntry = true
        region.notifyOnExit  = false

        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)

        let request = UNNotificationRequest(
            identifier: "approaching_notification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Approaching notif error:", error.localizedDescription)
            } else {
                print("✅ Scheduled APPROACHING location notification for \(station.name)")
            }
        }
    }

    // MARK: - Arrival Notification
    private func scheduleArrivalNotification(for station: Station) {
        let content = UNMutableNotificationContent()
        content.title = String(format: "alert.arrived".localized, station.name)
        content.sound = .default

        let region = CLCircularRegion(
            center: station.coordinate,
            radius: TripRadius.arrival,
            identifier: "arrival_notification"
        )
        region.notifyOnEntry = true
        region.notifyOnExit  = false

        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)

        let request = UNNotificationRequest(
            identifier: "arrival_notification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Arrival notif error:", error.localizedDescription)
            } else {
                print("✅ Scheduled ARRIVAL location notification for \(station.name)")
            }
        }
    }

    // MARK: - Geofence Fallback Notifications
    /// Geofence-triggered fallback notifications (called from CLLocationManager delegate)
    func notifyApproaching(stationName: String) {
        let content = UNMutableNotificationContent()
        content.title = String(format: "alert.approaching".localized, stationName)
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(
            identifier: "approaching_notification_geofence",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(req)
    }

    func notifyArrival(stationName: String) {
        let content = UNMutableNotificationContent()
        content.title = String(format: "alert.arrived".localized, stationName)
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(
            identifier: "arrival_notification_geofence",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(req)
    }

    // MARK: - Wrong Direction Notification
    /// Wrong Direction as LOCATION notification (works outside app)
    func scheduleWrongDirectionNotification(wrongStation: Station, terminalName: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["wrong_direction_notification"]
        )

        let content = UNMutableNotificationContent()
        content.title = "alert.wrongDirection.title".localized
        content.body = terminalName.isEmpty
            ? "alert.wrongDirection.body.noTerminal".localized
            : String(
                format: "alert.wrongDirection.body.withTerminal".localized,
                terminalName
            )
        content.sound = .default

        let region = CLCircularRegion(
            center: wrongStation.coordinate,
            radius: TripRadius.wrongDirection,
            identifier: "wrong_direction_notification_region"
        )
        region.notifyOnEntry = true
        region.notifyOnExit  = false

        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)

        let req = UNNotificationRequest(
            identifier: "wrong_direction_notification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(req) { error in
            if let error = error {
                print("❌ Wrong direction notif error:", error.localizedDescription)
            } else {
                print("✅ Scheduled WRONG DIRECTION location notification")
            }
        }
    }
}
