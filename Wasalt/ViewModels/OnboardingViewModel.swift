import SwiftUI
import Combine

struct OnboardingPage1 {
    let lightIcon: String
    let darkIcon: String
    let title: String
    let subtitle: String
}

class OnboardingViewModel: ObservableObject {

    @Published var currentPage: Int = 0
    
    @AppStorage("didFinishOnboarding") var isOnboardingFinished: Bool = false

    let pages: [OnboardingPage1] = [
        .init(
            lightIcon: "Train",
            darkIcon: "Train Dark",
            title: "onboarding.title1".localized,
            subtitle: "onboarding.subtitle1".localized
        ),
        
        .init(
            lightIcon: "phone",
            darkIcon: "Phone Dark",
            title: "onboarding.title2".localized,
            subtitle: "onboarding.subtitle2".localized
        ),
        
        .init(
            lightIcon: "Map",
            darkIcon: "Map Dark",
            title: "onboarding.title3".localized,
            subtitle: "onboarding.subtitle3".localized
        )
    ]

    func next() {
        withAnimation {
            if currentPage < pages.count - 1 {
                currentPage += 1
            } else {
                isOnboardingFinished = true
            }
        }
    }

    func skip() {
        withAnimation {
            isOnboardingFinished = true
        }
    }
}
