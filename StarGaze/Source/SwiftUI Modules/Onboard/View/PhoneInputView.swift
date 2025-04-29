//
//  PhoneInputView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 07/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct PhoneInputView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SigninViewModel
    @State private var loadCountryPicker: Bool = false
    @FocusState private var focusedField: OnboardField?
    
    var body: some View {
        VStack(spacing: 0) {
            navView()
            Spacer()
            
            ScrollViewReader { proxy in
                List {
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
                }
                .listStyle(.plain)
                .onChange(of: focusedField) { newValue in
                    guard let field = newValue
                    else { return }
                    
                    proxy.scrollTo(field)
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
            
            SGRoundRectButton(title: "SAVE") {
                viewModel.saveMobileNumber()
            }
            .disabled(!viewModel.canSubmit)
            .opacity(viewModel.canSubmit ? 1.0 : 0.44)
        }
        .background {
            Color.brand1
                .ignoresSafeArea()
        }
    }
    
    private func navView() -> some View {
        HStack(alignment: .center) {
            Color.clear
                .frame(width: 64, height: 64)
                                    
            Spacer()
            
            Text("Phone Number")
                .foregroundColor(.text1)
                .font(.system(size: 18, weight: .medium))
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image("subscriptionClose")
                    .tint(.text1)
                    
            }
            .frame(width: 64, height: 64)
        }
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
}

struct PhoneInputView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneInputView(viewModel: SigninViewModel())
    }
}
