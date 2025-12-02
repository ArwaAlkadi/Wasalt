//
//  MetroTripViewModel.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//


import SwiftUI
import MapKit
import AVFoundation
import Combine


/*
 🔴 File Contents | محتوى الكود
     •    MetroTripViewModel → handles trip flow, ETA updates, and arrival logic.
     •    InAppAlertManager → manages in-app alerts (banner + vibration + flash).
 */


//MARK:  -MetroTripViewModel → handles trip flow, ETA updates, and arrival logic.
final class MetroTripViewModel: ObservableObject {
    
    private let stations: [Station]
    private let notificationManager: LocalNotificationManager
    
    // حالة الرحلة
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
    
    let nearStationDistance: CLLocationDistance = 1000.0

    private let arrivalDistance: CLLocationDistance = 100.0
    
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
            statusText = "اختر محطتك أولاً."
            return
        }
        
        if isChangingDestination {
            guard let baseStation = lastPassedStation ?? startStation else {
                statusText = "ما قدرنا نعرف آخر محطة ركبت منها."
                return
            }
            startStation = baseStation
            
            if dest.order == baseStation.order {
                currentNearestStation = dest
                stationsRemaining = 0
                etaMinutes = 0
                nextStation = nil
                statusText = "أنت بالفعل في محطتك: \(dest.name)"
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
            statusText = "ماتقدر تبدأ: موقعك غير معروف."
            return
        }
        guard isUserNearAnyStation(userLocation: location) else {
            statusText = "قرب من أي محطة عشان تقدر تبدأ الرحلة."
            return
        }
        guard let startSt = nearestStation(to: location) else {
            statusText = "ما قدرنا نحدد أقرب محطة."
            return
        }
        
        startStation = startSt
        lastPassedStation = startSt
        
        if dest.order == startSt.order {
            currentNearestStation = dest
            stationsRemaining = 0
            etaMinutes = 0
            nextStation = nil
            statusText = "أنت بالفعل في محطتك: \(dest.name)"
            showArrivalSheet = true
            isTracking = false
            activeAlert = .arrival(stationName: dest.name)
            notificationManager.cancelTripNotifications()
            return
        }
        
        // اتجاه الرحلة
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
        
        // إشعارات باك أب بالوقت (Plan B لو الـ GPS انقطع)
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
    
    // تحديث من الموقع الحقيقي
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
        // نحتفظ بأقرب محطة وآخر محطة
        if let current = currentNearestStation {
            lastPassedStation = current
        }
        // نفرغ الوجهة فقط
        selectedDestination = nil
        nextStation = nil
        stationsRemaining = 0
        etaMinutes = 0
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
        
        let destLocation = CLLocation(latitude: dest.coordinate.latitude,
                                      longitude: dest.coordinate.longitude)
        let distanceToDest = destLocation.distance(from: location)
        
        if distanceToDest <= arrivalDistance {
            statusText = "وصلت إلى محطتك: \(dest.name)"
            isTracking = false
            showArrivalSheet = true
            
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
    @Published var bannerTitle: String = ""
    @Published var bannerMessage: String = ""
    
    private var flashTimer: Timer?
    private var isTorchOn: Bool = false
    private var isPatternRunning: Bool = false
    
    /// أقصى مدة نشغّل فيها النمط قبل ما نوقفه تلقائياً (فلاش + اهتزاز) – 15 ثانية
    private let maxPatternDuration: TimeInterval = 15
    /// مدة بقاء البانر على الشاشة قبل ما يختفي تلقائياً – 5 دقائق
    private let bannerAutoDismiss: TimeInterval = 5 * 60
    
    // عرض التنبيه
    func showCriticalAlert(title: String) {
        bannerTitle = title
        bannerMessage = ""
        isShowingBanner = true
        startPatternVibrationAndFlash()
        
        // إخفاء البانر تلقائياً بعد 5 دقائق إذا ما قفله المستخدم
        DispatchQueue.main.asyncAfter(deadline: .now() + bannerAutoDismiss) { [weak self] in
            guard let self = self, self.isShowingBanner else { return }
            self.dismiss()
        }
    }
    
    // إخفاء التنبيه (من زر X مثلاً)
    func dismiss() {
        isShowingBanner = false
        stopPatternVibrationAndFlash()
    }
    
    // النمط (اهتزاز + فلاش)
    
    /// يبدأ نمط متكرر: كل 0.35 ثانية → يهز ويقلب وضع الفلاش
    private func startPatternVibrationAndFlash() {
        stopPatternVibrationAndFlash()
        isPatternRunning = true
        
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { [weak self] _ in
            guard let self = self, self.isPatternRunning else { return }
            self.vibrateOnce()
            self.toggleTorch()
        }
        
        // إيقاف تلقائي بعد maxPatternDuration ثواني
        DispatchQueue.main.asyncAfter(deadline: .now() + maxPatternDuration) { [weak self] in
            self?.stopPatternVibrationAndFlash()
        }
    }
    
    /// يوقف النمط ويطفئ الفلاش
    private func stopPatternVibrationAndFlash() {
        isPatternRunning = false
        flashTimer?.invalidate()
        flashTimer = nil
        setTorch(on: false)
    }
    
    /// هزّة واحدة
    private func vibrateOnce() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    /// قلب حالة الفلاش (تشغيل/إطفاء)
    private func toggleTorch() {
        isTorchOn.toggle()
        setTorch(on: isTorchOn)
    }
    
    /// تشغيل/إطفاء فلاش الكاميرا الخلفية
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
            print("Torch error:", error.localizedDescription)
        }
    }
}

enum MetroAlertType: Equatable {
    case approaching(stationName: String, etaMinutes: Int)
    case arrival(stationName: String)
}









