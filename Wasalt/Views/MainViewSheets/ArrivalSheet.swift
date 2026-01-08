//
//  ArrivedSheet.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//

import SwiftUI

struct ArrivedSheet: View {
    
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        
        ZStack {
            
            Color.whiteBlack
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        ZStack {
                            Circle()
                                .foregroundStyle(.mainGreen.opacity(0.5))
                                .frame(width: 30, height: 30)
                                .glassEffect(.clear.tint(Color.secondGreen))
                            
                            Image(systemName: "xmark")
                                .foregroundStyle(.whiteBlack)
                                .font(.title3)
                        }
                    }
                }
                .padding()
                
                ZStack {
                    Circle()
                        .fill(Color.mainGreen)
                        .frame(width: 220, height: 220)
                        .glassEffect(.clear.tint(.green))

                    Image(scheme == .dark ? "MetroDark" : "MetroLight")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                }
                
                Text("arrival.title".localized)
                    .font(.title.bold())
                    .padding()
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("arrival.back".localized)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 200, height: 25)
                        .padding(.vertical, 15)
                        .background(Color.secondGreen)
                        .glassEffect(.clear.tint(.secondGreen))
                        .cornerRadius(25)
                }
                .padding(.bottom, 35)
                
                Spacer()
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    StatefulPreviewWrapper(false) { value in
        ArrivedSheet(isPresented: value)
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
