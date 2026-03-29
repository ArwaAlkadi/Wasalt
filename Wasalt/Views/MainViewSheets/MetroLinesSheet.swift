//
//  MetroLinesSheet.swift
//  Wasalt
//

import SwiftUI
import CoreLocation

struct MetroLinesSheet: View {

    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showSheet: Bool
    @Binding var showTrackingSheet: Bool

    @State private var selectedLine: MetroLine? = nil
    @State private var nearestStation: Station? = nil

    @ObservedObject var metroVM: MetroTripViewModel
    @ObservedObject var permissionsVM: PermissionsViewModel

    let getCurrentLocation: () -> CLLocation?

    var body: some View {
        NavigationStack {
            ZStack {

                Color.stationGreen2
                    .ignoresSafeArea()

                VStack(spacing: 16) {

                    HStack {
                        Text("metroLines.header".localized)
                            .font(.title2.bold())
                            .padding(.top, 20)
                            .padding(.horizontal, 10)
                            .foregroundColor(.white)

                        Spacer()
                    }

                    // MARK: - Nearest Station Text
                    if let nearest = nearestStation {
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.white)
                                .font(.body)

                            Text(String(format: "metroLines.nearestStation".localized, nearest.name))
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                    }

                    // MARK: - Lines List
                    ScrollView {
                        ForEach(MetroLine.allCases) { line in
                            Button {
                                selectedLine = line
                                metroVM.filterStations(for: line)
                                metroVM.statusText = ""
                            } label: {
                                HStack {
                                    Circle()
                                        .fill(line.color)
                                        .frame(width: 20, height: 20)

                                    Text(line.displayName)
                                        .foregroundColor(.black)

                                    Spacer()
                                }
                                .frame(height: 40)
                                .padding()
                                .background(Color.stationGreen1)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.stationGreen2)
                .cornerRadius(20)
                .onAppear {
                    updateNearestStation()
                }
                // MARK: - Navigation
                .navigationDestination(
                    isPresented: Binding(
                        get: { selectedLine != nil },
                        set: { if !$0 { selectedLine = nil } }
                    )
                ) {
                    if let line = selectedLine {
                        StationSheetView(
                            metroVM: metroVM,
                            permissionsVM: permissionsVM,
                            showSheet: $showSheet,
                            getCurrentLocation: getCurrentLocation,
                            line: line
                        )
                        .background(Color.stationGreen2)
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private func updateNearestStation() {
        guard let location = getCurrentLocation() else { return }
        nearestStation = MetroData.allStations.min { lhs, rhs in
            let lhsLoc = CLLocation(latitude: lhs.coordinate.latitude, longitude: lhs.coordinate.longitude)
            let rhsLoc = CLLocation(latitude: rhs.coordinate.latitude, longitude: rhs.coordinate.longitude)
            return lhsLoc.distance(from: location) < rhsLoc.distance(from: location)
        }
    }
}

#Preview {
    StatefulPreviewWrapper(false) { value in
        MetroLinesSheet(
            showSheet: value,
            showTrackingSheet: .constant(false),
            metroVM: MetroTripViewModel(stations: MetroData.yellowLineStations),
            permissionsVM: PermissionsViewModel(),
            getCurrentLocation: { nil }
        )
    }
}
