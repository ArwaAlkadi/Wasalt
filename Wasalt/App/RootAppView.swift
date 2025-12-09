//
//  RootAppView.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//

// كود يحدد من وين يبدأ التطبيق، بناءً على حالة المستخدم

import SwiftUI

struct RootAppView: View {
    
    // يظهر السبلاش أول مرة فقط
    @State private var showSplash: Bool = true
    
    // نحفظ هل خلص الأونبوردنق ولا لا
    @AppStorage("didFinishOnboarding") var didFinishOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
            } else {
                if didFinishOnboarding {
                    MainView()
                } else {
                    OnboardingView()
                }
            }
        }
        .onAppear {
            // مدة السبلاش
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    RootAppView()
}
