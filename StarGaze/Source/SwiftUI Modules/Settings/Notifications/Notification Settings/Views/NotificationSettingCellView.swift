//
//  NotificationSettingCellView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 04/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct NotificationSettingCellView: View {
    var title: String
    var subTitle: String
    var icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(alignment: .top,
               spacing: 15) {
            Image(icon)
                .frame(width: 28)
            
            VStack(alignment: .leading,
                   spacing: 6) {
                Text(title)
                    .foregroundColor(.text1)
                    .font(.system(size: 17,
                                  weight: .regular))
                
                Text(subTitle)
                    .foregroundColor(.text2)
                    .font(.system(size: 16,
                                  weight: .regular))
                    .opacity(0.6)
            }
                   .fixedSize(horizontal: true, vertical: false)                   
                   
            Toggle("",
                   isOn: $isOn)
            .toggleStyle(.switch)
            .tint(.celebBrand)
            
        }
               .padding(.init(top: 20,
                              leading: 20,
                              bottom: 13,
                              trailing: 20))
               .background {
                   Color.brand1
               }
    }
}

struct NotificationSettingCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NotificationSettingCellView(title: "More Activities About you..",
                                        subTitle: "Push notification, SMS",
                                        icon: "commentNotification",
                                        isOn: .constant(true))
            Spacer()
        }
        .preferredColorScheme(.dark)
    }
}
