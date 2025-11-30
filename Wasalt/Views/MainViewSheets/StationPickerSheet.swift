//
//  StationPickerSheet.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//

import SwiftUI

struct StationSheet: View {
    
    @Binding var isPresented: Bool
    @Binding var selectedStation: String?
    
    let stations = [
        "المركز المالي",
        "الربيع",
        "طريق عثمان بن عفان",
        "سابك",
        "جامعة الاميرة نوره 1",
        "جامعة الاميرة نوره 2"
    ]
    
    // ألوان الوضع الليلي والنهاري
    var sheetBackground: Color {
        Color(UIColor { trait in
            return trait.userInterfaceStyle == .dark ? .black : .white
        })
    }
    
    var stationColor: Color {
        Color(UIColor { trait in
            return trait.userInterfaceStyle == .dark ?
                UIColor(hex: "#ACCF71") :
                UIColor(hex: "#87986B")
        })
    }
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            // خط السحب
            Rectangle()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))
                .cornerRadius(3)
                .padding(.top, 8)
            
            Text("أهلاً 👋 وين ودك تروح ؟")
                .font(.headline)
                .padding(.top, 5)
            
            ScrollView {
                VStack(spacing: 12) {
                    
                    ForEach(stations, id: \.self) { station in
                        
                        Button(action: {
                            selectedStation = station
                        }) {
                            HStack {
                                Text(station)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                                    .background(
                                        Circle()
                                            .fill(selectedStation == station ? Color.black : Color.clear)
                                    )
                                    .frame(width: 22, height: 22)
                            }
                            .padding()
                            .background(stationColor)
                            .cornerRadius(14)
                        }
                        
                    }
                }
                .padding(.horizontal)
            }
            
            Button(action: {
                isPresented = false
            }) {
                Text("ابدأ الرحلة")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor(hex: "#6D744E")))
                    .cornerRadius(14)
            }
            .padding(.horizontal)
            .padding(.bottom, 15)
            
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.55)
        .background(sheetBackground)
        .cornerRadius(20)
    }
}

// MARK: - Preview
struct StationSheet_Previews: PreviewProvider {
    
    struct Wrapper: View {
        @State var show = true
        @State var selected: String? = nil
        
        var body: some View {
            StationSheet(isPresented: $show, selectedStation: $selected)
                .preferredColorScheme(.dark)  // جربي: .light
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}

// MARK: - UIColor HEX Extension
extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgbValue & 0x0000FF) / 255
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
