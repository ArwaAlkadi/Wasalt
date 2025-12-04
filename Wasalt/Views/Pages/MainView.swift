//
//  MainView.swift
//  Wasalt
//
//  Created by Rana Alqubaly on 11/06/1447 AH.
//

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
                // MARK: - البانر الأخضر داخل التطبيق
                if alertManager.isShowingBanner {
                    bannerView
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 8)
                }
                
                Spacer()
                
                Button(action: {
                    showStationSheet = true
                }) {
                    Text("اختر وجهتك")
                        .font(.title3.bold())
                        .foregroundColor(Color.whiteBlack)
                        .frame(width: 200, height: 25)
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
                isPresented: $showTrackingSheet,
                metroVM: metroVM
            )
            .presentationDetents([.height(330), .height(330)])
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
            permissionsVM.requestLocationPermission()
            permissionsVM.requestNotificationPermission()
            
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
                alertManager.showApproaching(
                    message: "استعد! قربنا من محطتك \(name)"
                )
                
            case .arrival(let name):
                alertManager.showArrival(
                    message: "وصلت محطتك \(name)!"
                )
            }
            
            DispatchQueue.main.async {
                metroVM.clearActiveAlert()
            }
        }
        // Alerts
        .alert("فعّل الموقع", isPresented: $permissionsVM.showLocationSettingsAlert) {
            Button("فتح الإعدادات") {
                permissionsVM.openAppSettings()
            }
            Button("إلغاء", role: .cancel) { }
        } message: {
            Text("نحتاج منك إذن الوصول للموقع قبل تبدأ الرحلة.")
        }
        .alert("فعّل الإشعارات", isPresented: $permissionsVM.showNotificationSettingsAlert) {
            Button("فتح الإعدادات") {
                permissionsVM.openAppSettings()
            }
            Button("إلغاء", role: .cancel) { }
        } message: {
            Text("فعّل الإشعارات عشان ننبهك عند الوصول.")
        }
    }
    
    // MARK: - Banner View
    private var bannerView: some View {
        HStack {
            Button {
                alertManager.dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.whiteBlack)
            }
            
            Spacer()
            
            HStack {
                
                Text(alertManager.bannerMessage)
                    .font(.body.bold())
                    .foregroundStyle(.whiteBlack)
                
                Image(
                    alertManager.isArrival
                    ? (scheme == .dark ? "ArrivedDark" : "ArrivedLight")
                    : (scheme == .dark ? "NearbyDark"  : "NearbyLight")
                )
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
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
