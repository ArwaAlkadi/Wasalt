//
//  LocalNotificationManager.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 17/12/2025.
//

/*
    تنبيه مهم
 
     Important note about LocationManager and notifications

     LocationManager (Geofencing) is part of the iOS system itself,
     which means the system monitors the user’s location, not the app.


    :إحنا نحدد للنظام
   مناطق المراقبة (وصول، اقتراب، عكس الاتجاه) -

    :النظام بدوره
    يراقب الموقع حتى لو التطبيق مقفول -
    يشتغل حتى لو المستخدم سوا سوايب للصفحة -
    يشتغل حتى لو النظام سكّر التطبيق من الخلفية -

    :نفس الشي مع الإشعارات
     إشعارات الموقع تُدار من النظام -
     النظام هو اللي يقرر متى يطلق الإشعار -

    :عشان كذا
     حددنا عمر للرحلة وهو ساعتين ونص -
     وإذا انتهت الرحلة أو انتهى وقتها
      نوقف مراقبة المواقع ونلغي الإشعارات

    :الهدف
    منع إرسال تنبيهات قديمة أو غير صحيحة للمستخدم
*/

import MapKit
import UserNotifications

//MARK: - LocalNotificationManager → sends local notifications (arrival/approaching + wrongDirection).
final class LocalNotificationManager {

    static let shared = LocalNotificationManager()
    private init() {}

    func requestAuthIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            print("🔔 Notification auth granted? \(granted), error: \(String(describing: error))")
        }
    }

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

    func scheduleLocationNotifications(for station: Station) {
        cancelTripNotifications()
        scheduleApproachingNotification(for: station)
        scheduleArrivalNotification(for: station)
    }

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

    // ✅ Geofence-triggered fallback notifications (called from CLLocationManager delegate)
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

    // ✅ Wrong Direction as LOCATION notification (works outside app)
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
