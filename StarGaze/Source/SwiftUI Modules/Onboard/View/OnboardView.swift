//
//  OnboardView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 05/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import SwiftDate

enum OnboardField: Int, Hashable {
    case name, emailAddress, birthDate, phoneNumber, otp
}

struct OnboardView: View {
    @StateObject private var viewModel = OnboardViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focusedField: OnboardField?
    @State private var loadCountryPicker: Bool = false
    
    var body: some View {
        VStack(spacing: .zero) {
            navView()
            
            ScrollViewReader { scrollProxy in
                
//                ScrollView {
//                    nameInputField()
//                    emailAddressField()
//                    dateField()
//                    phoneField()
//
//                    switch viewModel.otpStatus {
//                    case  .unknown:
//                        HStack {
//                            Spacer()
//
//                            Button {
//                                viewModel.requestOTP()
//                            } label: {
//                                Text("Verify Phone Number")
//                                    .foregroundColor(.textFieldTitle)
//                                    .font(.system(size: 14, weight: .medium))
//                                    .underline()
//                            }
//                            .padding()
//
//                            Spacer()
//                        }
//                        .listRowSeparator(.hidden)
//                        .listRowBackground(Color.brand1)
//
//
//                    case .duration(_):
//                        otpInputField()
//
//                        HStack {
//                            Spacer()
//
//                            Button {
//                                viewModel.requestOTP()
//                            } label: {
//                                Text("Resend Verification Code")
//                                    .foregroundColor(.textFieldTitle)
//                                    .font(.system(size: 14, weight: .medium))
//                                    .underline()
//                            }
//                            .padding()
//                            .disabled(!viewModel.allowPinRequest)
//                            Spacer()
//                        }
//                        .listRowSeparator(.hidden)
//                        .listRowBackground(Color.brand1)
//
//                    case .verified:
//                        otpInputField()
//                    }
//
//                    termsView()
//
//                }
                
                List {
                    nameInputField()
                    emailAddressField()
                    dateField()
                    phoneField()

                    switch viewModel.otpStatus {
                    case  .unknown:
                        HStack {
                            Spacer()

                            Button {
                                viewModel.requestOTP()
                            } label: {
                                Text("Verify Phone Number")
                                    .foregroundColor(.textFieldTitle)
                                    .font(.system(size: 14, weight: .medium))
                                    .underline()
                            }
                            .padding()

                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.brand1)


                    case .duration(_):
                        otpInputField()

                        HStack {
                            Spacer()

                            Button {
                                viewModel.requestOTP()
                            } label: {
                                Text("Resend Verification Code")
                                    .foregroundColor(.textFieldTitle)
                                    .font(.system(size: 14, weight: .medium))
                                    .underline()
                            }
                            .padding()
                            .disabled(!viewModel.allowPinRequest)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.brand1)

                    case .verified:
                        otpInputField()
                    }

                    termsView()

                }
                .listStyle(.plain)
                .onChange(of: focusedField) { newValue in
                    guard let field = newValue
                    else { return }
                    
                    scrollProxy.scrollTo(field)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button {
                        self.focusedField = nil
                    } label: {
                        Text("Done")
                            .foregroundColor(.text1)
                            .font(.system(size: 15, weight: .regular))
                    }
                }
            }
            
            bottomView()
            
        }
        .background {
            Color.brand1
                .ignoresSafeArea()
        }
        .onChange(of: viewModel.loading) { newValue in
            if newValue == true {
                SGAlertUtility.showHUD()
            }
            else {
                SGAlertUtility.hidHUD()
            }
        }
        .onChange(of: viewModel.didSignup) { newValue in
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
            Button {
                dismiss()
            } label: {
                Image("navBack")
                    .tint(.text1)
                    .frame(width: 49, height: 44)
            }
            
            Spacer()
            
            Text("login.sign-up.title")
                .foregroundColor(.text1)
                .font(.system(size: 18, weight: .medium))
            
            Spacer()
            
            Color.clear
                .frame(width: 49, height: 44)
        }
        .background {
            Color.brand1
                .ignoresSafeArea(.all, edges: .top)
        }
    }
    
    private func nameInputField() -> some View {
        InputFieldWrapperView(title: NSLocalizedString("onboard.name.title",
                                                       comment: ""))
        {
            ZStack(alignment: .leading) {
                if viewModel.name.isEmpty {
                    Text("field.2.placeholder")
                        .foregroundColor(.text1)
                        .font(.system(size: 19,
                                      weight: .medium))
                        .opacity(0.2)
                }
                TextField("", text: $viewModel.name)
                    .foregroundColor(.text1)
                    .font(.system(size: 19,
                                  weight: .medium))
                    .tint(.text1)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .textInputAutocapitalization(.words)
                    .onSubmit {
                        viewModel.updateInputState()
                        self.focusedField = .emailAddress
                    }
            }
        }
        .id(OnboardField.name)
        .frame(height: 76)
        .listRowInsets(.init(top: 10,
                             leading: 20,
                             bottom: 10,
                             trailing: 20))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.brand1)
    }
    
    private func emailAddressField() -> some View {
        InputFieldWrapperView(title: NSLocalizedString("onboard.email.title",
                                                       comment: ""))
        {
            ZStack(alignment: .leading) {
                if viewModel.email.isEmpty {
                    Text("field.2.placeholder")
                        .foregroundColor(.text1)
                        .font(.system(size: 19,
                                      weight: .medium))
                        .opacity(0.2)
                }
                
                TextField("", text: $viewModel.email)
                    .foregroundColor(.text1)
                    .font(.system(size: 19,
                                  weight: .medium))
                    .tint(.text1)
                    .keyboardType(.emailAddress)
                    .textCase(.lowercase)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .emailAddress)
                    .submitLabel(.next)
                    .onSubmit {
                        viewModel.updateInputState()
                        self.focusedField = .birthDate
                    }
            }
        }
        .id(OnboardField.emailAddress)
        .frame(height: 76)
        .listRowInsets(.init(top: 10,
                             leading: 20,
                             bottom: 10,
                             trailing: 20))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.brand1)
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
    
    private func dateField() -> some View {
        InputFieldWrapperView(title: NSLocalizedString("onboard.dob.title",
                                                       comment: ""))
        {
            ZStack(alignment: .leading) {
                SGBirthDatePickerField(date: $viewModel.birthDate,
                                       maxDate: Date() - 16.years,
                                       textColor: .brand1)
                
                
                if viewModel.birthDate == nil {
                    Text("Pick a date")
                        .foregroundColor(.text1)
                        .font(.system(size: 19,
                                      weight: .medium))
                        .opacity(0.2)
                        .disabled(true)
                }
                
                HStack(alignment: .center,
                       spacing: 7) {
                    if let date = viewModel.birthDate {
                        Text(String(format: "%2d", date.day))
                            .foregroundColor(.text1)
                            .font(.system(size: 19, weight: .medium))
                        
                        Text("-")
                            .foregroundColor(.text1)
                            .font(.system(size: 19, weight: .medium))
                            .opacity(0.3)
                        
                        Text(String(format: "%2d", date.month))
                            .foregroundColor(.text1)
                            .font(.system(size: 19, weight: .medium))
                        
                        Text("-")
                            .foregroundColor(.text1)
                            .font(.system(size: 19, weight: .medium))
                            .opacity(0.3)
                        
                        Text(String(date.year))
                            .foregroundColor(.text1)
                            .font(.system(size: 19, weight: .medium))
                    }
                    
                    Spacer()
                    
                    Text("Optional")
                        .font(.system(size: 14,
                                      weight: .medium))
                        .foregroundColor(.brownGrey)
                        .opacity(0.6)
                }
                       .disabled(true)
                       .padding(.trailing, 25)
            }
        }
        .id(OnboardField.birthDate)
        .frame(height: 76)
        .listRowInsets(.init(top: 10,
                             leading: 20,
                             bottom: 10,
                             trailing: 20))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.brand1)
    }
    
    private func phoneField() -> some View {
        
        InputFieldWrapperView(title: NSLocalizedString("onboard.number.title",
                                                       comment: ""))
        {
            HStack(alignment: .center,
                   spacing: 10) {
                
                countryView()
                    .sheet(isPresented: $loadCountryPicker, content: {
                        CountryPickerViewProxy { choosenCountry in
                            let code = choosenCountry.countryCode
                            self.viewModel.switchCountry(with: code)
                        }
                    })
                    .onTapGesture {
                        self.loadCountryPicker = true
                    }
                
                ZStack(alignment: .leading) {
                    if viewModel.phoneNumber.isEmpty {
                        Text("field.2.placeholder")
                            .foregroundColor(.text1)
                            .font(.system(size: 19,
                                          weight: .medium))
                            .opacity(0.2)
                    }
                    
                    TextField("", text: $viewModel.phoneNumber)
                        .foregroundColor(.text1)
                        .font(.system(size: 19,
                                      weight: .medium))
                        .tint(.text1)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .phoneNumber)
                        .submitLabel(.done)
                        .onChange(of: viewModel.phoneNumber, perform: { newValue in
                            if newValue.count == 10 {
                                self.focusedField = nil
                            }
                        })
                        .onSubmit {
                            viewModel.updateInputState()
                            self.focusedField = nil
                        }
                }
                .padding(.trailing, 26)
            }
        }
        .id(OnboardField.phoneNumber)
        .frame(height: 76)
        .listRowInsets(.init(top: 10,
                             leading: 20,
                             bottom: 10,
                             trailing: 20))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.brand1)
    }
    
    private func otpInputField() -> some View {
        InputFieldWrapperView(title: "Verification Code") {
            HStack {
                OTPView(otpCode: $viewModel.otp,
                        otpCodeLength: 4,
                        textColor: .text1,
                        textSize: 19)
                .frame(width: 154)
                .focused($focusedField, equals: .otp)
                .onChange(of: viewModel.otp) { newValue in
                    if newValue.count == 4 {
                        self.focusedField = nil
                        self.viewModel.verifyPin()
                    }
                }
                .onAppear {
                    switch viewModel.otpStatus {
                    case .verified: break
                    default: self.focusedField = .otp
                    }
                }
                Spacer()
                
                switch viewModel.otpStatus {
                case .unknown: EmptyView()
                case .verified:
                    HStack(spacing: 3) {
                        Image("verifiedCheckmark")
                        
                        Text("Verified")
                            .foregroundColor(.init(uiColor: .init(rgb: 0x299e1b)))
                            .font(.system(size: 14, weight: .regular))
                            .kerning(0.52)
                    }
                    
                case .duration(let duration):
                    Text(
                        duration.toString {
                            $0.maximumUnitCount = 2
                            $0.allowedUnits = [.minute, .second]
                            $0.collapsesLargestUnit = false
                            $0.unitsStyle = .positional
                            $0.zeroFormattingBehavior = .pad
                        }
                    )
                    .foregroundColor(.brownGrey)
                    .font(.system(size: 14, weight: .medium))
                }
            }
            .padding(.trailing, 26)
        }
        .id(OnboardField.otp)
        .frame(height: 76)
        .listRowInsets(.init(top: 10,
                             leading: 20,
                             bottom: 10,
                             trailing: 20))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.brand1)
    }
    
    private func termsView() -> some View {
        HStack(alignment: .top, spacing: 10) {
            CheckBoxView(checked: $viewModel.didAgree)
            
            Text("By Signing up, you agree to the [Terms & Conditions](https://stargaze.ai/terms-and-conditions) & [Privacy Policy](https://stargaze.ai/privacy-policy). You will receive an OTP to verify your phone number. Message & Data rates my apply.")
                .font(.system(size: 14,
                              weight: .medium))
                .foregroundColor(.init(uiColor: .init(rgb: 0x5b6067)))
                .tint(.init(uiColor: .init(rgb: 0xa9aeb5)))
                .multilineTextAlignment(.leading)
                .lineSpacing(10)
        }
        .listRowInsets(.init(top: 10,
                             leading: 20,
                             bottom: 10,
                             trailing: 24))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.brand1)
    }
    
    private func bottomView() -> some View {
        VStack(alignment: .center, spacing: 0) {
            
            Text("Already have an account? [Login](open://sign-in)")
                .foregroundColor(.text1)
                .font(.system(size: 14, weight: .medium))
                .tint(.textFieldTitle)
                .environment(\.openURL, OpenURLAction(handler: { _ in
                    
                    dismiss()
                    
                    return .discarded
                }))
                .padding()
            
            SGRoundRectButton(title: "SIGN UP") {
                viewModel.onboard()
            }
            .disabled(!viewModel.canSubmit)
            .opacity(viewModel.canSubmit ? 1.0 : 0.44)
            .padding(.horizontal, -20)
        }
        .padding(.horizontal, 20)
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView()
    }
}
