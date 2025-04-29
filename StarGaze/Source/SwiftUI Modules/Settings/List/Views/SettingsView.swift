//
//  SettingsView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 10/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import ToastUI

struct SettingsView: View {
    @EnvironmentObject private var menuViewModel: SideMenuViewModel
    
    @State var sections:[SettingsSectionInfo] = []
    
    @State private var loadAbout: Bool = false
    @State private var loadTerms: Bool = false
    @State private var confirmDelete: Bool = false
    @State private var deleteSuccess: Bool = false
    @State private var error: SGAPIError? = nil
    @State private var pickedItem: SettingsType? = nil
    
    init() {
        _sections = State(initialValue: [
            SettingsSectionInfo(title: "", option: [.notifications, .blockedAccounts, .about, .faq, .terms]),
            SettingsSectionInfo(title: "Dangerous area", option: [.deleteAccount])
        ])
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            navView()
                .padding(.top, UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
            
            List {
                ForEach(sections, id: \.self) { section in
                    if !section.title.isEmpty {
                        Text(section.title)
                            .foregroundColor(.text2)
                            .font(.system(size: 14,
                                          weight: .medium))
                            .opacity(0.5)
                            .listRowInsets(.init(top: 7, leading: 20, bottom: 0, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.brand1)
                    }
                    
                    ForEach(section.option, id:\.self) { type in
                        cellView(for: type)
                            .onTapGesture {
                                if type == .deleteAccount {
                                    self.confirmDelete = true
                                }
                                else {
                                    self.pickedItem = type
                                }
                            }
                    }
                }
            }
            .listStyle(.plain)
            .padding(.bottom, UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)

        }
        .background {
            Color.brand1
                .ignoresSafeArea()
        }
        .alert("Delete Account",
               isPresented: $confirmDelete,
               actions: {
            Button("Cancel", role: .cancel) {}
            
            Button("Delete", role: .destructive) {
                self.deleteAccount()
            }
        },
               message: {
            Text("Are you sure you want to delete your account? This will permanently erase your account.")
        })
        .fullScreenCover(item: $pickedItem, content: { type in
            switch type {
            case .notifications:
                NotificationSettingsView()
                
            case .blockedAccounts:
                BlockedUserListView()
                
            case .about:
                WebView(title: NSLocalizedString("settings.about-us.title",
                                                 comment: ""),
                        url: URL(string: "https://stargaze.ai/about")!)
                
            case .faq:
                FaqListView()
                
            case .terms:
                WebView(title: NSLocalizedString("package.terms.title",
                                                 comment: ""),
                        url: URL(string: "https://stargaze.ai/terms-and-conditions")!)
                
            case .deleteAccount:
                EmptyView()
            }
        })
        .toast(item: $error,
               dismissAfter: 3) {
            
        } content: { error in
            SGErrorToastView(message: error.localizedDescription)
        }
        .toastDimmedBackground(false)
        .toast(isPresented: $deleteSuccess,
               dismissAfter: 5) {
            self.navigateToIntro()
        } content: {
            SGSuccessToastView(message: "Your account has been deleted successfully")
        }


    }
    
    private func navView() -> some View {
        ZStack {
            HStack {
                Spacer()
                
                Text("settings.title")
                    .foregroundColor(.text1)
                    .font(.system(size: 18,
                                  weight: .medium))
                
                Spacer()
            }
            
            HStack {
                Button {
                    menuViewModel.showMenu = true
                } label: {
                    Image("navBack")
                }
                .frame(width: 49,
                       height: 46)

                Spacer()
            }
        }
        .background {
            Color.brand1
                .ignoresSafeArea(.all,
                                 edges: .top)
        }
        .tint(.text1)
    }
    
    private func cellView(for type: SettingsType) -> some View {
        HStack(spacing: 21) {
            Image(type.iconName)
            
            Text(type.title)
                .foregroundColor(.text1)
                .font(.system(size: 16, weight: .regular))
            
            Spacer()
        }
        .frame(height: 75)
        .listRowBackground(Color.brand1)
        .listRowSeparator(.hidden)
        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    //MARK: -
    private func deleteAccount() {
        SGAlertUtility.showHUD()
        
        Task.detached {
            let result = await SGUserService.shared.deleteAccount()
            switch result {
            case .success(_):
                await showDeleteSuccess()
            case .failure(let failure):
                await showError(failure)
            }
        }
    }
    
    private func navigateToIntro() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .logout, object: nil)
        }
    }
    
    @MainActor
    private func showError(_ error: SGAPIError) async {
        SGAlertUtility.hidHUD()
        self.error = error
    }
    
    @MainActor
    private func showDeleteSuccess() async {
        SGAlertUtility.hidHUD()
        self.deleteSuccess = true
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
