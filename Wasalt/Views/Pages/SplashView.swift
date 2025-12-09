import SwiftUI

struct SplashView: View {

    @StateObject private var viewModel = SplashViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.locale) var locale
    
    private var isArabic: Bool {
        locale.language.languageCode?.identifier == "ar"
    }
    
    private var iconName: String {
        colorScheme == .dark ? "icon Dark" : "icon"
    }
    
    private var textName: String {
        if colorScheme == .dark {
            return isArabic ? "wasaltDark" : "wasaltDarkEn"
        } else {
            return isArabic ? "wasalt" : "wasaltEn"
        }
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 1) {
                
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .opacity(viewModel.showLogo ? 1 : 0)
                    .offset(
                        x: viewModel.shake ? -10 : (viewModel.moveLeftDown ? -21 : 0),
                        y: viewModel.moveLeftDown ? -2 : 0
                    )
                    .animation(
                        viewModel.shake
                        ? Animation.linear(duration: 0.1).repeatCount(4, autoreverses: true)
                        : .default,
                        value: viewModel.shake
                    )
                    .padding(.leading, 85)
                    .padding(.vertical, 5)

                if viewModel.showText {
                    Image(textName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
