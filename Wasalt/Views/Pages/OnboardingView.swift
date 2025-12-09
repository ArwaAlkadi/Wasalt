import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.locale) var locale
    
    init(viewModel: OnboardingViewModel = OnboardingViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var isArabic: Bool {
        locale.language.languageCode?.identifier == "ar"
    }
    
    var body: some View {
        Group {
            if viewModel.isOnboardingFinished {
                MainView()
                    .transition(.opacity)
            } else {
                VStack(spacing: 10) {
                    
                    HStack {
                        Spacer()
                        if viewModel.currentPage != viewModel.pages.count - 1 {
                            Button("onboarding.skip".localized) {
                                viewModel.skip()
                            }
                            .padding(.horizontal, 30)
                            .foregroundColor(.mainGreen)
                        }
                    }
                    
                    Spacer()
                    
                    TabView(selection: $viewModel.currentPage) {
                        ForEach(0..<viewModel.pages.count, id: \.self) { index in
                            let page = viewModel.pages[index]
                            let iconName = (colorScheme == .light) ? page.lightIcon : page.darkIcon
                            
                            VStack(spacing: 25) {
                                ZStack {
                                    Circle()
                                        .frame(width: 290, height: 290)
                                        .foregroundColor(.secondGreen)
                                        .opacity(0.2)
                                    
                                    Image(iconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 250)
                                }
                                
                                VStack {
                                    Text(page.title)
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                    Text(page.subtitle)
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                }
                            }
                            .tag(index)
                            .padding(.horizontal, 20)
                            .transition(.slide)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    VStack(spacing: 16) {
                        
                        HStack(spacing: 8) {
                            ForEach(0..<viewModel.pages.count, id: \.self) { dotIndex in
                                if dotIndex == viewModel.currentPage {
                                    Capsule()
                                        .fill(Color.mainGreen)
                                        .frame(width: 50, height: 8)
                                        .animation(.easeInOut, value: viewModel.currentPage)
                                } else {
                                    Circle()
                                        .fill(Color.mainGreen.opacity(0.5))
                                        .frame(width: 10, height: 10)
                                }
                            }
                        }
                        
                        HStack {
                            if viewModel.currentPage == viewModel.pages.count - 1 {
                                Button(action: {
                                    viewModel.next()
                                }) {
                                    Text("onboarding.done".localized)
                                        .font(.title3.bold())
                                        .frame(width: 150, height: 47)
                                        .background(Color(colorScheme == .light ? "GL" : "GD"))
                                        .foregroundColor(colorScheme == .light ? .white : .black)
                                        .cornerRadius(25)
                                }
                            } else {
                                Spacer()
                                Button(action: {
                                    viewModel.next()
                                }) {
                                    Image(systemName: isArabic ? "chevron.left.circle.fill"
                                                               : "chevron.right.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.mainGreen)
                                }
                                .padding(.trailing, 20)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .animation(.easeInOut, value: viewModel.currentPage)
                }
            }
        }
    }
}

#Preview {
    let vm = OnboardingViewModel()
    vm.isOnboardingFinished = false
    return OnboardingView(viewModel: vm)
}
