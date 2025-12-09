import SwiftUI
import MapKit
import _MapKit_SwiftUI

struct MainView: View {
    
    @StateObject var vm = MapViewModel()
    
    @StateObject private var metroVM = MetroTripViewModel(
        stations: MetroData.yellowLineStations
    )
    @StateObject private var locationManager = LocationManager()
    @StateObject private var permissionsVM = PermissionsViewModel()
    
    @StateObject private var alertManager = InAppAlertManager()
    
    @State private var showStationSheet: Bool  = false
    @State private var showTrackingSheet: Bool = false
    @State private var showArrivalSheet: Bool  = false
    
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        ZStack {
            
            // MARK: - Map
            Map(position: $vm.mapCamera) {
                
                UserAnnotation()
                
                if let selectedName = vm.selectedLineName,
                   let topLine = vm.allRoutePolylines.first(where: { $0.name == selectedName }) {
                    MapPolyline(points: topLine.points)
                        .stroke(.yellow, lineWidth: 6)
                }
                
                ForEach(vm.stations) { station in
                    Annotation(station.name, coordinate: station.coordinate) {
                        ZStack {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 18, height: 18)
                                .shadow(radius: 3)
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                                .shadow(radius: 3)
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
                
                Button(action: {
                    showStationSheet = true
                }) {
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
        
        // MARK: - Station Sheet
        .sheet(isPresented: $showStationSheet) {
            StationSheetView(
                metroVM: metroVM,
                permissionsVM: permissionsVM,
                showSheet: $showStationSheet,
                getCurrentLocation: { locationManager.userLocation }
            )
            .presentationDetents([.height(400), .large])
            .presentationDragIndicator(.hidden)
        }
        
        // MARK: - Tracking Sheet
        .sheet(isPresented: $showTrackingSheet) {
            TrackingSheet(
                ShowStationSheet: $showStationSheet,
                isPresented: $showArrivalSheet,
                metroVM: metroVM
            )
            .presentationDetents([.height(460), .height(550)])
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(true)
        }
        
        // MARK: - Arrival Sheet
        .sheet(isPresented: $showArrivalSheet) {
            ArrivedSheet(isPresented: $showArrivalSheet)
                .presentationDetents([.height(500), .height(500)])
                .presentationDragIndicator(.hidden)
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
        }
        .onChange(of: metroVM.showArrivalSheet) { arrived in
            if arrived {
                showTrackingSheet = false
                showArrivalSheet = true
            }
        }
        .onChange(of: metroVM.activeAlert) { alert in
            guard let alert = alert else { return }
            
            switch alert {
            case .approaching(let name, _):
                let message = String(
                    format: "alert.approaching".localized,
                    name
                )
                alertManager.showApproaching(message: message)
                
            case .arrival(let name):
                let message = String(
                    format: "alert.arrived".localized,
                    name
                )
                alertManager.showArrival(message: message)
            }
            
            DispatchQueue.main.async {
                metroVM.clearActiveAlert()
            }
        }
        // Alerts
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
                Image(
                    alertManager.isArrival
                    ? (scheme == .dark ? "ArrivedDark" : "ArrivedLight")
                    : (scheme == .dark ? "NearbyDark"  : "NearbyLight")
                )
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
        .background(Color.mainGreen)
        .cornerRadius(16)
    }
}

#Preview {
    MainView()
}
