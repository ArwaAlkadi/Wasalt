//
//  LocationManager.swift
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
import Combine

//MARK: - LocationManager → continuously tracks the user’s real GPS location.
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var userLocation: CLLocation?
    @Published var wrongDirectionTriggered: Bool = false

    //  هذا اللي بتراقبه الواجهة/الفيو مودل
    @Published var tripExpired: Bool = false

    private let tripExpirySeconds: TimeInterval = 2.5 * 60 * 60
    private var expiryTimer: AnyCancellable?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest

        if let modes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String],
           modes.contains("location") {
            manager.allowsBackgroundLocationUpdates = true
            manager.pausesLocationUpdatesAutomatically = false
        }

        startExpiryTimer()
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func start() {
        manager.startUpdatingLocation()
    }

    // MARK: - Geofencing (Trip)
    func startTripGeofences(start: Station, destination: Station, allStations: [Station]) {

        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            print("⚠️ [GeoFence] Monitoring not available")
            return
        }

        stopTripGeofences()

        tripExpired = false

        UserDefaults.standard.set(destination.order, forKey: "currentDestinationOrder")
        UserDefaults.standard.set(destination.name,  forKey: "currentDestinationName")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "tripStartTimestamp")

        // العكس
        let correctTerminalName: String
        if destination.order > start.order {
            correctTerminalName = allStations.max(by: { $0.order < $1.order })?.name ?? ""
        } else if destination.order < start.order {
            correctTerminalName = allStations.min(by: { $0.order < $1.order })?.name ?? ""
        } else {
            correctTerminalName = ""
        }
        UserDefaults.standard.set(correctTerminalName, forKey: "correctTerminalName")

        //  الاقتراب
        let approachRegion = CLCircularRegion(
            center: destination.coordinate,
            radius: TripRadius.approaching,
            identifier: "approach_\(destination.order)"
        )
        approachRegion.notifyOnEntry = true
        approachRegion.notifyOnExit  = false
        manager.startMonitoring(for: approachRegion)
        print("🟡 [GeoFence] Monitoring APPROACH for \(destination.name)")

        //  الوصول
        let arrivalRegion = CLCircularRegion(
            center: destination.coordinate,
            radius: TripRadius.arrival,
            identifier: "arrival_\(destination.order)"
        )
        arrivalRegion.notifyOnEntry = true
        arrivalRegion.notifyOnExit  = false
        manager.startMonitoring(for: arrivalRegion)
        print("🟢 [GeoFence] Monitoring ARRIVAL for \(destination.name)")

        //  عكس الاتجاه (محطة وحدة)
        let wrongOrder: Int
        if destination.order > start.order {
            wrongOrder = start.order - 1
        } else {
            wrongOrder = start.order + 1
        }

        if let wrongStation = allStations.first(where: { $0.order == wrongOrder }) {
            let wrongRegion = CLCircularRegion(
                center: wrongStation.coordinate,
                radius: TripRadius.wrongDirection,
                identifier: "wrong_direction"
            )
            wrongRegion.notifyOnEntry = true
            wrongRegion.notifyOnExit  = false
            manager.startMonitoring(for: wrongRegion)

            print("🚨 [GeoFence] Monitoring WRONG direction at \(wrongStation.name)")

            LocalNotificationManager.shared.scheduleWrongDirectionNotification(
                wrongStation: wrongStation,
                terminalName: correctTerminalName
            )
        }
    }

    func stopTripGeofences() {
        for region in manager.monitoredRegions {
            if region.identifier.hasPrefix("approach_")
                || region.identifier.hasPrefix("arrival_")
                || region.identifier == "wrong_direction" {
                manager.stopMonitoring(for: region)
            }
        }

        UserDefaults.standard.removeObject(forKey: "currentDestinationOrder")
        UserDefaults.standard.removeObject(forKey: "currentDestinationName")
        UserDefaults.standard.removeObject(forKey: "tripStartTimestamp")
        UserDefaults.standard.removeObject(forKey: "correctTerminalName")

        print("🧹 [GeoFence] Stop trip geofences")
    }

    // MARK: - Expiry (UI helper)
    private func startExpiryTimer() {
        expiryTimer?.cancel()
        expiryTimer = Timer
            .publish(every: 15, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkTripExpiryAndExpireIfNeeded()
            }
    }

    private func checkTripExpiryAndExpireIfNeeded() {
        // ما فيه رحلة؟ لا تسوي شي
        guard UserDefaults.standard.object(forKey: "currentDestinationOrder") != nil else {
            return
        }

        let startTS = UserDefaults.standard.double(forKey: "tripStartTimestamp")
        guard startTS != 0 else {
            expireTrip()
            return
        }

        let elapsed = Date().timeIntervalSince1970 - startTS
        if elapsed > tripExpirySeconds {
            expireTrip()
        }
    }

    private func expireTrip() {
        guard tripExpired == false else { return }

        print("⏱️ [GeoFence] Trip expired — cancel everything")
        tripExpired = true

        stopTripGeofences()
        LocalNotificationManager.shared.cancelTripNotifications()
    }

    // MARK: - CLLocationManagerDelegate
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

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circular = region as? CLCircularRegion else { return }

        guard UserDefaults.standard.object(forKey: "currentDestinationOrder") != nil else {
            print("ℹ️ [GeoFence] Entered \(circular.identifier) but no active trip")
            return
        }

        //  expiry 2.5h (ينطبق على كل شيء: وصول/اقتراب/عكس)
        let startTS = UserDefaults.standard.double(forKey: "tripStartTimestamp")
        if startTS == 0 {
            expireTrip()
            return
        }

        let elapsed = Date().timeIntervalSince1970 - startTS
        if elapsed > tripExpirySeconds {
            print("⏱️ [GeoFence] Trip expired — no notification")
            expireTrip()
            return
        }

        let destOrder = UserDefaults.standard.integer(forKey: "currentDestinationOrder")
        let destName  = UserDefaults.standard.string(forKey: "currentDestinationName") ?? ""

        let notif = LocalNotificationManager.shared

        //  عكس الاتجاه
        if circular.identifier == "wrong_direction" {
            print("🚨 [GeoFence] Wrong direction detected")

            // داخل التطبيق فقط (بانر)
            DispatchQueue.main.async {
                self.wrongDirectionTriggered = true
            }
            return
        }

        //  الاقتراب
        if circular.identifier == "approach_\(destOrder)" {
            print("🟡 [GeoFence] Approaching destination: \(destName)")
            notif.notifyApproaching(stationName: destName)
            return
        }

        //  الوصول
        if circular.identifier == "arrival_\(destOrder)" {
            print("🟢 [GeoFence] Arrived to destination: \(destName)")
            notif.notifyArrival(stationName: destName)
            stopTripGeofences()
            return
        }

        print("ℹ️ [GeoFence] Entered unrelated region: \(circular.identifier)")
    }

    func locationManager(_ manager: CLLocationManager,
                         monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        print("⚠️ [GeoFence] Monitoring failed for region \(region?.identifier ?? "nil"): \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager,
                         didStartMonitoringFor region: CLRegion) {
        print("✅ [GeoFence] Started monitoring: \(region.identifier)")
    }
}

