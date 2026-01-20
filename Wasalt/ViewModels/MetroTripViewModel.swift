//
//  MetroTripViewModel.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//

import MapKit
import Combine

// MARK: - Trip Radius
enum TripRadius {
    static let arrival: CLLocationDistance = 250.0
    static let approaching: CLLocationDistance = 500.0
    static let wrongDirection: CLLocationDistance = 500.0
}

// MARK: - MetroTripViewModel → handles trip flow, ETA updates, and arrival logic
final class MetroTripViewModel: ObservableObject {

    // MARK: - Stored Data
    private var allStations: [Station]
    private let notificationManager: LocalNotificationManager
    @Published private(set) var stations: [Station]

    private let locationManager: LocationManager?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Published State
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

    // MARK: - Distance Rules
    private let arrivalDistance: CLLocationDistance = TripRadius.arrival
    private let approachingDistance: CLLocationDistance = TripRadius.approaching

    // MARK: - Trip Direction
    private enum TripDirection { case forward, backward }
    private var tripDirection: TripDirection?

    // MARK: - Alert Flags
    private var didFireApproachingAlert = false
    private var didFireArrivalAlert = false
    private var isChangingDestination: Bool = false

    // MARK: - Wrong Direction Detection
    private var didFireWrongDirectionAlert = false
    private var lastKnownOrder: Int?

    // MARK: - Init
    /// Initializes the trip view model and observes trip expiration from LocationManager
    init(
        stations: [Station],
        notificationManager: LocalNotificationManager = .shared,
        locationManager: LocationManager? = nil
    ) {
        self.notificationManager = notificationManager
        self.locationManager = locationManager
        self.allStations = stations
        self.stations = stations

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

    // MARK: - Line Selection
    /// Filters stations based on the selected metro line
    func filterStations(for line: MetroLine) {
        self.stations = line.stations
        self.allStations = MetroData.allStations
        resetProgress(keepDestination: false)
    }

    /// Sets the selected destination station
    func selectDestination(_ station: Station) {
        selectedDestination = station
    }

    // MARK: - Start Trip
    /// Starts a new trip based on the user’s current location
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
            didFireWrongDirectionAlert = false
            lastKnownOrder = baseStation.order
            statusText = ""
            isChangingDestination = false

            let fakeLocation = CLLocation(
                latitude: baseStation.coordinate.latitude,
                longitude: baseStation.coordinate.longitude
            )

            notificationManager.scheduleLocationNotifications(for: dest)
            updateProgress(for: fakeLocation)
            return
        }

        guard let location = userLocation else {
            statusText = "sheet.status.noLocation".localized
            return
        }

        guard let nearestOverall = nearestStation(to: location, in: allStations) else {
            statusText = "trip.error.nearestStationNotFound".localized
            return
        }

        guard let nearestInLine = nearestStation(to: location, in: stations) else {
            statusText = "trip.error.nearestStationNotFound".localized
            return
        }

        guard isSamePhysicalStation(nearestOverall, nearestInLine) else {
            let suggestedLines = findLinesForStation(nearestOverall)

            if !suggestedLines.isEmpty {
                let separator = "common.or".localized
                let lineNames = suggestedLines
                    .map { $0.displayName }
                    .joined(separator: " \(separator) ")

                statusText = String(
                    format: "trip.error.differentLineWithSuggestion".localized,
                    lineNames
                )
            } else {
                statusText = "trip.error.differentLine".localized
            }

            isTracking = false
            return
        }

        startStation = nearestInLine
        lastPassedStation = nearestInLine
        lastKnownOrder = nearestInLine.order

        if dest.order == nearestInLine.order {
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

        tripDirection = dest.order > nearestInLine.order ? .forward : .backward

        isTracking = true
        showArrivalSheet = false
        didFireApproachingAlert = false
        didFireArrivalAlert = false
        didFireWrongDirectionAlert = false
        statusText = ""

        notificationManager.scheduleLocationNotifications(for: dest)
        updateProgress(for: location)
    }

    // MARK: - Location Updates
    /// Updates trip progress when user location changes
    func userLocationUpdated(_ location: CLLocation?) {
        guard isTracking, let location = location else { return }
        updateProgress(for: location)
    }

    // MARK: - Trip Controls
    /// Ends the trip and resets all trip-related state
    func endTripAndReset() {
        isTracking = false
        resetProgress(keepDestination: false)
        statusText = ""
        notificationManager.cancelTripNotifications()
    }

    /// Cancels the current trip and allows selecting a new destination
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
        didFireWrongDirectionAlert = false
        lastKnownOrder = nil
        activeAlert = nil
        statusText = ""
        isChangingDestination = true
        notificationManager.cancelTripNotifications()
    }

    /// Clears the currently active in-app alert
    func clearActiveAlert() {
        activeAlert = nil
    }

    // MARK: - Stations Between Start and Destination
    /// Returns all stations between the start and destination stations
    var middleStations: [Station] {
        guard let start = startStation,
              let dest = selectedDestination
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

    /// Checks whether a station has already been passed
    func isStationReached(_ station: Station) -> Bool {
        guard let direction = tripDirection else { return false }
        guard let currentOrder = currentNearestStation?.order else { return false }

        switch direction {
        case .forward:
            return station.order <= currentOrder
        case .backward:
            return station.order >= currentOrder
        }
    }

    // MARK: - Progress Updates
    /// Updates ETA, remaining stations, alerts, and arrival state
    private func updateProgress(for location: CLLocation) {
        guard let dest = selectedDestination,
              let nearest = nearestStation(to: location, in: stations) else { return }

        if let current = currentNearestStation, current.order != nearest.order {
            lastPassedStation = current
        }
        currentNearestStation = nearest

        checkWrongDirection(currentOrder: nearest.order)

        let result = computeRemainingStationsAndTime(from: nearest, to: dest)
        stationsRemaining = result.stations
        etaMinutes = result.minutes
        nextStation = result.next
        upcomingStations = computeUpcomingStations(from: nearest, to: dest)

        let destLocation = CLLocation(
            latitude: dest.coordinate.latitude,
            longitude: dest.coordinate.longitude
        )
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

    // MARK: - Wrong Direction Check
    /// Detects whether the user is moving in the wrong direction
    private func checkWrongDirection(currentOrder: Int) {
        guard let direction = tripDirection,
              let lastOrder = lastKnownOrder,
              currentOrder != lastOrder,
              !didFireWrongDirectionAlert else {

            if lastKnownOrder != nil {
                lastKnownOrder = currentOrder
            }
            return
        }

        let isMovingWrong: Bool
        switch direction {
        case .forward:
            isMovingWrong = currentOrder < lastOrder
        case .backward:
            isMovingWrong = currentOrder > lastOrder
        }

        if isMovingWrong {
            activeAlert = .wrongDirection
            didFireWrongDirectionAlert = true
        }

        lastKnownOrder = currentOrder
    }

    // MARK: - Remaining Stations + ETA
    /// Calculates remaining stations, total ETA, and next station
    private func computeRemainingStationsAndTime(
        from current: Station,
        to dest: Station
    ) -> (stations: Int, minutes: Int, next: Station?) {

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
                    totalMinutes += st.minutesToPrevious ?? 0
                    count += 1
                }
            }
        }

        return (count, totalMinutes, next)
    }

    // MARK: - Upcoming Stations
    /// Returns the list of upcoming stations toward the destination
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

    // MARK: - Helpers
    /// Finds the nearest station to the given location
    private func nearestStation(to location: CLLocation, in list: [Station]) -> Station? {
        list.min { lhs, rhs in
            let lhsLoc = CLLocation(latitude: lhs.coordinate.latitude, longitude: lhs.coordinate.longitude)
            let rhsLoc = CLLocation(latitude: rhs.coordinate.latitude, longitude: rhs.coordinate.longitude)
            return lhsLoc.distance(from: location) < rhsLoc.distance(from: location)
        }
    }

    /// Checks whether two stations represent the same physical location
    private func isSamePhysicalStation(_ a: Station, _ b: Station) -> Bool {
        let aLoc = CLLocation(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude)
        let bLoc = CLLocation(latitude: b.coordinate.latitude, longitude: b.coordinate.longitude)
        return aLoc.distance(from: bLoc) < 25
    }

    /// Resets all trip-related state
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
        didFireWrongDirectionAlert = false
        lastKnownOrder = nil
        activeAlert = nil
        isChangingDestination = false
    }

    // MARK: - Terminal Station
    /// Returns the correct terminal station based on trip direction
    var correctTerminalStation: Station? {
        guard let start = startStation,
              let dest = selectedDestination else { return nil }

        if dest.order > start.order {
            return stations.max(by: { $0.order < $1.order })
        } else if dest.order < start.order {
            return stations.min(by: { $0.order < $1.order })
        } else {
            return nil
        }
    }

    // MARK: - Suggested Lines
    /// Finds all metro lines that include the given station
    private func findLinesForStation(_ station: Station) -> [MetroLine] {
        var lines: [MetroLine] = []
        for line in MetroLine.allCases {
            if line.stations.contains(where: { s in
                isSamePhysicalStation(s, station)
            }) {
                lines.append(line)
            }
        }
        return lines
    }
}
