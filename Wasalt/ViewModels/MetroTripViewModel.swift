//
//  MetroTripViewModel.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//

import MapKit
import Combine

//تعديل المسافات
enum TripRadius {
    static let arrival: CLLocationDistance = 250.0
    static let approaching: CLLocationDistance = 500.0
    static let wrongDirection: CLLocationDistance = 500.0
}

// MARK: - MetroTripViewModel → handles trip flow, ETA updates, and arrival logic.
final class MetroTripViewModel: ObservableObject {

    private let stations: [Station]
    private let notificationManager: LocalNotificationManager

 
    private let locationManager: LocationManager?
    private var cancellables = Set<AnyCancellable>()

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

    /// الوصول الفعلي للمحطة
    private let arrivalDistance: CLLocationDistance = TripRadius.arrival
    /// بداية «الاقتراب» من المحطة
    private let approachingDistance: CLLocationDistance = TripRadius.approaching

    private enum TripDirection { case forward, backward }
    private var tripDirection: TripDirection?
    private var didFireApproachingAlert = false
    private var didFireArrivalAlert = false
    private var isChangingDestination: Bool = false

    init(
        stations: [Station],
        notificationManager: LocalNotificationManager = .shared,
        locationManager: LocationManager? = nil
    ) {
        self.stations = stations
        self.notificationManager = notificationManager
        self.locationManager = locationManager

        locationManager?.$tripExpired
            .receive(on: RunLoop.main)
            .sink { [weak self] expired in
                guard let self = self else { return }
                guard expired else { return }

                self.isTracking = false
                self.showArrivalSheet = false
                self.resetProgress(keepDestination: false)
                self.notificationManager.cancelTripNotifications()
            }
            .store(in: &cancellables)
    }

    func selectDestination(_ station: Station) {
        selectedDestination = station
    }

    // - Start Trip
    func startTrip(userLocation: CLLocation?) {
        guard let dest = selectedDestination else {
            statusText = "sheet.status.chooseDestination".localized
            return
        }

        if isChangingDestination {
            guard let baseStation = lastPassedStation ?? startStation else {
                statusText = "trip.error.unknownLastStation".localized
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
                    format: "status.alreadyAtDestination".localized,
                    dest.name
                )

                isTracking = false
                notificationManager.cancelTripNotifications()
                return
            }

            tripDirection = dest.order > baseStation.order ? .forward : .backward

            isTracking = true
            showArrivalSheet = false
            didFireApproachingAlert = false
            didFireArrivalAlert = false
            statusText = ""
            isChangingDestination = false

            let fakeLocation = CLLocation(latitude: baseStation.coordinate.latitude,
                                          longitude: baseStation.coordinate.longitude)

            notificationManager.scheduleLocationNotifications(for: dest)
            updateProgress(for: fakeLocation)
            return
        }

        guard let location = userLocation else {
            statusText = "sheet.status.noLocation".localized
            return
        }

        guard let startSt = nearestStation(to: location) else {
            statusText = "trip.error.nearestStationNotFound".localized
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
                format: "status.alreadyAtDestination".localized,
                dest.name
            )

            isTracking = false
            notificationManager.cancelTripNotifications()
            return
        }

        tripDirection = dest.order > startSt.order ? .forward : .backward

        isTracking = true
        showArrivalSheet = false
        didFireApproachingAlert = false
        didFireArrivalAlert = false
        statusText = ""

        notificationManager.scheduleLocationNotifications(for: dest)
        updateProgress(for: location)
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
        guard let start = startStation,
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
            statusText = String(format: "trip.arrived".localized, dest.name)
            isTracking = false
            showArrivalSheet = true
            upcomingStations = []

            if !didFireArrivalAlert {
                activeAlert = .arrival(stationName: dest.name)
                didFireArrivalAlert = true
                notificationManager.cancelTripNotifications()
            }
            return
        }

        statusText = ""

        if !didFireApproachingAlert,
           !didFireArrivalAlert,
           distanceToDest <= approachingDistance,
           distanceToDest > arrivalDistance {

            activeAlert = .approaching(
                stationName: dest.name,
                etaMinutes: etaMinutes
            )
            didFireApproachingAlert = true
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

    var correctTerminalName: String? {
        guard let start = startStation,
              let dest = selectedDestination else { return nil }

        if dest.order > start.order {
            return stations.max(by: { $0.order < $1.order })?.name
        } else if dest.order < start.order {
            return stations.min(by: { $0.order < $1.order })?.name
        } else {
            return nil
        }
    }
}
