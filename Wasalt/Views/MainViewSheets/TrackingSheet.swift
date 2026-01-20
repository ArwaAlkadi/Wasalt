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
    
    @State private var showingTransferPopover: Bool = false
    @State private var selectedTransferStation: Station? = nil

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

                                /// Transfer Info Button
                                if let startStation = metroVM.startStation,
                                   startStation.isTransferStation,
                                   let lines = startStation.transferLines {
                                    
                                    Button {
                                        selectedTransferStation = startStation
                                        showingTransferPopover = true
                                    } label: {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.callout)
                                            .foregroundStyle(Color.white.opacity(0.9))
                                            .padding(6)
                                            .background(
                                                Circle()
                                                    .fill(Color.gray.opacity(0.5))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .popover(isPresented: Binding(
                                        get: { showingTransferPopover && selectedTransferStation?.order == startStation.order },
                                        set: { if !$0 { showingTransferPopover = false } }
                                    )) {
                                        VStack(spacing: 10) {
                                            Text(String(format: "station.transfer.message".localized, lines.map { $0.displayName }.joined(separator: " \("common.and".localized) ")))
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.center)
                                            
                                            HStack(spacing: 4) {
                                                Image(systemName: "arrow.trianglehead.2.clockwise")
                                                    .font(.caption.bold())
                                                    .foregroundStyle(.primary)
                                                
                                                ForEach(lines, id: \.self) { transferLine in
                                                    Image(systemName: "circlebadge.fill")
                                                        .foregroundStyle(transferLine.color)
                                                        .font(.callout)
                                                }
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.gray.opacity(0.4))
                                            )
                                        }
                                        .padding(12)
                                        .presentationCompactAdaptation(.popover)
                                        .frame(width: 250)
                                    }
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

                                                    /// Transfer Info Button
                                                    if station.isTransferStation,
                                                       let lines = station.transferLines {
                                                        
                                                        Button {
                                                            selectedTransferStation = station
                                                            showingTransferPopover = true
                                                        } label: {
                                                            Image(systemName: "lightbulb.fill")
                                                                .font(.caption2)
                                                                .foregroundStyle(Color.white.opacity(0.9))
                                                                .padding(6)
                                                                .background(
                                                                    Circle()
                                                                        .fill(Color.gray.opacity(0.5))
                                                                )
                                                        }
                                                        .buttonStyle(.plain)
                                                        .popover(isPresented: Binding(
                                                            get: { showingTransferPopover && selectedTransferStation?.order == station.order },
                                                            set: { if !$0 { showingTransferPopover = false } }
                                                        )) {
                                                            VStack(spacing: 10) {
                                                                Text(String(format: "station.transfer.message".localized, lines.map { $0.displayName }.joined(separator: " \("common.and".localized) ")))
                                                                    .font(.caption)
                                                                    .foregroundColor(.primary)
                                                                    .multilineTextAlignment(.center)
                                                                
                                                                HStack(spacing: 4) {
                                                                    Image(systemName: "arrow.trianglehead.2.clockwise")
                                                                        .font(.caption.bold())
                                                                        .foregroundStyle(.primary)
                                                                    
                                                                    ForEach(lines, id: \.self) { transferLine in
                                                                        Image(systemName: "circlebadge.fill")
                                                                            .foregroundStyle(transferLine.color)
                                                                            .font(.callout)
                                                                    }
                                                                }
                                                                .padding(.horizontal, 8)
                                                                .padding(.vertical, 4)
                                                                .background(
                                                                    RoundedRectangle(cornerRadius: 12)
                                                                        .fill(Color.gray.opacity(0.4))
                                                                )
                                                            }
                                                            .padding(12)
                                                            .presentationCompactAdaptation(.popover)
                                                            .frame(width: 250)
                                                        }
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

                                    /// Transfer Info Button
                                    if let destination = metroVM.selectedDestination,
                                       destination.isTransferStation,
                                       let lines = destination.transferLines {
                                        
                                        Button {
                                            selectedTransferStation = destination
                                            showingTransferPopover = true
                                        } label: {
                                            Image(systemName: "lightbulb.fill")
                                                .font(.callout)
                                                .foregroundStyle(Color.white.opacity(0.9))
                                                .padding(6)
                                                .background(
                                                    Circle()
                                                        .fill(Color.gray.opacity(0.5))
                                                )
                                        }
                                        .buttonStyle(.plain)
                                        .popover(isPresented: Binding(
                                            get: { showingTransferPopover && selectedTransferStation?.order == destination.order },
                                            set: { if !$0 { showingTransferPopover = false } }
                                        )) {
                                            VStack(spacing: 10) {
                                                Text(String(format: "station.transfer.message".localized, lines.map { $0.displayName }.joined(separator: " \("common.and".localized) ")))
                                                    .font(.caption)
                                                    .foregroundColor(.primary)
                                                    .multilineTextAlignment(.center)
                                                
                                                HStack(spacing: 4) {
                                                    Image(systemName: "arrow.trianglehead.2.clockwise")
                                                        .font(.caption.bold())
                                                        .foregroundStyle(.primary)
                                                    
                                                    ForEach(lines, id: \.self) { transferLine in
                                                        Image(systemName: "circlebadge.fill")
                                                            .foregroundStyle(transferLine.color)
                                                            .font(.callout)
                                                    }
                                                }
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.gray.opacity(0.4))
                                                )
                                            }
                                            .padding(12)
                                            .presentationCompactAdaptation(.popover)
                                            .frame(width: 250)
                                        }
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
    // if metroVM.stationsRemaining == 1 { return "tracking.nextStation".localized }
        //removed line 369 to fix the logic
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
