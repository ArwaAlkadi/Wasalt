//
//  RootAppView.swift
//  Wasalt
//
//  Created by Arwa Alkadi on 19/11/2025.
//

// Determines where the app starts based on the user’s state

import SwiftUI

struct RootAppView: View {

    /// Shows the splash screen only the first time
    @State private var showSplash: Bool = true

    /// Stores whether onboarding has been completed
    @AppStorage("didFinishOnboarding")
    var didFinishOnboarding: Bool = false

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
            // Splash duration
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
