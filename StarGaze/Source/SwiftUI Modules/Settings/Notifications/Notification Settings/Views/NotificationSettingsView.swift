//
//  NotificationSettingsView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 04/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import ToastUI

struct NotificationSettingsView: View {
    @StateObject private var viewModel = NotifSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Spacer()
                    
                    Text("notification-settings.title")
                        .foregroundColor(.text1)
                        .font(.system(size: 18, weight: .medium))
                    
                    Spacer()
                }
                
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image("navBack")
                            .tint(Color.text1)
                    }
                    .frame(width: 49, height: 49)

                    Spacer()
                }
            }
            .background {
                Color.brand1
                    .ignoresSafeArea(.all, edges: .top)
            }
            
            VStack(spacing: 0) {
                List {
                    NotificationSettingCellView(title: NSLocalizedString("notification-settings.push", comment: ""),
                                                subTitle: viewModel.settings.isOn
                                                ? NSLocalizedString("notification-settings.push.on",
                                                                    comment: "")
                                                : NSLocalizedString("notification-settings.push.off",
                                                                    comment: ""),
                                                icon: viewModel.settings.isOn
                                                ? "pushNotificationOn"
                                                : "pushNotificationOff",
                                                isOn: $viewModel.settings.isOn)
                    .plainCellStyle()
                    
                    if viewModel.settings.isOn {
                        Text("notification-settings.section")
                            .foregroundColor(.text1)
                            .font(.system(size: 18, weight: .medium))
                            .listRowBackground(Color.brand1)
                            .listRowSeparator(.hidden)
                            .padding(.top, 12)
                            .listRowInsets(.init(top: 20, leading: 20, bottom: 4, trailing: 20))
                        
                        
                        NotificationSettingCellView(title: NSLocalizedString("notification-settings.comments", comment: ""),
                                                    subTitle: NSLocalizedString("notification-settings.subtitle",
                                                                                comment: ""),
                                                    icon: "commentNotification",
                                                    isOn: $viewModel.settings.commentsOn)
                        .plainCellStyle()
                        
                        NotificationSettingCellView(title: NSLocalizedString("notification-settings.videocall", comment: ""),
                                                    subTitle: NSLocalizedString("notification-settings.subtitle",
                                                                                comment: ""),
                                                    icon: "callNotification",
                                                    isOn: $viewModel.settings.videosOn)
                        .plainCellStyle()
                        
                        NotificationSettingCellView(title: NSLocalizedString("notification-settings.events", comment: ""),
                                                    subTitle: NSLocalizedString("notification-settings.subtitle",
                                                                                comment: ""),
                                                    icon: "eventNotification",
                                                    isOn: $viewModel.settings.eventsOn)
                        .plainCellStyle()
                        
                        NotificationSettingCellView(title: NSLocalizedString("notification-settings.activities", comment: ""),
                                                    subTitle: NSLocalizedString("notification-settings.subtitle",
                                                                                comment: ""),
                                                    icon: "activityNotification",
                                                    isOn: $viewModel.settings.activitiesOn)
                        .plainCellStyle(showSeparator: false)
                    }
                                            
                }
                .listStyle(.plain)
                .background {
                    Color.brand1
                }
                .cornerRadius(40, corners: [.bottomLeft, .bottomRight])
            }
            
            Button {
                viewModel.saveChanges()
            } label: {
                GeometryReader { proxy in
                    Text("notification-settings.save.title")
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
            .frame(height: 44)
            .disabled(!viewModel.hasChanges)
            .opacity(viewModel.hasChanges ? 1.0 : 0.5)

        }
        .background {
            Color.brand2
                .ignoresSafeArea()
                .opacity(viewModel.hasChanges ? 1.0 : 0.5)
        }
        .toast(item: $viewModel.error,
               dismissAfter: 3) {
        } content: { error in
            SGErrorToastView(message: error.localizedDescription)
        }
        .toastDimmedBackground(false)
        .toast(isPresented: $viewModel.changesSaved,
               dismissAfter: 3,
               onDismiss: {
            
        }, content: {
            SGSuccessToastView(message: NSLocalizedString("notification-settings.saved", comment: ""))
        })
        .toastDimmedBackground(false)
        .onChange(of: viewModel.loading) { newValue in
            if newValue {
                SGAlertUtility.showHUD()
            }
            else {
                SGAlertUtility.hidHUD()
            }
        }
        .onAppear {
            viewModel.fetchSettings()
        }
    }
}

extension View {
    func plainCellStyle(showSeparator: Bool = true) -> some View {
        VStack(spacing: 0) {
            self
            
            if showSeparator {
                Divider()
                    .foregroundColor(.tableSeparator)
                    .padding(.horizontal, 20)
            }
        }
        .listRowBackground(Color.brand1)
        .listRowInsets(.init())
        .listRowSeparator(.hidden)
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}
