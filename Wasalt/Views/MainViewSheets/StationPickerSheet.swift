
//
//  StationSheetView.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 02/12/2025.
//

import SwiftUI
import CoreLocation

struct StationSheetView: View {
    
    @ObservedObject var metroVM: MetroTripViewModel
    @ObservedObject var permissionsVM: PermissionsViewModel
    
    @Binding var showSheet: Bool
    
    let getCurrentLocation: () -> CLLocation?
    
    let stations: [Station] = MetroData.yellowLineStations
    
    var body: some View {
        VStack {
            VStack(spacing: metroVM.statusText.isEmpty ? 20 : 7) {
                headerSection
                
                if !metroVM.statusText.isEmpty {
                    statusSection
                }
                
                stationsListSection
                
                startButtonSection
            }
            .padding(.horizontal, 16)
            .background(Color.stationGreen2)
            .cornerRadius(20)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Sections

private extension StationSheetView {
    
    var headerSection: some View {
        Text("أهلاً! 👋🏼 وين ودك تروح؟")
            .font(.title2.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.top, 20)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    var statusSection: some View {
        HStack {
            Text(metroVM.statusText)
                .font(.body)
                .foregroundColor(.yellow)
            
            Image(systemName: "exclamationmark.triangle")
                .font(.body)
                .foregroundColor(.yellow)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 30)
        .padding(.bottom, 10)
    }
    
    var stationsListSection: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .trailing) {
                    
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: 3)
                        .padding(.trailing, 33)
                    
                    VStack(spacing: 16) {
                        ForEach(stations) { station in
                            stationRow(for: station)
                        }
                    }
                }
            }
        }
    }
    
    var startButtonSection: some View {
        Button(action: {
            if permissionsVM.areAllPermissionsGranted {
                let location = getCurrentLocation()
                metroVM.startTrip(userLocation: location)

                if metroVM.isTracking {
                    showSheet = false
                }
            } else {
                if !permissionsVM.isLocationAuthorized {
                    permissionsVM.showLocationSettingsAlert = true
                } else if !permissionsVM.isNotificationAuthorized {
                    permissionsVM.showNotificationSettingsAlert = true
                }
            }
        }) {
            Text("ابدأ الرحلة")
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(width: 200, height: 25)
                .padding(.vertical, 15)
                .background(Color.secondGreen)
                .cornerRadius(25)
                .glassEffect(.clear.tint(Color.mainGreen))

        }
        .padding(.bottom, 15)

    }
    
    func stationRow(for station: Station) -> some View {
        ZStack {
            HStack(alignment: .center, spacing: 8) {
                ZStack(alignment: .leading) {
                    Text(station.name)
                        .font(.body)
                        .foregroundColor(.black)
                        .frame(width: 300, height: 35, alignment: .trailing)
                        .padding(.vertical, 15)
                        .padding(.trailing, 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.stationGreen1)
                              
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            metroVM.selectedDestination?.id == station.id
                                            ? Color(UIColor { trait in
                                                trait.userInterfaceStyle == .dark
                                                ? .white
                                                : .black
                                            })
                                            : Color.clear,
                                            lineWidth: 5
                                        )
                                )
                                
                        )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                metroVM.selectDestination(station)
            }
            
            Rectangle()
                .fill(Color.yellow)
                .frame(width: 3)
                .padding(.leading, 290)
            
            Circle()
                .fill(Color.yellow)
                .frame(width: 20, height: 20)
                .padding(.leading, 290)
            
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
                .padding(.leading, 290)
        }
    }
}

#Preview {
    StatefulPreviewWrapper(false) { isPresented in
        StationSheetView(
            metroVM: MetroTripViewModel(stations: MetroData.yellowLineStations),
            permissionsVM: PermissionsViewModel(),
            showSheet: isPresented,
            getCurrentLocation: { nil }
        )
    }
}

