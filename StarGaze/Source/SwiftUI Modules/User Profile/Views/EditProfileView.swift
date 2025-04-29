//
//  EditProfileView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 01/07/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher
import CountryKit
import ToastUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    
    @ObservedObject var viewModel: UserViewModel
    @StateObject var editViewModel = EditUserViewModel()
    @ObservedObject var keyboardManager = KeyboardManager()
    
    @State var showImagePicker: Bool = false
    
    private let countryKit = CountryKit()
    
    var body: some View {
        
        ZStack(alignment: .top) {
            VStack {
                Spacer()
                footerView()
            }
            .background(Color.clear)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            VStack(spacing: 0) {
                navView()
                
                ScrollView {
                    VStack(spacing:20) {
                        headerView()
                        
                        nameField()
                        
                        if SGAppSession.shared.user.value?.role == .celebrity {
                            bioField()
                        }
                                                
                        phoneField()
                        emailField()
                        
                        Spacer()
                    }
                }
                .background(
                    Color.brand1
                )
                .cornerRadius(40,
                              corners: [.bottomLeft, .bottomRight])
                .padding(.bottom, keyboardManager.isVisible ? 0 : 40)
                
            }
        }
        .background(Color.brand1)
        .onAppear(perform: {
            UITextField.appearance().tintColor = .text1
            UITextView.appearance().tintColor = .text1
        })
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        isFocused = false
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showImagePicker, content: {
            SGImagePicker(pickedItem: nil,
                          maxItems: 1,
                          types: .photo) { pickedMediaItems in
                
                if let pickedPhoto = pickedMediaItems.first {
                    self.editViewModel.saveMedia(media: pickedPhoto)
                }
            }
        })
//        .toast(isPresented: $editViewModel.storingMedia, content: {
//            LoaderToastView(message: "")
//        })
        .toast(item: $editViewModel.error,
               dismissAfter: 3,
               onDismiss: nil,
               content: { error in
            SGErrorToastView(message: error.localizedDescription)
        })
        .toast(isPresented: $editViewModel.imageUploading,
               content: {
            LoaderToastView(message: NSLocalizedString("profile.edit.image.upload",
                                                              comment: ""))
        })
        .toast(isPresented: $editViewModel.profileUpdating,
               content: {
            LoaderToastView(message: NSLocalizedString("profile.edit.detail.upload",
                                                              comment: ""))
        })
        .toast(isPresented: $editViewModel.didUpdate,
               dismissAfter: 5,
               onDismiss: {
            NotificationCenter.default.post(name: .profileUpdated,
                                            object: nil)
            self.dismiss()
        }, content: {
            SGSuccessToastView(message: NSLocalizedString("profile.edit.submit.pass",
                                                          comment: ""))
        })
        .toastDimmedBackground(false)
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
            
            Text("profile.edit.title".localizedKey)
                .foregroundColor(.text1)
                .font(.system(size: 18, weight: .medium))
            
            Spacer()
            
            Color.clear
                .frame(width: 49, height: 44) //To center align the title
        }
    }
    
    private func headerView() -> some View {
        VStack(alignment: .center, spacing: 25) {
            Text("profile.edit.desc".localizedKey)
                .font(.system(size: 16,
                              weight: .regular))
                .foregroundColor(.text2.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .lineSpacing(6)
            
            ZStack(alignment: .top) {
                KFImage(editViewModel.picturePath)
                    .resizable()
                    .placeholder({
                        Image("profilePlaceholder")
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 92, height: 92)
                    })
                    .fade(duration: 0.25)
                    .cancelOnDisappear(true)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 92, height: 92)
                    .background(Color.textFieldBorder)
                    .clipShape(Capsule())
                    .overlay {
                        if editViewModel.storingMedia {
                                ProgressView()
                                .tint(.darkText)
                        }
                        else {
                                EmptyView()
                        }
                    }
                
                VStack {
                    Color.clear
                        .frame(height: 62) //To push the button down, as per the design specs
                    Button {
                        self.showImagePicker = true
                    } label: {
                        Image("profileCamera")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func footerView() -> some View {
        Button {
            editViewModel.submit()
        } label: {
            
            GeometryReader { proxy in
                Text("profile.edit.save".localizedKey)
                    .kerning(3.53)
                    .font(.system(size: 15,
                                  weight: .medium))
                    .foregroundColor(.darkText)
                    .frame(maxWidth: .infinity)
                    .offset(x: 0,
                            y: proxy.safeAreaInsets.bottom > 0
                            ? 29.0
                            : 0.0) //As per design specs
            }
        }
        .frame(height: 40)
        .background(
            Color.brand2
                .ignoresSafeArea(edges: .bottom)
                .padding(.top, -50)
        )
        
    }
    
    private func nameField() -> some View {
        SGTextField(title: NSLocalizedString("profile.edit.name", comment: ""),
                    placeHolder: NSLocalizedString("field.2.placeholder", comment: ""),
                    value: $editViewModel.name,
                    keyboardType: .default,
                    borderColor: .textFieldBorder,
                    borderWidth: 1)
        .focused($isFocused)
        
    }
    
    private func phoneField() -> some View {
        HStack(alignment: .center,
               spacing: 7) {
            
            if editViewModel.countryCode.isEmpty == false,
               let country = countryKit.countries
                .first(where: {
                    $0.phoneCode == Int(editViewModel.countryCode)
                }) {
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
            
            textField(placeholder: "field.2.placeholder".localizedKey,
                      text: $editViewModel.phoneNumber,
                      keyboardType: .numberPad)
            .frame(maxHeight: .infinity)
        }
               .opacity(0.5)
               .disabled(true)
               .inputFieldStyle(with: "profile.edit.number".localizedKey)
               .padding(.horizontal, 20)
    }
    
    private func emailField() -> some View {
        
        SGTextField(title: NSLocalizedString("profile.edit.email", comment: ""),
                    placeHolder: NSLocalizedString("field.2.placeholder", comment: ""),
                    value: $editViewModel.email,
                    keyboardType: .emailAddress,
                    borderColor: .textFieldBorder,
                    borderWidth: 1)
        .focused($isFocused)
        .opacity(viewModel.isSocialAccount ? 0.5 : 1.0)
        .disabled(viewModel.isSocialAccount)
    }
    
    private func bioField() -> some View {
        SGTextEditor(title: NSLocalizedString("profile.edit.bio", comment: ""),
                     placeHolder: NSLocalizedString("field.2.placeholder", comment: ""),
                     value: $editViewModel.bio,
                     borderColor: .textFieldBorder,
                     borderWidth: 1)
        .focused($isFocused)
    }
    
    //MARK: -
    private func textField(placeholder: LocalizedStringKey,
                           text:Binding<String>,
                           keyboardType:UIKeyboardType) -> some View {
        TextField(placeholder, text: text)
            .font(.system(size: 19,
                          weight: .medium))
            .foregroundColor(.text1)
            .tint(.text1)
            .focused($isFocused)
            .keyboardType(keyboardType)
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(viewModel: UserViewModel())
            .preferredColorScheme(.dark)
    }
}
