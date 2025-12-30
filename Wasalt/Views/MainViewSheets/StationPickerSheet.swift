//
//  StationSheetView.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 02/12/2025.
//

import SwiftUI
import CoreLocation

struct StationSheetView: View {

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var metroVM: MetroTripViewModel
    @ObservedObject var permissionsVM: PermissionsViewModel

    @Binding var showSheet: Bool

    let getCurrentLocation: () -> CLLocation?
    let line: MetroLine

    var body: some View {
        VStack {
            VStack(spacing: metroVM.statusText.isEmpty ? 20 : 7) {

                // MARK: Header
                HStack {
                   
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }

                    Text("sheet.header".localized)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.top, 20)
               
               

                // MARK: Status
                if !metroVM.statusText.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.body.bold())
                            .foregroundColor(.red1)

                        Text(metroVM.statusText)
                            .font(.subheadline.bold())
                            .foregroundColor(.red1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                }

                // MARK: Stations List
                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .leading) {

                        // Vertical line
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            Rectangle()
                                .fill(line.color)
                                .frame(width: 3, height: CGFloat(line.stations.count * 80))
                                .padding(.leading, 33.3)
                        }

                        VStack(spacing: 16) {
                            ForEach(line.stations) { station in
                                stationRow(for: station)
                            }
                        }
                    }
                }

                // MARK: Start Trip Button
                Button {
                    permissionsVM.refreshPermissions()

                    if !permissionsVM.isLocationAuthorized {
                        permissionsVM.requestLocationPermission()
                        permissionsVM.showLocationSettingsAlert = true
                        return
                    }

                    if !permissionsVM.isNotificationAuthorized {
                        permissionsVM.requestNotificationPermission()
                        return
                    }

                    let location = getCurrentLocation()
                    metroVM.startTrip(userLocation: location)

                    if metroVM.isTracking {
                        showSheet = false
                    }

                } label: {
                    Text("sheet.startTrip".localized)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 200, height: 29)
                        .padding(.vertical, 15)
                        .background(
                            metroVM.selectedDestination == nil
                            ? Color.clear
                            : Color.secondGreen
                        )
                        .cornerRadius(25)
                        .glassEffect(.clear.tint(.black.opacity(0.2)))
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 16)
            .background(Color.stationGreen2)
            .cornerRadius(20)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Station Row
    private func stationRow(for station: Station) -> some View {
        ZStack {
            HStack(alignment: .center, spacing: 8) {

                Text(station.name)
                    .font(.body)
                    .foregroundColor(.black)
                    .frame(width: 310, height: 40, alignment: .leading)
                    .padding(.vertical, 15)
                    .padding(.leading, 60)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.stationGreen1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        metroVM.selectedDestination?.id == station.id
                                        ? (colorScheme == .dark
                                           ? Color.white.opacity(0.4)
                                           : Color.black.opacity(0.3))
                                        : Color.clear
                                    )
                            )
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        metroVM.selectDestination(station)
                    }
            }
            .frame(maxWidth: .infinity)

            // Line + station dots
            Rectangle()
                .fill(line.color)
                .frame(width: 3)
                .padding(.trailing, 300)

            Circle()
                .fill(line.color)
                .frame(width: 20, height: 20)
                .padding(.trailing, 300)

            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
                .padding(.trailing, 300)
        }
    }
}

#Preview {
    StatefulPreviewWrapper(false) { isPresented in
        StationSheetView(
            metroVM: MetroTripViewModel(stations: MetroData.yellowLineStations),
            permissionsVM: PermissionsViewModel(),
            showSheet: isPresented,
            getCurrentLocation: { nil },
            line: .line4
        )
    }
}
