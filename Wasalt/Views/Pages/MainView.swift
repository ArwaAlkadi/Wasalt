//
//  MainView 2.swift
//  Wasalt
//
//  Created by Rana Alqubaly on 11/06/1447 AH.
//


import SwiftUI
import MapKit
import _MapKit_SwiftUI

struct MainView: View {

    @StateObject var vm = MapViewModel()
    @State private var selectedStation: Station?

    var body: some View {
        ZStack {
            // MARK: - Map
            Map(position: $vm.mapCamera) {

                // Draw all lines except the selected line
                ForEach(vm.allRoutePolylines.filter { $0.name != vm.selectedLineName }, id: \.name) { line in
                    MapPolyline(points: line.points)
                        .stroke(.gray, lineWidth: 6)
                }

                // Draw selected line on top
                if let selectedName = vm.selectedLineName,
                   let topLine = vm.allRoutePolylines.first(where: { $0.name == selectedName }) {
                    MapPolyline(points: topLine.points)
                        .stroke(.yellow, lineWidth: 6)
                }

                // Stations as tappable circles
                ForEach(vm.stations) { station in
                    Annotation(station.name, coordinate: station.coordinate) {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 18, height: 18)
                            .shadow(radius: 3)
                            .onTapGesture {
                                selectedStation = station
                                print("Selected: \(station.name)")
                            }
                    }
                }
            }
            .background(Color(.systemBackground))
            .mapStyle(.standard)
            .edgesIgnoringSafeArea(.all)

          
        }
        // MARK: - Optional: show selected station details
        .sheet(item: $selectedStation) { station in
            StationDetailView(station: station)
        }
    }
}

#Preview {
    MainView()
}
