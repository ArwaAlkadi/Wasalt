import SwiftUI
import MapKit
import AVFoundation
import Combine


/*
 🔴 File Contents | محتوى الكود
     •    MetroTripViewModel → handles trip flow, ETA updates, and arrival logic.
     •    InAppAlertManager → manages in-app alerts (banner + vibration + flash).
     •    LocalNotificationManager → sends local notifications (arrival/approaching + backup timers).
 */


//MARK:  -MetroTripViewModel → handles trip flow, ETA updates, and arrival logic.
final class MetroTripViewModel: ObservableObject {
    
    private let stations: [Station]
    private let notificationManager: LocalNotificationManager
    
    @Published var selectedDestination: Station?
    @Published var isTracking: Bool = false
    @Published var startStation: Station?
    @Published var currentNearestStation: Station?
    @Published var lastPassedStation: Station?
    @Published var nextStation: Station?
    @Published var stationsRemaining: Int = 0
    @Published var etaMinutes: Int = 0
    @Published var statusText: String = ""
    @Published var showArrivalSheet: Bool = false
    @Published var activeAlert: MetroAlertType? = nil
    @Published var upcomingStations: [Station] = []
    
    let nearStationDistance: CLLocationDistance = 500000.0                                                          //Here
    private let arrivalDistance: CLLocationDistance = 10.0
    
    private enum TripDirection { case forward, backward }
    private var tripDirection: TripDirection?
    private var didFireApproachingAlert = false
    private var didFireArrivalAlert = false
    private var isChangingDestination: Bool = false
    
    init(
        stations: [Station],
        notificationManager: LocalNotificationManager = .shared
    ) {
        self.stations = stations
        self.notificationManager = notificationManager
    }
    
    func selectDestination(_ station: Station) {
        selectedDestination = station
    }
    
    func startTrip(userLocation: CLLocation?) {
        guard let dest = selectedDestination else {
            statusText = "sheet.status.chooseDestination".localized
            return
        }
        
        if isChangingDestination {
            guard let baseStation = lastPassedStation ?? startStation else {
                statusText = "error.unknown".localized
                return
            }
            startStation = baseStation
            
            if dest.order == baseStation.order {
                currentNearestStation = dest
                stationsRemaining = 0
                etaMinutes = 0
                nextStation = nil
                upcomingStations = []
                statusText = String(
                    format: "alert.arrived".localized,
                    dest.name
                )
                showArrivalSheet = true
                isTracking = false
                activeAlert = .arrival(stationName: dest.name)
                notificationManager.cancelTripNotifications()
                return
            }
            
            if dest.order > baseStation.order {
                tripDirection = .forward
            } else {
                tripDirection = .backward
            }
            
            isTracking = true
            showArrivalSheet = false
            didFireApproachingAlert = false
            didFireArrivalAlert = false
            statusText = ""
            isChangingDestination = false
            
            let fakeLocation = CLLocation(latitude: baseStation.coordinate.latitude,
                                          longitude: baseStation.coordinate.longitude)
            updateProgress(for: fakeLocation)
            
            if etaMinutes > 3 {
                notificationManager.scheduleApproachingNotification(
                    inMinutes: max(etaMinutes - 3, 1),
                    stationName: dest.name
                )
            }
            if etaMinutes > 0 {
                notificationManager.scheduleArrivalNotification(
                    inMinutes: etaMinutes,
                    stationName: dest.name
                )
            }
            return
        }
        
        guard let location = userLocation else {
            statusText = "sheet.status.noLocation".localized
            return
        }
        guard isUserNearAnyStation(userLocation: location) else {
            statusText = "sheet.status.notNearMetro".localized
            return
        }
        guard let startSt = nearestStation(to: location) else {
            statusText = "error.unknown".localized
            return
        }
        
        startStation = startSt
        lastPassedStation = startSt
        
        if dest.order == startSt.order {
            currentNearestStation = dest
            stationsRemaining = 0
            etaMinutes = 0
            nextStation = nil
            upcomingStations = []
            statusText = String(
                format: "trip.status.alreadyAtDestination".localized,
                  dest.name
            )
            showArrivalSheet = true
            isTracking = false
            activeAlert = .arrival(stationName: dest.name)
            notificationManager.cancelTripNotifications()
            return
        }
        
        if dest.order > startSt.order {
            tripDirection = .forward
        } else {
            tripDirection = .backward
        }
        
        isTracking = true
        showArrivalSheet = false
        didFireApproachingAlert = false
        didFireArrivalAlert = false
        statusText = ""
        
        updateProgress(for: location)
        
        if etaMinutes > 3 {
            notificationManager.scheduleApproachingNotification(
                inMinutes: max(etaMinutes - 3, 1),
                stationName: dest.name
            )
        }
        if etaMinutes > 0 {
            notificationManager.scheduleArrivalNotification(
                inMinutes: etaMinutes,
                stationName: dest.name
            )
        }
    }
    
    func userLocationUpdated(_ location: CLLocation?) {
        guard isTracking, let location = location else { return }
        updateProgress(for: location)
    }
    
    func endTripAndReset() {
        isTracking = false
        resetProgress(keepDestination: false)
        statusText = ""
        notificationManager.cancelTripNotifications()
    }
    
    func cancelAndChooseAgain() {
        isTracking = false
        
        if let current = currentNearestStation {
            lastPassedStation = current
        }
        
        selectedDestination = nil
        nextStation = nil
        stationsRemaining = 0
        etaMinutes = 0
        upcomingStations = []
        showArrivalSheet = false
        tripDirection = nil
        didFireApproachingAlert = false
        didFireArrivalAlert = false
        activeAlert = nil
        statusText = ""
        isChangingDestination = true
        notificationManager.cancelTripNotifications()
    }
    
    func clearActiveAlert() {
        activeAlert = nil
    }
    
    var middleStations: [Station] {
        guard
            let start = startStation,
            let dest  = selectedDestination
        else { return [] }
        
        if dest.order > start.order {
            return stations
                .filter { $0.order > start.order && $0.order < dest.order }
                .sorted { $0.order < $1.order }
        } else if dest.order < start.order {
            return stations
                .filter { $0.order < start.order && $0.order > dest.order }
                .sorted { $0.order > $1.order }
        } else {
            return []
        }
    }
    
    func isStationReached(_ station: Station) -> Bool {
        guard let direction = tripDirection else { return false }
        
        let refOrder: Int? =
            lastPassedStation?.order ??
            currentNearestStation?.order ??
            startStation?.order
        
        guard let currentOrder = refOrder else { return false }
        
        switch direction {
        case .forward:
            return station.order <= currentOrder
        case .backward:
            return station.order >= currentOrder
        }
    }
    
    private func updateProgress(for location: CLLocation) {
        guard let dest = selectedDestination,
              let nearest = nearestStation(to: location) else { return }
        
        if currentNearestStation?.order != nearest.order {
            lastPassedStation = nearest
        }
        currentNearestStation = nearest
        
        let result = computeRemainingStationsAndTime(from: nearest, to: dest)
        stationsRemaining = result.stations
        etaMinutes = result.minutes
        nextStation = result.next
        
        upcomingStations = computeUpcomingStations(from: nearest, to: dest)
        
        let destLocation = CLLocation(latitude: dest.coordinate.latitude,
                                      longitude: dest.coordinate.longitude)
        let distanceToDest = destLocation.distance(from: location)
        
        if distanceToDest <= arrivalDistance {
            statusText = String(
                format: "alert.arrived".localized,
                dest.name
            )
            isTracking = false
            showArrivalSheet = true
            upcomingStations = []
            
            if !didFireArrivalAlert {
                activeAlert = .arrival(stationName: dest.name)
                didFireArrivalAlert = true
                notificationManager.cancelTripNotifications()
                notificationManager.scheduleArrivalNotification(
                    inMinutes: 0,
                    stationName: dest.name
                )
            }
            return
        }
        
        statusText = ""
        
        if !didFireApproachingAlert, let direction = tripDirection {
            var previousOrder: Int?
            switch direction {
            case .forward:
                previousOrder = dest.order - 1
            case .backward:
                previousOrder = dest.order + 1
            }
            
            if let prevOrder = previousOrder,
               prevOrder != dest.order,
               let prevStation = stations.first(where: { $0.order == prevOrder }),
               nearest.order == prevStation.order {
                
                activeAlert = .approaching(
                    stationName: dest.name,
                    etaMinutes: etaMinutes
                )
                didFireApproachingAlert = true
                
                notificationManager.scheduleApproachingNotification(
                    inMinutes: 0,
                    stationName: dest.name
                )
            }
        }
    }
    
    private func computeRemainingStationsAndTime(from current: Station, to dest: Station)
    -> (stations: Int, minutes: Int, next: Station?) {
        guard let direction = tripDirection else {
            let diff = abs(dest.order - current.order)
            return (diff, 0, nil)
        }
        
        var totalMinutes = 0
        var count = 0
        var next: Station?
        
        switch direction {
        case .forward:
            if current.order >= dest.order { return (0, 0, nil) }
            for order in current.order..<dest.order {
                if let st = stations.first(where: { $0.order == order }) {
                    if count == 0 {
                        next = stations.first(where: { $0.order == order + 1 })
                    }
                    totalMinutes += st.minutesToNext ?? 0
                    count += 1
                }
            }
        case .backward:
            if current.order <= dest.order { return (0, 0, nil) }
            for order in stride(from: current.order, to: dest.order, by: -1) {
                if let st = stations.first(where: { $0.order == order }) {
                    if count == 0 {
                        next = stations.first(where: { $0.order == order - 1 })
                    }
                    totalMinutes += st.minutesToNext ?? 0
                    count += 1
                }
            }
        }
        
        return (count, totalMinutes, next)
    }
    
    private func computeUpcomingStations(from current: Station, to dest: Station) -> [Station] {
        guard let direction = tripDirection else { return [] }
        
        switch direction {
        case .forward:
            guard current.order < dest.order else { return [] }
            return stations
                .filter { $0.order > current.order && $0.order <= dest.order }
                .sorted { $0.order < $1.order }
            
        case .backward:
            guard current.order > dest.order else { return [] }
            return stations
                .filter { $0.order < current.order && $0.order >= dest.order }
                .sorted { $0.order > $1.order }
        }
    }
    
    private func nearestStation(to location: CLLocation) -> Station? {
        stations.min { lhs, rhs in
            let lhsLoc = CLLocation(latitude: lhs.coordinate.latitude,
                                    longitude: lhs.coordinate.longitude)
            let rhsLoc = CLLocation(latitude: rhs.coordinate.latitude,
                                    longitude: rhs.coordinate.longitude)
            return lhsLoc.distance(from: location) < rhsLoc.distance(from: location)
        }
    }
    
    private func isUserNearAnyStation(userLocation: CLLocation) -> Bool {
        for station in stations {
            let stLoc = CLLocation(latitude: station.coordinate.latitude,
                                   longitude: station.coordinate.longitude)
            if stLoc.distance(from: userLocation) <= nearStationDistance {
                return true
            }
        }
        return false
    }
    
    private func resetProgress(keepDestination: Bool) {
        if !keepDestination {
            selectedDestination = nil
            startStation = nil
            lastPassedStation = nil
        }
        currentNearestStation = nil
        nextStation = nil
        stationsRemaining = 0
        etaMinutes = 0
        upcomingStations = []
        showArrivalSheet = false
        tripDirection = nil
        didFireApproachingAlert = false
        didFireArrivalAlert = false
        activeAlert = nil
        isChangingDestination = false
    }
}










// MARK:  -InAppAlertManager → manages in-app alerts (banner + vibration + flash).
final class InAppAlertManager: ObservableObject {
    @Published var isShowingBanner: Bool = false
    @Published var bannerMessage: String = ""
    @Published var isArrival: Bool = false

    private var flashTimer: Timer?
    private var isTorchOn: Bool = false
    private var isPatternRunning: Bool = false

    /// مدة تشغيل الفلاش + الاهتزاز (15 ثانية)
    private let maxPatternDuration: TimeInterval = 5

    /// مدة بقاء البانر على الشاشة قبل إخفائه تلقائياً (60 ثانية)
    private let bannerAutoDismiss: TimeInterval = 5

    
    // MARK: Public API (يستعملها الـ ViewModel)
    func showApproaching(message: String) {
        bannerMessage = message
        isArrival = false
        showBanner()
    }
    
    func showArrival(message: String) {
        bannerMessage = message
        isArrival = true
        showBanner()
    }
    
    func dismiss() {
        isShowingBanner = false
        bannerMessage = ""
        stopPatternVibrationAndFlash()
    }
    
    
    // MARK: Private Helpers
    private func showBanner() {
        isShowingBanner = true
        startPatternVibrationAndFlash()
        
        // إخفاء البانر تلقائياً بعد مدة
        DispatchQueue.main.asyncAfter(deadline: .now() + bannerAutoDismiss) { [weak self] in
            guard let self = self, self.isShowingBanner else { return }
            self.dismiss()
        }
    }
    
    /// تشغيل نمط الاهتزاز + الفلاش كل 0.35 ثانية
    private func startPatternVibrationAndFlash() {
        stopPatternVibrationAndFlash()  // إلغاء أي نمط سابق
        isPatternRunning = true
        
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { [weak self] _ in
            guard let self = self, self.isPatternRunning else { return }
            self.vibrateOnce()
            self.toggleTorch()
        }
        
        // إيقاف النمط بعد 15 ثانية
        DispatchQueue.main.asyncAfter(deadline: .now() + maxPatternDuration) { [weak self] in
            self?.stopPatternVibrationAndFlash()
        }
    }
    
    /// إطفاء الفلاش + إيقاف الاهتزاز
    private func stopPatternVibrationAndFlash() {
        isPatternRunning = false
        flashTimer?.invalidate()
        flashTimer = nil
        setTorch(on: false)
    }
    
    /// هزة واحدة
    private func vibrateOnce() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    /// تشغيل/إيقاف الفلاش
    private func toggleTorch() {
        isTorchOn.toggle()
        setTorch(on: isTorchOn)
    }
    
    /// التحكم بالفلاش الحقيقي
    private func setTorch(on: Bool) {
        // في السيميوليتر ما فيه كاميرا، فـ guard يحمي من المشاكل
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back),
              device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if on {
                try device.setTorchModeOn(level: 1.0)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch Error:", error.localizedDescription)
        }
    }
}

enum MetroAlertType: Equatable {
    case approaching(stationName: String, etaMinutes: Int)
    case arrival(stationName: String)
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
        content.title = String(
            format: "alert.approaching".localized,
            stationName
        )
        content.sound = .default
        
        let seconds = TimeInterval(minutes * 60)
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(seconds, 1),
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
        content.title = String(
            format: "alert.arrived".localized,
            stationName
        )
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
