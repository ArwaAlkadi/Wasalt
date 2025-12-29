//
//  MetroLinesSheet.swift
//  Wasalt
//

import SwiftUI
import CoreLocation

struct MetroLinesSheet: View {

    @Binding var showSheet: Bool
    @Binding var showTrackingSheet: Bool

    @State private var selectedLine: MetroLine? = nil

    @ObservedObject var metroVM: MetroTripViewModel
    @ObservedObject var permissionsVM: PermissionsViewModel

    let getCurrentLocation: () -> CLLocation?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                Text("metroLines.header".localized)
                    .font(.title2.bold())
                    .padding(.top, 20)
                    .foregroundColor(.white)

                // MARK: - Metro Lines List
                ForEach(MetroLine.allCases) { line in
                    Button {
                        selectedLine = line
                        metroVM.filterStations(for: line)
                    } label: {
                        HStack {
                            Circle()
                                .fill(line.color)
                                .frame(width: 20, height: 20)

                            Text(line.displayName)
                                .foregroundColor(.black)

                            Spacer()
                        }
                        .padding()
                        .background(Color.stationGreen1)
                        .cornerRadius(12)
                    }
                }

                Spacer()
            }
            .padding()
            .background(Color.stationGreen2)
            .cornerRadius(20)

            // MARK: - Navigation to Stations
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
                        line: line               // ✅ FIX IS HERE
                    )
                    .background(Color.stationGreen2)
                }
            }
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
