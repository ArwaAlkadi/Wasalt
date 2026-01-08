//
//  TrackingSheet.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//

import SwiftUI
import CoreLocation

struct TrackingSheet: View {

    @Binding var showLineSheet: Bool
    @Binding var isPresented: Bool

    @Environment(\.colorScheme) var scheme

    @ObservedObject var metroVM: MetroTripViewModel

    var body: some View {
        ZStack {
            Color.whiteBlack
                .ignoresSafeArea()

            VStack(spacing: 10) {

                // MARK: - ETA Header
                HStack {
                    Image(systemName: "clock")
                        .font(.title3.bold())
                        .padding(.vertical, 15)

                    //  UI tweak when ETA is 0
                    Text(etaDisplayText)
                        .font(.title3.bold())
                        .padding(.vertical, 15)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 5) {

                    // MARK: - Start Station
                    HStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.mainGreen)
                                .frame(width: 60, height: 60)

                            Image(scheme == .dark ? "LocationDark" : "LocationLight")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("tracking.start".localized)
                                .foregroundColor(.mainGreen)
                                .font(.body)

                            HStack(spacing: 4) {
                                Text(metroVM.startStation?.name ?? "—")
                                    .font(.body.bold())

                                /// Transform circles
                                if let startStation = metroVM.startStation,
                                   startStation.isTransferStation,
                                   let lines = startStation.transferLines {

                                    HStack(spacing: 2) {
                                        Image(systemName: "arrow.trianglehead.2.clockwise")
                                            .font(.footnote.bold())
                                        
                                        ForEach(lines, id: \.self) { transferLine in
                                            Image(systemName: "circlebadge.fill")
                                                .foregroundStyle(transferLine.color)
                                                .font(.body.bold())
                                                .padding(.horizontal, 0.5)
                                        }
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.gray.opacity(0.5))
                                    )
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    ScrollView {

                        // MARK: - Simple line if no middle stations
                        if metroVM.middleStations.isEmpty {
                            HStack {
                                Rectangle()
                                    .fill(Color.mainGreen)
                                    .frame(width: 3, height: 40)
                                    .padding(.leading, 48)
                                Spacer()
                            }
                        }

                        // MARK: - Middle Stations
                        if !metroVM.middleStations.isEmpty {
                            ZStack(alignment: .leading) {
                                VStack(spacing: 12) {
                                    ForEach(metroVM.middleStations) { station in
                                        HStack(spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .foregroundStyle(.mainGreen)
                                                    .frame(width: 25, height: 25)
                                                    .overlay {
                                                        Circle()
                                                            .frame(width: 7, height: 7)
                                                            .foregroundStyle(.whiteBlack)
                                                    }

                                                if metroVM.isStationReached(station) {
                                                    Circle()
                                                        .fill(Color.mainGreen)
                                                        .frame(width: 25, height: 25)
                                                        .overlay {
                                                            Image(systemName: "checkmark")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 13, height: 13)
                                                                .foregroundStyle(.whiteBlack)
                                                                .bold()
                                                        }
                                                }
                                            }

                                            VStack(alignment: .leading, spacing: 2) {
                                                HStack(spacing: 4) {

                                                    Text(station.name)
                                                        .font(.footnote)

                                                    /// Transform circles
                                                    if station.isTransferStation,
                                                       let lines = station.transferLines {

                                                        HStack(spacing: 2) {
                                                            Image(systemName: "arrow.trianglehead.2.clockwise")
                                                                .font(.footnote)
                                                            
                                                            ForEach(lines, id: \.self) { transferLine in
                                                                Image(systemName: "circlebadge.fill")
                                                                    .foregroundStyle(transferLine.color)
                                                                    .font(.footnote)
                                                                    .padding(.horizontal, 0.5)
                                                            }
                                                        }
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 3)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 20)
                                                                .fill(Color.gray.opacity(0.5))
                                                        )
                                                    }
                                                }
                                            }

                                            Spacer()
                                        }
                                        .padding(.leading, 37)
                                    }
                                }
                                .padding(.vertical, 12)
                            }
                        }

                        // MARK: - Destination
                        HStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(Color.mainGreen)
                                    .frame(width: 60, height: 60)

                                Image(scheme == .dark ? "LocationDark" : "LocationLight")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("tracking.destination".localized)
                                    .foregroundColor(.mainGreen)
                                    .font(.body)

                                HStack(spacing: 4) {
                                    Text(metroVM.selectedDestination?.name ?? "—")
                                        .font(.body.bold())

                                    /// Transform circles
                                    if let destination = metroVM.selectedDestination,
                                       destination.isTransferStation,
                                       let lines = destination.transferLines {

                                        HStack(spacing: 2) {
                                            Image(systemName: "arrow.trianglehead.2.clockwise")
                                                .font(.footnote.bold())
                                            
                                            ForEach(lines, id: \.self) { transferLine in
                                                Image(systemName: "circlebadge.fill")
                                                    .foregroundStyle(transferLine.color)
                                                    .font(.body.bold())
                                                    .padding(.horizontal, 0.5)
                                            }
                                        }
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.gray.opacity(0.5))
                                        )
                                    }
                                }
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    }

                    Spacer()
                }

                // MARK: - Buttons
                HStack {
                    Button(action: {
                        metroVM.endTripAndReset()
                        isPresented = false
                    }) {
                        Text("tracking.endTrip".localized)
                            .font(.body.bold())
                            .foregroundColor(.white)
                            .frame(width: 175, height: 25)
                            .padding(.vertical, 15)
                            .background(Color.red.opacity(0.9))
                            .cornerRadius(25)
                    }
                    .padding(.vertical, 15)

                    Button(action: {
                        metroVM.cancelAndChooseAgain()
                        isPresented = false
                        showLineSheet = true
                    }) {
                        Text("tracking.change".localized)
                            .font(.body.bold())
                            .foregroundColor(.whiteBlack)
                            .frame(width: 175, height: 25)
                            .padding(.vertical, 15)
                            .background(Color.mainGreen)
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
    }

    // MARK: - ETA Text
    private var etaDisplayText: String {
        if metroVM.stationsRemaining == 1 { return "tracking.nextStation".localized }
        if metroVM.etaMinutes == 0 { return "tracking.nearDestination".localized }
        return String(format: "tracking.eta".localized, "\(metroVM.etaMinutes)")
    }
}

#Preview {
    let stations = MetroData.yellowLineStations
    let mockVM = MetroTripViewModel(stations: stations)

    mockVM.startStation = stations[0]
    mockVM.selectedDestination = stations[1]
    mockVM.currentNearestStation = stations[1]
    mockVM.lastPassedStation = stations[1]
    mockVM.upcomingStations = [
        stations[2],
        stations[3],
        stations[4],
        stations[5]
    ]
    mockVM.etaMinutes = 14

    return TrackingSheet(
        showLineSheet: .constant(false),
        isPresented: .constant(true),
        metroVM: mockVM
    )
}
