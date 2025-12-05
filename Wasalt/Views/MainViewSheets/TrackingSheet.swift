//
//  TrackingSheet.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//

import SwiftUI
import CoreLocation

struct TrackingSheet: View {
    
    @Binding var ShowStationSheet: Bool
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var scheme
    
    @ObservedObject var metroVM: MetroTripViewModel
    
    var body: some View {
        ZStack {
            Color.whiteBlack
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                HStack  {
                    Spacer()
                    
                    Text("الوقت المتوقع للوصول : \(metroVM.etaMinutes) دقيقة")
                        .font(.title3.bold())
                        .padding(.vertical, 15)
                    
                    Image(systemName: "clock")
                        .font(.title3.bold())
                        .padding(.vertical, 15)
                        .padding(.trailing)
                }
                .padding(.top, 25)
                
                VStack(spacing: 5) {
                    
                    HStack (spacing: 20) {
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("البداية")
                                .foregroundColor(.mainGreen)
                                .font(.body)
                            
                            Text(metroVM.startStation?.name ?? "—")
                                .font(.body.bold())
                        }
                        
                        ZStack {
                            Circle()
                                .fill(Color.mainGreen)
                                .frame(width: 60, height: 60)
                            
                            Image(scheme == .dark ? "LocationDark" : "LocationLight")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    }
                    .padding(.trailing, 40)
                    
                    if metroVM.middleStations.isEmpty {
                        Rectangle()
                            .fill(Color.mainGreen)
                            .frame(width: 3, height: 30)
                            .padding(.leading, 265)
                    }
                    
                    if !metroVM.middleStations.isEmpty {
                        ZStack(alignment: .trailing) {
                            VStack(spacing: 12) {
                                ForEach(metroVM.middleStations) { station in
                                    HStack(spacing: 12) {
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(station.name)
                                                .font(.footnote)
                                        }
                                        
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
                                    }
                                    .padding(.trailing, 55)
                                }
                            }
                            .padding(.vertical, 12)
                        }
                    }
                    
                    HStack (spacing: 20) {
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("الوجهة")
                                .foregroundColor(.mainGreen)
                                .font(.body)
                            
                            Text(metroVM.selectedDestination?.name ?? "—")
                                .font(.body.bold())
                        }
                        
                        ZStack {
                            Circle()
                                .fill(Color.mainGreen)
                                .frame(width: 60, height: 60)
                            
                            Image(scheme == .dark ? "LocationDark" : "LocationLight")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    }
                    .padding(.trailing, 40)
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        metroVM.endTripAndReset()
                        isPresented = false
                    }) {
                        Text("إنهاء الرحلة")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(width: 170, height: 25)
                            .padding(.vertical, 15)
                            .background(Color.red.opacity(0.9))
                            .cornerRadius(25)
                    }
                    .padding(.vertical, 15)
                    
                    Button(action: {
                        metroVM.cancelAndChooseAgain()
                        isPresented = false
                        ShowStationSheet = true
                    }) {
                        Text("بغير وجهتي")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(width: 170, height: 25)
                            .padding(.vertical, 15)
                            .background(Color.secondGreen)
                            .cornerRadius(25)
                    }
                }
            }
        }
    }
}

#Preview {
    let stations = MetroData.yellowLineStations
    let mockVM = MetroTripViewModel(stations: stations)
    
    mockVM.startStation = stations[0]
    mockVM.selectedDestination = stations[8]
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
        ShowStationSheet: .constant(false),
        isPresented: .constant(true),
        metroVM: mockVM
    )
}
