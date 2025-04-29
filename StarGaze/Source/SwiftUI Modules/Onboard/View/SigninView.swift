//
//  SigninView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 02/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct SigninView: View {
    @StateObject private var viewModel = SigninViewModel()
    @State private var loadSignup: Bool = false
    @State private var loadCountryPicker: Bool = false
    @State private var capturePin: Bool = false
//    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                navView()
                    .frame(height: 44)
                
                
    //
                loginInputView()
                    .padding(.top, 15)
                
                partitionView()
                
                socialLoginView()
                
                Spacer()
                
                NavigationLink("", isActive: $loadSignup) {
                    OnboardView()
                        .navigationBarHidden(true)
                }
                
                signupView()
                
                SGRoundRectButton(title: NSLocalizedString("login.button.title",
                                                           comment: ""))
                {
                    viewModel.login()
                }
                .padding(.horizontal, -20)
            }
//            .hiddenNavigationBarStyle()
            .padding(.horizontal, 20)
            .background {
                Color.brand1
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $viewModel.captureOTP) {
                PinInputView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.capturePhoneNumber, content: {
                PhoneInputView(viewModel: viewModel)
            })
            .onChange(of: viewModel.loading) { newValue in
                if newValue == true {
                    SGAlertUtility.showHUD()
                }
                else {
                    SGAlertUtility.hidHUD()
                }
            }
        }
        .onChange(of: viewModel.didLogin) { newValue in
            if newValue {
                let homeVC = UIHostingController(rootView: SideMenuView())
                
                if let scene = UIApplication.shared.connectedScenes.first,
                   let window = (scene as? UIWindowScene)?.keyWindow {
                    window.set(rootViewController: homeVC,
                               options: .init(direction: .toRight,
                                              style: .easeOut)) { _ in
                    }
                }
            }
        }
    }
    
    private func navView() -> some View {
        HStack(alignment: .center) {
//            Button {
//                dismiss()
//            } label: {
//                Image("navBack")
//                    .tint(.text1)
//                    .frame(width: 49, height: 44)
//            }
            
            Spacer()
            
            Text("login.title")
                .foregroundColor(.text1)
                .font(.system(size: 18, weight: .medium))
            
            Spacer()
        }
        .background {
            Color.brand1
                .ignoresSafeArea(.all, edges: .top)
        }
    }
    
    private func loginInputView() -> some View {
        InputFieldWrapperView(title: NSLocalizedString("login.input.title", comment: "")) {
            
            HStack(alignment: .center, spacing: 10) {
                if viewModel.isMobileNumber {
                    countryView()
                        .transition(.slide)
                        .animation(.default, value: viewModel.isMobileNumber)
                        .sheet(isPresented: $loadCountryPicker, content: {
                            CountryPickerViewProxy { choosenCountry in
                                let code = choosenCountry.countryCode
                                self.viewModel.switchCountry(with: code)
                            }
                        })
                        .onTapGesture {
                            self.loadCountryPicker = true
                        }
                }
                
                ZStack(alignment: .leading) {
                    if viewModel.input.isEmpty {
                        Text("login.placeholder.title")
                            .foregroundColor(.text1)
                            .font(.system(size: 19,
                                          weight: .medium))
                            .opacity(0.2)
                    }
                    
                    TextField("", text: $viewModel.input)
                        .foregroundColor(.text1)
                        .font(.system(size: 19,
                                      weight: .medium))
                        .tint(.text1)
                        .focused(viewModel.$inputFocussed)
                        .keyboardType(.emailAddress)
                        .textCase(.lowercase)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .onSubmit {
                            viewModel.inputFocussed = false
                        }
                }
            }
        }
        .frame(height: 76)
        
        
//        ZStack(alignment: .topLeading) {
//            Text("login.input.title")
//                .foregroundColor(.textFieldTitle)
//                .font(.system(size: 14, weight: .medium))
//                .frame(height: 16)
//                .padding(.horizontal, 10)
//                .background {
//                    Color.brand1
//                }
//                .padding(.leading, 16)
//                .zIndex(1)
//
//
//            ZStack(alignment: .leading) {
//                Text("")
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color.textFieldBorder)
//                    .cornerRadius(10, corners: [.topLeft, .topRight])
//                    .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
//
//                ZStack(alignment: .leading) {
//                    if viewModel.input.isEmpty {
//                        Text("login.placeholder.title")
//                            .foregroundColor(.text1)
//                            .font(.system(size: 19,
//                                          weight: .medium))
//                            .opacity(0.2)
//                    }
//
//                    TextField("", text: $viewModel.input)
//                        .foregroundColor(.text1)
//                        .font(.system(size: 19,
//                                      weight: .medium))
//                        .tint(.text1)
//                        .focused(viewModel.$inputFocussed)
//                        .onSubmit {
//                            viewModel.inputFocussed = false
//                        }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .padding(.leading, 24)
//                .background(Color.brand1)
//                .cornerRadius(10, corners: [.topLeft, .topRight])
//                .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
//                .padding(1)
//            }
//            .padding(.top, 9)
//
////            .frame(maxWidth: .infinity, maxHeight: .infinity)
////            .padding(1)
////            .cornerRadius(10, corners: [.topLeft, .topRight])
////            .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
//        }
        
    }
    
    @ViewBuilder
    private func countryView() -> some View {
        if let country = viewModel.country {
            HStack(alignment: .center,
                   spacing: 10) {
                Image(uiImage: country.flagImage ?? UIImage())
                    .resizable()
                    .frame(width: 25,
                           height: 19)
                    .aspectRatio(contentMode: .fit)
                
                Text("+\(country.phoneCode!)")
                    .foregroundColor(.text1)
                    .font(.system(size: 19,
                                  weight: .medium))
                
                Image("dropArrow")
            }
        }
        else {
            EmptyView()
        }
    }
    
    private func partitionView() -> some View {
        ZStack {
            Divider()
                .tint(.commentFieldBorder)
                .frame(height: 1)
//                .opacity(0.6)
            
            Text("login.or.title")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.text1)
                .opacity(0.5)
                .frame(height: 22)
                .padding(.horizontal, 4)
                .background {
                    Color.brand1
                }
        }
        .padding(.vertical, 30)
        
    }
    
    private func socialLoginView() -> some View {
        VStack(spacing: 20) {
            appleLoginView()
            googleLoginView()
            
//            facebookLoginView()
        }
    }
    
    private func facebookLoginView() -> some View {
        Button {
            viewModel.facebookLogin()
        } label: {
            ZStack(alignment: .center) {
                HStack {
                    Image("facebookLogin")
                    Spacer()
                }
                .padding(.leading, 26)
                
                Text("login.facebook.title")
                    .foregroundColor(.text1)
                    .font(.system(size: 17,
                                  weight: .regular))
            }
            .frame(height: 58)
            .background {
                Capsule()
                    .stroke(Color.textFieldBorder,
                            lineWidth: 1)
            }
        }
    }
    
    private func appleLoginView() -> some View {
        Button {
            viewModel.appleLogin()
        } label: {
            ZStack(alignment: .center) {
                HStack {
                    Image("appleLogin")
                        .renderingMode(.template)
                        .tint(.text1)
                    
                    Spacer()
                }
                .padding(.leading, 26)
                
                Text("login.apple.title")
                    .foregroundColor(.text1)
                    .font(.system(size: 17,
                                  weight: .regular))
            }
            .frame(height: 58)
            .background {
                Capsule()
                    .stroke(Color.textFieldBorder,
                            lineWidth: 1)
            }
        }
    }
    
    private func googleLoginView() -> some View {
        Button {
            viewModel.googleLogin()
        } label: {
            ZStack(alignment: .center) {
                HStack {
                    Image("googleLogin")
                    Spacer()
                }
                .padding(.leading, 26)
                
                Text("login.google.title")
                    .foregroundColor(.text1)
                    .font(.system(size: 17,
                                  weight: .regular))
            }
            .frame(height: 58)
            .background {
                Capsule()
                    .stroke(Color.textFieldBorder,
                            lineWidth: 1)
            }
        }
    }
    
    private func signupView() -> some View {
        HStack(alignment: .center,
               spacing: 0) {
            Text("login.create-account.text")
                .foregroundColor(.text1)
                .font(.system(size: 14,
                              weight: .medium))
            
            Button {
                self.loadSignup = true
            } label: {
                Text("login.sign-up.title")
                    .foregroundColor(.brand2)
                    .font(.system(size: 14,
                                  weight: .medium))
            }
            .padding(3)
        }
    }
}

struct SigninView_Previews: PreviewProvider {
    static var previews: some View {
        SigninView()
    }
}
