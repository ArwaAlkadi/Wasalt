//
//  TrackingSheet.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//

import SwiftUI
import CoreLocation

struct TrackingSheet: View {

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
                        .padding(.trailing, 25)
                }
                .padding(.top, 25)
                
                VStack(spacing: 0) {
                    
                    HStack (spacing: 20) {
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("البداية")
                                .foregroundColor(Color.mainGreen)
                                .font(.body)
                            
                            Text(metroVM.startStation?.name ?? "—")
                                .font(.body.bold())
                        }
                        
                        ZStack {
                            Circle()
                                .fill(Color.mainGreen)
                                .frame(width: 55, height: 55)
                                .glassEffect(.clear.tint(Color.mainGreen))

                            
                            Image(scheme == .dark ? "LocationDark" : "LocationLight")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height:30)
                        }
                    }
                    .padding(.trailing, 40)
                    
                    HStack(spacing: 6) {
                        Spacer()
                        
                        VStack {
                            ForEach(0..<5) { _ in
                                Rectangle()
                                    .fill(Color.mainGreen)
                                    .frame(width: 4, height: 5)
                            }
                        }
                        .frame(width: 3)
                        .padding(.trailing, 65)
                    }
                    
                    HStack (spacing: 20) {
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("الوجهة")
                                .foregroundColor(Color.mainGreen)
                                .font(.body)
                            
                            Text(metroVM.selectedDestination?.name ?? "—")
                                .font(.body.bold())
                        }
                        
                        ZStack {
                            Circle()
                                .fill(Color.mainGreen)
                                .frame(width: 55, height: 55)
                                .glassEffect(.clear.tint(Color.mainGreen))

                            
                            Image(scheme == .dark ? "LocationDark" : "LocationLight")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height:30)
                        }
                    }
                    .padding(.trailing, 40)
                }
                
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
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(25)
                            .glassEffect(.clear.tint(Color.red))

                    }
                    .padding(.vertical, 15)
                    
                    Button(action: {
                        metroVM.cancelAndChooseAgain()   // نطبق منطق تغيير الوجهة
                        isPresented = false              // نقفل شيت التتبع
                        // بعدين من الـ MainView تقدرين تفتحين شيت اختيار المحطة مرة ثانية
                    }) {
                        Text("بغير وجهتي")
                            .font(.title3.bold())
                            .foregroundColor(.whiteBlack)
                            .frame(width: 170, height: 25)
                            .padding(.vertical, 15)
                            .background(Color.mainGreen)
                            .cornerRadius(25)
                            .glassEffect(.clear.tint(Color.mainGreen))

                    }
                    .padding(.vertical, 15)
                    
                }
               
            }
        }
    }
}

// MARK: - Preview
#Preview {
    StatefulPreviewWrapper(false) { value in
        TrackingSheet(
            isPresented: value,
            metroVM: MetroTripViewModel(stations: MetroData.yellowLineStations)
        )
    }
}

