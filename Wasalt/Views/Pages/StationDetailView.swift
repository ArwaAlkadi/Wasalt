//
//  StationDetailView.swift
//  Wasalt
//
//  Created by Rana Alqubaly on 11/06/1447 AH.
//


import SwiftUI
internal import _LocationEssentials

struct StationDetailView: View {
    let station: Station

    var body: some View {
        VStack(spacing: 20) {
            Text(station.name)
                .font(.largeTitle)
                .bold()

            Text("Lat: \(station.coordinate.latitude)")
            Text("Lon: \(station.coordinate.longitude)")

            Spacer()
        }
        .padding()
    }
}
