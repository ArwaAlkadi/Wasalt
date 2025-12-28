import SwiftUI
import MapKit
import _MapKit_SwiftUI

struct MainView: View {

    @StateObject var vm = MapViewModel()

    @StateObject private var locationManager: LocationManager
    @StateObject private var metroVM: MetroTripViewModel

    @StateObject private var permissionsVM = PermissionsViewModel()
    @StateObject private var alertManager = InAppAlertManager()

    @State private var showLineSheet: Bool = false // <-- New
    @State private var showTrackingSheet: Bool = false
    @State private var showArrivalSheet: Bool = false

    @Environment(\.colorScheme) var scheme

    init() {
        let lm = LocationManager()
        _locationManager = StateObject(wrappedValue: lm)
        _metroVM = StateObject(wrappedValue: MetroTripViewModel(
            stations: MetroData.yellowLineStations,
            locationManager: lm
        ))
    }

    var body: some View {
        ZStack {
            // MARK: - Map
            Map(position: $vm.mapCamera) {
                UserAnnotation()

                ForEach(vm.allRoutePolylines.indices, id: \.self) { index in
                    let route = vm.allRoutePolylines[index]
                    MapPolyline(points: route.points)
                        .stroke(route.line.color, lineWidth: 4)
                }

                ForEach(vm.stations) { station in
                    Annotation(station.name, coordinate: station.coordinate) {
                        ZStack {
                            Circle()
                                .fill(stationLineColor(station))
                                .frame(width: 18, height: 18)
                            Circle()
                                .fill(.white)
                                .frame(width: 7, height: 7)
                        }
                    }
                }
            }
            .ignoresSafeArea()

            VStack {
                if alertManager.isShowingBanner {
                    bannerView
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 8)
                }

                Spacer()

                // MARK: - Choose Line Button
                Button {
                    showLineSheet = true
                } label: {
                    Text("main.chooseDestination".localized)
                        .font(.title3.bold())
                        .foregroundColor(Color.whiteBlack)
                        .frame(width: 220, height: 25)
                        .padding(.vertical, 15)
                        .background(Color.mainGreen)
                        .cornerRadius(25)
                        .glassEffect(.clear.tint(Color.mainGreen))
                }
                .padding(.bottom, 15)
            }
            .padding(.horizontal)
        }
        // MARK: - Metro Lines Sheet
        .sheet(isPresented: $showLineSheet) {
            MetroLinesSheet(
                showSheet: $showLineSheet,
                metroVM: metroVM,
                permissionsVM: permissionsVM,
                getCurrentLocation: { locationManager.userLocation }
            )
            .presentationDetents([.height(400), .large])
            .presentationDragIndicator(.hidden)
            .presentationBackgroundInteraction(.enabled)
        }

        // MARK: - Tracking & Arrival Sheets (unchanged)
        .sheet(isPresented: $showTrackingSheet) {
            TrackingSheet(
                ShowStationSheet: $showStationSheet,
                isPresented: $showTrackingSheet,
                metroVM: metroVM
            )
            .presentationDetents([.height(460), .height(550)])
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(true)
            .presentationBackgroundInteraction(.enabled)
        }

        .sheet(isPresented: $showArrivalSheet) {
            ArrivedSheet(isPresented: $showArrivalSheet)
                .presentationDetents([.height(500), .height(500)])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(true)
                .presentationBackgroundInteraction(.enabled)
        }

        // MARK: - Logic
        .onAppear {
            permissionsVM.refreshPermissions()
            locationManager.requestPermission()
            locationManager.start()
        }

        .onChange(of: locationManager.userLocation) { newLoc in
            metroVM.userLocationUpdated(newLoc)
        }

        .onChange(of: metroVM.isTracking) { isTracking in
            showTrackingSheet = isTracking

            if isTracking,
               let start = metroVM.startStation,
               let dest = metroVM.selectedDestination {

                locationManager.startTripGeofences(
                    start: start,
                    destination: dest,
                    allStations: MetroData.yellowLineStations
                )

            } else {
                locationManager.stopTripGeofences()
            }
        }

        .onChange(of: metroVM.showArrivalSheet) { arrived in
            if arrived {
                showTrackingSheet = false
                showArrivalSheet = true
            }
        }

        .onChange(of: locationManager.wrongDirectionTriggered) { fired in
            guard fired else { return }
            metroVM.activeAlert = .wrongDirection
            locationManager.wrongDirectionTriggered = false
        }

        .onChange(of: metroVM.activeAlert) { alert in
            guard let alert = alert else { return }

            switch alert {
            case .approaching(let name, _):
                let message = String(format: "alert.approaching".localized, name)
                alertManager.showApproaching(message: message)
            case .arrival(let name):
                let message = String(format: "alert.arrived".localized, name)
                alertManager.showArrival(message: message)
            case .wrongDirection:
                let terminal = metroVM.correctTerminalName ?? ""
                let msg = terminal.isEmpty
                    ? "alert.wrongDirection.body.noTerminal".localized
                    : String(format: "alert.wrongDirection.body.withTerminal".localized, terminal)
                alertManager.showWrongDirection(message: msg)
            }

            DispatchQueue.main.async {
                metroVM.clearActiveAlert()
            }
        }

        //  هنا UI تعرف إن الرحلة انتهت وتسكر TrackingSheet
        .onReceive(locationManager.$tripExpired) { expired in
            guard expired else { return }

            metroVM.endTripAndReset()

            showTrackingSheet = false
            showArrivalSheet = false
            showStationSheet = true

            locationManager.tripExpired = false
        }

        // MARK: - Permission Alerts
        .alert("permission.location.title".localized,
               isPresented: $permissionsVM.showLocationSettingsAlert) {
            Button("permission.openSettings".localized) {
                permissionsVM.openAppSettings()
            }
            Button("cancel".localized, role: .cancel) { }
        } message: {
            Text("permission.location.message".localized)
        }

        .alert("permission.notifications.title".localized,
               isPresented: $permissionsVM.showNotificationSettingsAlert) {
            Button("permission.openSettings".localized) {
                permissionsVM.openAppSettings()
            }
            Button("cancel".localized, role: .cancel) { }
        } message: {
            Text("permission.notifications.message".localized)
        }
    }

    // MARK: - Banner View
    private var bannerView: some View {
        HStack {
            HStack {
                Image(bannerIconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                Text(alertManager.bannerMessage)
                    .font(.subheadline.bold())
                    .foregroundStyle(.whiteBlack)
            }
            Spacer()
            Button {
                alertManager.dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.whiteBlack)
            }
        }
        .frame(width: 350, height: 60)
        .padding()
        .background(.mainGreen)
        .cornerRadius(16)
    }

    private var bannerIconName: String {
        switch alertManager.bannerType {
        case .arrival:
            return scheme == .dark ? "ArrivedDark" : "ArrivedLight"

        case .approaching:
            return scheme == .dark ? "NearbyDark" : "NearbyLight"

        case .wrongDirection:
            return scheme == .dark ?  "warning" : "warning-2"
        }
    }

    func stationLineColor(_ station: Station) -> Color {
        for line in MetroLine.allCases {
            if line.stations.contains(where: { $0.id == station.id }) {
                return line.color
            }
        }
        return .gray
    }
}


#Preview {
    MainView()
}
