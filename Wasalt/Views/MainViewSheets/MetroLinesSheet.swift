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
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.white)
                                .font(.body)

                            HStack(spacing: 6) {
                                Text(String(format: "metroLines.nearestStation".localized, nearest.name))
                                    .font(.subheadline)
                                    .foregroundColor(.white)

                                let lines = displayLines(for: nearest)

                                /// Transform circles
                                if !lines.isEmpty {
                                    HStack(spacing: 2) {
                                        if lines.count > 1 {
                                            Image(systemName: "arrow.trianglehead.2.clockwise")
                                                .font(.footnote)
                                                .foregroundStyle(.white)
                                        }
                                        
                                            ForEach(lines, id: \.self) { line in
                                                Image(systemName: "circlebadge.fill")
                                                    .foregroundStyle(line.color)
                                                    .font(.body.bold())
                                            }
                                    }
                                    .padding(.horizontal, 3)
                                    .padding(.vertical, 4)
                                    .background(
                                        Group {
                                            if lines.count > 1 {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(
                                                        colorScheme == .dark
                                                        ? Color.gray.opacity(0.5)
                                                        : Color.white.opacity(0.3)
                                                    )
                                            }
                                        }
                                    )
                                }
                            }
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

    private func displayLines(for station: Station) -> [MetroLine] {
        if station.isTransferStation, let lines = station.transferLines, !lines.isEmpty {
            return lines
        }
        return linesForStationByCoordinate(station)
    }

    private func linesForStationByCoordinate(_ station: Station) -> [MetroLine] {
        MetroLine.allCases.filter { line in
            line.stations.contains(where: { isSamePhysicalStation($0, station) })
        }
    }

    private func isSamePhysicalStation(_ a: Station, _ b: Station) -> Bool {
        let aLoc = CLLocation(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude)
        let bLoc = CLLocation(latitude: b.coordinate.latitude, longitude: b.coordinate.longitude)
        return aLoc.distance(from: bLoc) < 25
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
